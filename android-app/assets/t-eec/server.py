import argparse
import contextlib
import copy
import importlib.metadata
import json
import os
import subprocess
import sys
import tempfile
import threading
import time
import uuid
from collections import deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

from ingestion import ConflictError, IngestionService
from model_runtime import MODEL_SPECS, ModelRuntime, validate_payload
from retrieval import RetrievalService


def now():
    return time.time()


class SemanticService:
    def __init__(self, models_dir, data_dir):
        self.models_dir = Path(models_dir)
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.instance_id = uuid.uuid4().hex
        self.started_at = now()
        self.lock = threading.RLock()
        self.chroma_lock = threading.RLock()
        self.lazy_lock = threading.Lock()
        self.model_locks = {key: threading.Lock() for key in MODEL_SPECS}
        self.events = deque(maxlen=2048)
        self.cursor = 0
        self.runtimes = {}
        self.runtime_assets = {}
        self.models = {key: {"id": key, "name": spec["name"], "connected": False, "ready": False, "active_count": 0, "loaded": False, "last_error": None, "last_success": None, "resident": spec["resident"]} for key, spec in MODEL_SPECS.items()}
        self.components = {key: {"ready": False, "last_error": None} for key in ("chroma", "langchain")}
        self.selftest = {"running": False, "passed": False, "last_error": None, "checks": {}}
        self.chroma = None
        self.ingestion = IngestionService(self.models_dir, self.data_dir, embed=lambda texts: self.run("e5", {"texts": texts, "kind": "passage"})["result"]["embeddings"], check_embedding=self.check_ingestion_assets)
        self.retrieval = RetrievalService(self)

    def check_ingestion_assets(self, expected):
        with self.lock:
            actual = self.runtime_assets.get("e5")
            if actual is not None and actual != expected:
                raise ValueError("Loaded E5 assets differ from the ingestion snapshot; restart the semantic service before ingesting")

    def event(self, kind, model_id=None, operation=None, error=None):
        with self.lock:
            self.cursor += 1
            item = {"seq": self.cursor, "time": now(), "kind": kind, "model_id": model_id, "operation": operation}
            if model_id is not None:
                item["active_count"] = self.models[model_id]["active_count"]
                item["loaded"] = self.models[model_id]["loaded"]
            if error is not None:
                item["error"] = error
            self.events.append(item)

    def connected(self, model_id):
        path = self.models_dir / MODEL_SPECS[model_id]["name"]
        config = "gliner_config.json" if model_id == "gliner" else "config.json"
        return all((path / part).is_file() and (path / part).stat().st_size > 0 for part in ("onnx/model_int8.onnx", "tokenizer.json", config))

    def snapshot(self, probe=True):
        if probe and self.chroma is not None and self.chroma_lock.acquire(blocking=False):
            try:
                heartbeat = self.chroma.heartbeat()
                self.chroma.count_collections()
                if not heartbeat:
                    raise RuntimeError("Chroma heartbeat is empty")
                with self.lock:
                    self.components["chroma"]["last_health_check"] = now()
            except Exception as error:
                with self.lock:
                    self.components["chroma"].update(ready=False, last_error=str(error))
            finally:
                self.chroma_lock.release()
        with self.lock:
            for key in self.models:
                try:
                    self.models[key]["connected"] = self.connected(key)
                except OSError:
                    self.models[key]["connected"] = False
            ready = self.selftest["passed"] and not self.selftest["running"] and all(item["ready"] and item["connected"] for item in self.models.values()) and all(item["ready"] for item in self.components.values())
            return copy.deepcopy({"schema": "t-eec.status/1", "ready": ready, "instance_id": self.instance_id, "started_at": self.started_at, "event_cursor": self.cursor, "models": list(self.models.values()), "components": self.components, "selftest": self.selftest})

    def events_after(self, after):
        self.snapshot()
        with self.lock:
            snapshot = self.snapshot(probe=False)
            oldest = self.events[0]["seq"] if self.events else self.cursor + 1
            return {"cursor": self.cursor, "oldest_seq": oldest, "truncated": after < oldest - 1 or after > self.cursor, "events": [copy.deepcopy(item) for item in self.events if item["seq"] > after], "snapshot": snapshot}

    @contextlib.contextmanager
    def activity(self, model_id, operation):
        started = time.monotonic()
        with self.lock:
            self.models[model_id]["active_count"] += 1
            self.event("start", model_id, operation)
        try:
            yield
        except ValueError as error:
            self.event("rejected", model_id, operation, str(error))
            raise
        except Exception as error:
            with self.lock:
                self.models[model_id].update(ready=False, last_error=type(error).__name__ + ": " + str(error))
                self.event("error", model_id, operation, self.models[model_id]["last_error"])
            raise
        else:
            with self.lock:
                self.models[model_id].update(ready=True, last_error=None, last_success=now())
        finally:
            with self.lock:
                self.models[model_id]["active_count"] -= 1
                self.models[model_id]["last_duration_ms"] = round((time.monotonic() - started) * 1000, 3)
                self.event("end", model_id, operation)

    def run(self, model_id, payload):
        if model_id not in self.models:
            raise KeyError(model_id)
        validate_payload(model_id, payload)
        resident = MODEL_SPECS[model_id]["resident"]
        with self.model_locks[model_id], (contextlib.nullcontext() if resident else self.lazy_lock):
            with self.activity(model_id, "inference"):
                if resident:
                    result = self._load_resident(model_id).run(payload)
                else:
                    result = self.run_worker(model_id, payload)
        return {"model_id": model_id, "result": result, "duration_ms": self.models[model_id]["last_duration_ms"]}

    def _load_resident(self, model_id):
        if model_id not in self.runtimes:
            identity = self.ingestion.model_identity() if model_id == "e5" else None
            runtime = ModelRuntime(model_id, self.models_dir)
            if model_id == "e5" and identity != self.ingestion.model_identity():
                raise ValueError("E5 assets changed while loading; retry after the files are stable")
            self.runtimes[model_id] = runtime
            with self.lock:
                if model_id == "e5":
                    self.runtime_assets[model_id] = identity
                self.models[model_id]["loaded"] = True
                self.models[model_id]["signature"] = runtime.signature
                self.event("loaded", model_id, "load")
        return self.runtimes[model_id]

    def resident_runtime(self, model_id):
        if model_id not in MODEL_SPECS or not MODEL_SPECS[model_id]["resident"]:
            raise ValueError("A resident model is required")
        with self.model_locks[model_id]:
            if model_id in self.runtimes:
                return self.runtimes[model_id]
            with self.activity(model_id, "load"):
                return self._load_resident(model_id)

    def run_worker(self, model_id, payload):
        command = [sys.executable, str(Path(__file__).with_name("model_runtime.py")), "--worker", model_id, "--models-dir", str(self.models_dir)]
        result, worker_error, worker_error_type = None, None, None
        try:
            with tempfile.TemporaryFile(mode="w+t") as errors:
                process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=errors, text=True)
                try:
                    process.stdin.write(json.dumps(payload) + "\n")
                    process.stdin.close()
                    for line in process.stdout:
                        message = json.loads(line)
                        if message.get("kind") == "loaded":
                            with self.lock:
                                self.models[model_id]["loaded"] = True
                                self.models[model_id]["signature"] = message["signature"]
                                self.event("loaded", model_id, "load")
                        elif message.get("kind") == "result":
                            result = message["result"]
                        elif message.get("kind") == "error":
                            worker_error = message["error"]
                            worker_error_type = message.get("error_type")
                    exit_code = process.wait()
                    if exit_code or worker_error or result is None:
                        errors.seek(0)
                        detail = errors.read()[-4096:]
                        if worker_error_type == "ValueError":
                            raise ValueError(worker_error)
                        raise RuntimeError(worker_error or "Model worker exited " + str(exit_code) + ": " + detail)
                finally:
                    if process.poll() is None:
                        process.terminate()
                        process.wait()
                    process.stdout.close()
        finally:
            with self.lock:
                self.models[model_id]["loaded"] = False
                self.event("unloaded", model_id, "unload")
        return result

    def start_selftest(self):
        with self.lock:
            if self.selftest["running"]:
                return False
            self.selftest = {"running": True, "passed": False, "started_at": now(), "last_error": None, "checks": {}}
            self.event("selftest_start", operation="selftest")
        threading.Thread(target=self.perform_selftest, name="semantic-selftest", daemon=True).start()
        return True

    def record_check(self, name, result):
        with self.lock:
            self.selftest["checks"][name] = result

    def perform_selftest(self):
        failures = []
        samples = {
            "e5": {"texts": ["Paris is the capital of France.", "The cat is sleeping."], "kind": "passage"},
            "tinybert": {"query": "What is the capital of France?", "docs": ["Paris is the capital of France.", "Bananas are yellow fruit."]},
            "nli": {"pairs": [{"premise": "A dog is running.", "hypothesis": "An animal is running."}, {"premise": "A dog is running.", "hypothesis": "No animal is running."}]},
            "gliner": {"text": "Alice works at Microsoft in Paris.", "labels": ["person", "organization", "location"]},
        }
        for key, payload in samples.items():
            try:
                outcome = self.run(key, payload)
                value = outcome["result"]
                if key == "e5":
                    import numpy as np
                    vectors = np.asarray(value["embeddings"])
                    if vectors.shape != (2, 384) or not np.allclose(np.linalg.norm(vectors, axis=1), 1, atol=1e-5) or np.allclose(vectors[0], vectors[1]):
                        raise RuntimeError("Embedding smoke check failed")
                    evidence = {"dimensions": 384, "normalized": True, "distinct": True}
                elif key == "tinybert":
                    if value["ranking"][0] != 0 or value["scores"][0] <= value["scores"][1]:
                        raise RuntimeError("Reranker did not rank the relevant passage first")
                    evidence = value
                elif key == "nli":
                    if [item["label"] for item in value["predictions"]] != ["entailment", "contradiction"]:
                        raise RuntimeError("NLI semantic smoke check failed: " + str([item["label"] for item in value["predictions"]]))
                    evidence = value
                else:
                    labels = {item["label"] for item in value["entities"]}
                    if not {"person", "organization", "location"}.issubset(labels):
                        raise RuntimeError("GLiNER did not recognize the three fixture entity types: " + json.dumps(value))
                    evidence = value
                self.record_check(key, {"passed": True, "duration_ms": outcome["duration_ms"], "evidence": evidence})
            except Exception as error:
                failures.append(key + ": " + str(error))
                with self.lock:
                    self.models[key].update(ready=False, last_error=str(error))
                self.record_check(key, {"passed": False, "error": str(error)})
        try:
            self.record_check("rag", {"passed": True, "evidence": self.rag_selftest()})
        except Exception as error:
            failures.append("rag: " + str(error))
            self.record_check("rag", {"passed": False, "error": str(error)})
            with self.lock:
                for item in self.components.values():
                    item.update(ready=False, last_error=str(error))
        with self.lock:
            self.selftest.update(running=False, passed=not failures, finished_at=now(), last_error="; ".join(failures) if failures else None)
            try:
                self.persist_selftest()
            except Exception as error:
                self.selftest.update(passed=False, last_error="Could not persist selftest evidence: " + str(error))
            self.event("selftest_end", operation="selftest", error=self.selftest["last_error"])

    def persist_selftest(self):
        record = {"instance_id": self.instance_id, "selftest": self.selftest, "components": self.components}
        path = self.data_dir / "last-selftest.json"
        temporary = path.with_suffix(".tmp")
        temporary.write_text(json.dumps(record, indent=2, allow_nan=False) + "\n")
        os.replace(temporary, path)

    def rag_selftest(self):
        import chromadb
        from chromadb.config import Settings
        from langchain_chroma import Chroma
        from langchain_core.embeddings import Embeddings
        from langchain_text_splitters import RecursiveCharacterTextSplitter

        service = self

        class ServiceEmbeddings(Embeddings):
            def embed_documents(self, texts):
                return service.run("e5", {"texts": texts, "kind": "passage"})["result"]["embeddings"]

            def embed_query(self, text):
                return service.run("e5", {"texts": [text], "kind": "query"})["result"]["embeddings"][0]

        with self.chroma_lock:
            directory = str(self.data_dir / "chroma")
            client = chromadb.PersistentClient(path=directory, settings=Settings(anonymized_telemetry=False))
            self.chroma = client
            collection_name = "semantic_selftest_" + uuid.uuid4().hex
            collection = client.create_collection(collection_name, embedding_function=None, metadata={"hnsw:space": "cosine"})
            try:
                texts = ["Paris is the capital of France. The Eiffel Tower is in Paris.", "Bananas are tropical fruit. They grow in warm climates."]
                documents = RecursiveCharacterTextSplitter(chunk_size=80, chunk_overlap=0).create_documents(texts, metadatas=[{"fixture": "paris"}, {"fixture": "banana"}])
                adapter = ServiceEmbeddings()
                vectors = adapter.embed_documents([doc.page_content for doc in documents])
                collection.add(ids=["fixture_" + str(index) for index in range(len(documents))], documents=[doc.page_content for doc in documents], metadatas=[doc.metadata for doc in documents], embeddings=vectors)
                query = adapter.embed_query("What is the capital of France?")
                result = collection.query(query_embeddings=[query], n_results=1, include=["metadatas", "distances"])
                if result["metadatas"][0][0]["fixture"] != "paris":
                    raise RuntimeError("Chroma semantic query returned the wrong fixture")
                command = [sys.executable, str(Path(__file__).resolve()), "--reopen-check", directory, "--collection", collection_name]
                reopened = subprocess.run(command, input=json.dumps({"query": query, "count": len(documents)}), capture_output=True, text=True)
                if reopened.returncode:
                    raise RuntimeError("Fresh-process persistence check failed: " + reopened.stderr[-2048:])
                reopen_evidence = json.loads(reopened.stdout)
                store = Chroma(client=client, collection_name=collection_name, embedding_function=adapter, create_collection_if_not_exists=False)
                found = store.similarity_search("What is the capital of France?", k=1)
                if len(found) != 1 or found[0].metadata.get("fixture") != "paris":
                    raise RuntimeError("LangChain Chroma adapter returned the wrong document")
                versions = {name: importlib.metadata.version(name) for name in ("chromadb", "langchain-core", "langchain-chroma", "langchain-text-splitters")}
                with self.lock:
                    self.components["chroma"].update(ready=True, last_error=None, version=versions["chromadb"], persisted_reopen=True, last_health_check=now())
                    self.components["langchain"].update(ready=True, last_error=None, versions=versions, adapter_query=True)
                return {"dimensions": 384, "documents": len(documents), "chroma_top_fixture": "paris", "reopened": reopen_evidence, "langchain_top_fixture": found[0].metadata["fixture"], "versions": versions}
            finally:
                client.delete_collection(collection_name)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, format, *args):
        return

    def reply(self, status, value):
        body = json.dumps(value, allow_nan=False, separators=(",", ":")).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_GET(self):
        route = urlsplit(self.path)
        if route.path == "/rag/status":
            try:
                self.reply(200, self.server.service.retrieval.status())
            except ValueError as error:
                self.reply(400, {"error": str(error)})
            except Exception as error:
                self.reply(500, {"error": type(error).__name__ + ": " + str(error)})
        elif route.path.startswith("/ingest/"):
            try:
                if route.path == "/ingest/config":
                    self.reply(200, self.server.service.ingestion.config())
                elif route.path == "/ingest/status":
                    self.reply(200, self.server.service.ingestion.status())
                elif route.path == "/ingest/jobs":
                    self.reply(200, {"job": self.server.service.ingestion.job(parse_qs(route.query).get("id", [""])[0])})
                else:
                    self.reply(404, {"error": "Unknown ingestion endpoint"})
            except KeyError as error:
                self.reply(404, {"error": str(error)})
            except ValueError as error:
                self.reply(400, {"error": str(error)})
            except Exception as error:
                self.reply(500, {"error": type(error).__name__ + ": " + str(error)})
        elif route.path in ("/health/status", "/health", "/status"):
            self.reply(200, self.server.service.snapshot())
        elif route.path == "/events":
            try:
                after = int(parse_qs(route.query).get("after", ["0"])[0])
                if after < 0:
                    raise ValueError("after must be nonnegative")
                self.reply(200, self.server.service.events_after(after))
            except ValueError as error:
                self.reply(400, {"error": str(error)})
        else:
            self.reply(404, {"error": "Unknown endpoint"})

    def do_POST(self):
        route = urlsplit(self.path).path
        try:
            if self.headers.get("Transfer-Encoding"):
                raise ValueError("Content-Length framing required")
            length = int(self.headers.get("Content-Length", "0"))
            if length < 0:
                raise ValueError("Invalid Content-Length")
            body = self.rfile.read(length)
            payload = json.loads(body) if body else {}
            if route in ("/rag/search", "/rag/route-and-retrieve"):
                self.reply(200, self.server.service.retrieval.search(payload))
            elif route == "/rag/route":
                self.reply(200, self.server.service.retrieval.route(payload))
            elif route == "/rag/get":
                self.reply(200, self.server.service.retrieval.get(payload))
            elif route == "/ingest/config":
                self.reply(200, self.server.service.ingestion.save_config(payload))
            elif route == "/ingest/jobs":
                self.reply(202, {"job": self.server.service.ingestion.start_job(payload)})
            elif route == "/selftest":
                started = self.server.service.start_selftest()
                self.reply(202 if started else 409, {"started": started, "snapshot": self.server.service.snapshot(probe=False)})
            elif route.startswith("/models/") and route.endswith("/run") and len(route.split("/")) == 4:
                self.reply(200, self.server.service.run(route.split("/")[2], payload))
            else:
                self.reply(404, {"error": "Unknown endpoint"})
        except ConflictError as error:
            self.reply(409, {"error": str(error)})
        except (ValueError, json.JSONDecodeError) as error:
            self.reply(400, {"error": str(error)})
        except KeyError as error:
            self.reply(404, {"error": str(error) if route.startswith("/rag/") else "Unknown model: " + str(error)})
        except Exception as error:
            self.reply(500, {"error": type(error).__name__ + ": " + str(error)})


def reopen_check(directory, collection_name):
    import chromadb
    from chromadb.config import Settings
    payload = json.load(sys.stdin)
    client = chromadb.PersistentClient(path=directory, settings=Settings(anonymized_telemetry=False))
    collection = client.get_collection(collection_name, embedding_function=None)
    result = collection.query(query_embeddings=[payload["query"]], n_results=1, include=["metadatas"])
    count = collection.count()
    if count != payload["count"] or result["metadatas"][0][0]["fixture"] != "paris":
        raise RuntimeError("Persisted collection content/query differs")
    print(json.dumps({"fresh_process": True, "count": count, "top_fixture": "paris"}), flush=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8867)
    parser.add_argument("--models-dir", default="/opt/t-eec/models")
    parser.add_argument("--data-dir", default="/opt/t-eec/data")
    parser.add_argument("--reopen-check")
    parser.add_argument("--collection")
    args = parser.parse_args()
    if args.reopen_check:
        reopen_check(args.reopen_check, args.collection)
        return
    service = SemanticService(args.models_dir, args.data_dir)
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    server.service = service
    service.start_selftest()
    print(json.dumps({"event": "listening", "host": args.host, "port": args.port, "instance_id": service.instance_id}), flush=True)
    try:
        server.serve_forever()
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
