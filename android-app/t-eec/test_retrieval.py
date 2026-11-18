import copy
import hashlib
import importlib.util
import json
import math
import os
import re
import sys
import tempfile
import threading
import types
import unittest
from http.client import HTTPConnection
from http.server import ThreadingHTTPServer
from pathlib import Path
from unittest.mock import patch

from ingestion import ConflictError, IngestionService, atomic_write, encoded
from retrieval import RetrievalService, default_routing_config, token_windows


def vector(first=1.0, second=0.0):
    return [first, second] + [0.0] * 382


class FakeCollection:
    def __init__(self, metric="l2"):
        self.rows = {}
        self.configuration = {"hnsw": {"space": metric}}
        self.queries = []
        self.on_query = None

    def count(self):
        return len(self.rows)

    def query(self, query_embeddings, n_results, include):
        self.queries.append(n_results)
        if self.on_query:
            self.on_query()
        items = sorted(self.rows.items(), key=lambda item: (item[1]["distance"], item[0]))[:n_results]
        return {"ids": [[key for key, _ in items]], "documents": [[row["text"] for _, row in items]], "metadatas": [[copy.deepcopy(row["metadata"]) for _, row in items]], "distances": [[row["distance"] for _, row in items]]}

    def get(self, ids=None, where=None, include=None):
        items = [(key, row) for key, row in self.rows.items() if (ids is None or key in ids) and (where is None or all(row["metadata"].get(field) == value for field, value in where.items()))]
        return {"ids": [key for key, _ in items], "documents": [row["text"] for _, row in items], "metadatas": [copy.deepcopy(row["metadata"]) for _, row in items]}


class FakeTokenizer:
    def encode(self, text, add_special_tokens=True):
        spans = [item.span() for item in re.finditer(r"\S+", text)]
        return types.SimpleNamespace(ids=[1] * (len(spans) + (2 if add_special_tokens else 0)), offsets=spans)


class FakeService:
    def __init__(self, root):
        self.ingestion = IngestionService(root / "models", root / "data")
        self.identity = {"id": "e5", "kind": "passage", "normalization": "mean_pool_l2", "model_sha256": "model-a", "config_sha256": "config-a", "max_tokens": 512, "tokenizer_sha256": "tokenizer-a"}
        self.ingestion.model_identity = lambda: copy.deepcopy(self.identity)
        self.calls = []
        self.profile_vectors = {}
        self.query_vector = vector()
        self.rerank_scores = None
        self.tokenizer = FakeTokenizer()
        self.window_vector = None
        self.retrieval = RetrievalService(self)

    def check_ingestion_assets(self, expected):
        if expected != self.identity:
            raise ValueError("Loaded model mismatch")

    def snapshot(self, probe=False):
        return {"ready": True}

    def resident_runtime(self, model):
        if model != "e5":
            raise AssertionError("Unexpected tokenizer request")
        return types.SimpleNamespace(tokenizer=self.tokenizer)

    def run(self, model, payload):
        self.calls.append((model, copy.deepcopy(payload)))
        if model == "tinybert":
            scores = self.rerank_scores or list(range(len(payload["docs"])))
            return {"result": {"scores": scores}}
        if any(len(self.tokenizer.encode(payload["kind"] + ": " + text).ids) > 512 for text in payload["texts"]):
            raise ValueError("Input exceeds the model's 512 subtoken limit")
        values = [(self.window_vector(text) if self.window_vector else self.query_vector) if payload["kind"] == "query" else self.profile_vectors.get(text.split("\n")[0], vector()) for text in payload["texts"]]
        return {"result": {"embeddings": copy.deepcopy(values)}}


class RetrievalFixture:
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.service = FakeService(self.root)
        self.retrieval = self.service.retrieval
        self.ingestion = self.service.ingestion

    def tearDown(self):
        self.temporary.cleanup()

    def add(self, key="microskills", identifier="chunk-a", source_key="source-a", record_id="record-a", text="Original full record", chunk="Original", distance=0.1, identity=None):
        collection = self.ingestion.collections.setdefault(key, FakeCollection())
        embedding = dict(identity or self.service.identity)
        tokenizer_hash = embedding.pop("tokenizer_sha256")
        fingerprint = source_key + "-fingerprint"
        metadata = {"_ingest_source_key": source_key, "_ingest_record_id": record_id, "_ingest_fingerprint": fingerprint, "_ingest_source_path": "/storage/emulated/0/" + source_key + ".txt", "_ingest_source_side": "android", "_ingest_chunk_index": 0}
        record = {"id": record_id, "text": text, "metadata": {"skill_code": "SKILL-1"}, "source": {"path": metadata["_ingest_source_path"], "side": "android", "sha256": "source-hash"}, "chunks": [{"index": 0, "text": chunk, "token_ids": [1, 2]}]}
        prepared_file = "prepared/" + source_key + ".jsonl"
        content = encoded(record) + b"\n"
        atomic_write(self.ingestion.department_path(key) / prepared_file, content)
        manifest = self.ingestion.manifest(key)
        previous = manifest["sources"].get(source_key, {})
        manifest["sources"][source_key] = {"state": "indexed", "vector_ids": previous.get("vector_ids", []) + [identifier], "fingerprint": fingerprint, "embedding": embedding, "tokenizer": {"sha256": tokenizer_hash}, "prepared_file": prepared_file, "prepared_sha256": hashlib.sha256(content).hexdigest()}
        atomic_write(self.ingestion.department_path(key) / "manifest.json", encoded(manifest))
        collection.rows[identifier] = {"text": chunk, "metadata": metadata, "distance": distance}
        return collection

    def department(self, key, **values):
        config = self.ingestion.config()
        next(item for item in config["departments"] if item["id"] == key).update(values)
        self.ingestion.save_config(config)

    def route_config(self, **selection):
        value = default_routing_config()
        value["selection"].update(selection)
        atomic_write(self.retrieval.config_path, encoded(value))


class RetrievalTests(RetrievalFixture, unittest.TestCase):
    def test_status_reads_manifests_without_opening_chroma_or_serializing_jobs(self):
        self.add()
        self.ingestion.collections.clear()
        self.ingestion.jobs["job-a"] = {"id": "job-a", "state": "running", "progress": {"files": 42}, "result": {"huge": "x" * 100000}}
        with patch.object(self.retrieval, "collection", side_effect=AssertionError("Unexpected client opening")):
            result = self.retrieval.status()
        self.assertEqual(result["departments"][0]["indexed_chunks"], 1)
        self.assertEqual(result["active_jobs"], [{"id": "job-a", "state": "running", "progress": {"files": 42}}])
        self.assertFalse(any(item["loaded"] for item in result["departments"]))
        self.assertEqual(self.service.calls, [])
        self.assertLess(len(encoded(result)), 5000)

    def test_invalid_requests_do_not_call_models(self):
        for payload in (None, [], {}, {"query": " "}, {"query": "x", "department_ids": []}, {"query": "x", "department_ids": [[]]}, {"query": "x", "department_ids": ["microskills", "microskills"]}, {"query": "x", "top_k": True}, {"query": "x", "top_k": 0}, {"query": "x", "rerank": "false"}):
            with self.subTest(payload=payload), self.assertRaises(ValueError):
                self.retrieval.search(payload)
        self.assertEqual(self.service.calls, [])

    def test_explicit_route_preserves_departments_and_empty_search_avoids_inference(self):
        payload = {"query": "hello", "department_ids": ["department-6", "microskills"]}
        self.assertEqual(self.retrieval.route(payload)["routing"]["department_ids"], payload["department_ids"])
        result = self.retrieval.search(payload)
        self.assertEqual(result["results"], [])
        self.assertEqual(result["routing"]["reason"], "explicit")
        self.assertEqual(self.service.calls, [])
        self.assertEqual(self.ingestion.clients, {})

    def test_literal_rules_are_casefolded_data_and_override_semantic_routing(self):
        self.add()
        self.add("department-2", "chunk-b")
        self.department("department-2", name="ANDROID", phrases=["APK İncele"], rules=["__import__('os').unlink('/tmp/example')"])
        result = self.retrieval.route({"query": "Lütfen APK İncele işlemini yap"})
        self.assertEqual(result["routing"]["department_ids"], ["department-2"])
        self.assertEqual(result["routing"]["reason"], "literal")
        code = "__import__('os').unlink('/tmp/example')"
        result = self.retrieval.route({"query": code})
        self.assertEqual(result["routing"]["matched"][0]["field"], "rules")
        self.assertEqual(self.service.calls, [])

    def test_unnamed_empty_and_populated_placeholders_are_not_automatic_profiles(self):
        self.add()
        self.add("department-2", "chunk-b")
        result = self.retrieval.route({"query": "task"})
        self.assertEqual(result["routing"]["department_ids"], ["microskills"])
        self.assertEqual(result["routing"]["reason"], "single_populated_department")
        self.assertEqual(self.service.calls, [])

    def test_semantic_search_embeds_query_once_and_caches_passage_profiles(self):
        self.add()
        self.add("department-2", "chunk-b", source_key="source-b", distance=0.05)
        self.department("department-2", name="ANDROID", description="Android package analysis", examples=["Inspect an APK"])
        self.service.profile_vectors = {"MICROSKILLS": vector(0.8, 0.6), "ANDROID": vector()}
        result = self.retrieval.search({"query": "inspect application", "top_k": 2})
        self.assertEqual(result["routing"]["reason"], "semantic")
        self.assertEqual(result["routing"]["department_ids"], ["department-2"])
        self.assertEqual(result["results"][0]["id"], "chunk-b")
        self.assertEqual([call[1]["kind"] for call in self.service.calls], ["query", "passage"])
        self.retrieval.search({"query": "inspect another application"})
        self.assertEqual([call[1]["kind"] for call in self.service.calls], ["query", "passage", "query"])
        self.department("department-2", examples=["New routing example"])
        self.retrieval.route({"query": "different application"})
        self.assertEqual([call[1]["kind"] for call in self.service.calls], ["query", "passage", "query", "query", "passage"])

    def test_top_n_policy_and_explicit_threshold_fallback_are_configurable(self):
        self.add()
        self.add("department-2", "chunk-b", source_key="source-b")
        self.department("department-2", name="ANDROID")
        self.service.profile_vectors = {"MICROSKILLS": vector(0.8, 0.6), "ANDROID": vector(0.0, 1.0)}
        self.route_config(mode="top_n", max_departments=2)
        result = self.retrieval.route({"query": "task"})
        self.assertEqual(result["routing"]["department_ids"], ["microskills", "department-2"])
        self.route_config(mode="top_n", min_score=0.95)
        result = self.retrieval.route({"query": "task"})
        self.assertEqual(result["routing"]["reason"], "fallback")
        self.assertEqual(result["routing"]["department_ids"], ["microskills"])

    def test_pending_and_incompatible_nearest_hits_are_excluded_with_candidate_expansion(self):
        collection = self.add(identifier="safe", source_key="safe", distance=0.3)
        self.add(identifier="pending", source_key="pending", distance=0.01)
        stale_identity = dict(self.service.identity, model_sha256="old-model")
        self.add(identifier="stale", source_key="stale", distance=0.02, identity=stale_identity)
        manifest = self.ingestion.manifest("microskills")
        manifest["pending"]["pending"] = manifest["sources"]["pending"]
        atomic_write(self.ingestion.department_path("microskills") / "manifest.json", encoded(manifest))
        result = self.retrieval.search({"query": "x", "top_k": 1})
        self.assertEqual([item["id"] for item in result["results"]], ["safe"])
        self.assertEqual(collection.queries, [1, 2, 3])
        self.assertEqual(result["warnings"][0]["count"], 2)

    def test_concurrent_commit_start_cannot_publish_half_committed_hit(self):
        collection = self.add()
        entered, committed = threading.Event(), threading.Event()

        def commit():
            if not entered.wait(5):
                return
            manifest = self.ingestion.manifest("microskills")
            manifest["pending"]["source-a"] = manifest["sources"]["source-a"]
            atomic_write(self.ingestion.department_path("microskills") / "manifest.json", encoded(manifest))
            committed.set()

        def during_query():
            entered.set()
            if not committed.wait(5):
                raise AssertionError("Concurrent commit did not reach pending state")

        writer = threading.Thread(target=commit)
        writer.start()
        collection.on_query = during_query
        try:
            result = self.retrieval.search({"query": "x"})
        finally:
            writer.join(5)
        self.assertFalse(writer.is_alive())
        self.assertEqual(result["results"], [])
        self.assertEqual(result["warnings"][0]["reason"], "uncommitted_or_incompatible_candidates_excluded")

    def test_mixed_metrics_are_not_compared_as_equal_scales_and_optional_rerank_is_real(self):
        self.add(identifier="a", distance=100)
        other = self.add("department-2", "b", "source-b", distance=0.01)
        other.configuration = {"hnsw": {"space": "cosine"}}
        payload = {"query": "x", "department_ids": ["microskills", "department-2"], "top_k": 2}
        result = self.retrieval.search(payload)
        self.assertEqual([item["id"] for item in result["results"]], ["a", "b"])
        self.assertEqual([item["metric"] for item in result["results"]], ["l2", "cosine"])
        self.assertEqual(result["warnings"][-1]["reason"], "mixed_distance_metrics_merged_by_department_rank")
        self.service.rerank_scores = [-5, 10]
        result = self.retrieval.search(dict(payload, rerank=True))
        self.assertEqual([item["id"] for item in result["results"]], ["b", "a"])
        self.assertTrue(result["reranked"])
        self.assertEqual(self.service.calls[-1][0], "tinybert")
        self.assertEqual(result["results"][0]["rerank_score"], 10)

    def test_get_returns_original_full_record_and_validates_prepared_checksum(self):
        self.add(text="Full record beyond the selected chunk", chunk="selected chunk")
        result = self.retrieval.get({"department_id": "microskills", "record_id": "chunk-a"})
        self.assertEqual(result["text"], "Full record beyond the selected chunk")
        self.assertEqual(result["record_id"], "record-a")
        self.assertEqual(result["id"], "chunk-a")
        self.assertEqual(result["metadata"]["_ingest_source_path"], "/storage/emulated/0/source-a.txt")
        self.assertEqual(self.retrieval.get({"department_id": "microskills", "record_id": "record-a"})["id"], "chunk-a")
        path = self.ingestion.department_path("microskills") / "prepared/source-a.jsonl"
        path.write_text("changed")
        with self.assertRaisesRegex(ConflictError, "checksum"):
            self.retrieval.get({"department_id": "microskills", "record_id": "chunk-a"})
        self.assertEqual(self.service.calls, [])

    def test_ambiguous_original_identity_requires_vector_identity(self):
        self.add()
        self.add(identifier="chunk-b", source_key="source-b")
        with self.assertRaisesRegex(ConflictError, "multiple sources"):
            self.retrieval.get({"department_id": "microskills", "record_id": "record-a"})
        self.assertEqual(self.retrieval.get({"department_id": "microskills", "record_id": "chunk-b"})["id"], "chunk-b")

    def test_model_identity_change_during_query_is_rejected(self):
        collection = self.add()
        collection.on_query = lambda: self.service.identity.update(model_sha256="new-model")
        with self.assertRaisesRegex(ConflictError, "assets changed"):
            self.retrieval.search({"query": "task"})

    def test_large_top_k_is_structurally_valid_and_not_arbitrarily_capped(self):
        self.add()
        result = self.retrieval.search({"query": "task", "top_k": 1000})
        self.assertEqual(result["top_k"], 1000)
        self.assertEqual(len(result["results"]), 1)

    def test_long_query_uses_complete_token_windows_and_one_normalized_pooled_vector(self):
        self.add()
        query = " ".join(["ilk"] * 700 + ["ikinci"] * 700) + "   "
        self.service.window_vector = lambda text: vector() if "ilk" in text else vector(0, 1)
        result = self.retrieval.search({"query": query})
        self.assertEqual(result["query"], query)
        prepared = result["query_preparation"]
        self.assertEqual(prepared["windows"], 3)
        self.assertEqual(prepared["input_tokens"], 1400)
        self.assertFalse(prepared["truncated"])
        calls = [payload for model, payload in self.service.calls if model == "e5"]
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0]["kind"], "query")
        self.assertEqual("".join(calls[0]["texts"]), query)
        self.assertTrue(all(len(self.service.tokenizer.encode("query: " + text).ids) <= 512 for text in calls[0]["texts"]))
        pooled, _, _ = self.retrieval.embed_query(query)
        self.assertAlmostEqual(sum(value * value for value in pooled), 1)
        self.assertAlmostEqual(pooled[0], 2 / math.sqrt(5))
        self.assertAlmostEqual(pooled[1], 1 / math.sqrt(5))

    def test_long_profiles_use_passage_windows_and_keep_query_embedding_single(self):
        self.add()
        self.add("department-2", "chunk-b", "source-b")
        self.department("department-2", name="ANDROID", description=" ".join(["android"] * 1200))
        result = self.retrieval.search({"query": "inspect android"})
        calls = [payload for model, payload in self.service.calls if model == "e5"]
        self.assertEqual(sum(payload["kind"] == "query" for payload in calls), 1)
        self.assertGreater(sum(len(payload["texts"]) for payload in calls if payload["kind"] == "passage"), 2)
        self.assertEqual(result["query_preparation"]["windows"], 1)
        self.assertTrue(all(len(self.service.tokenizer.encode(payload["kind"] + ": " + text).ids) <= 512 for payload in calls for text in payload["texts"]))

    def test_cold_query_tokenizer_and_inference_share_one_resident_runtime(self):
        calls = []

        class Runtime:
            def __init__(self, model_id, directory):
                calls.append(model_id)
                self.tokenizer = FakeTokenizer()
                self.signature = []

            def run(self, payload):
                return {"embeddings": [vector() for _ in payload["texts"]]}

        stub = types.ModuleType("model_runtime")
        stub.MODEL_SPECS = {"e5": {"name": "multilingual-e5-small", "resident": True}}
        stub.ModelRuntime = Runtime
        stub.validate_payload = lambda *args: None
        spec = importlib.util.spec_from_file_location("retrieval_runtime_test_server", Path(__file__).with_name("server.py"))
        module = importlib.util.module_from_spec(spec)
        with patch.dict(sys.modules, {"model_runtime": stub}):
            spec.loader.exec_module(module)
        service = module.SemanticService(self.root / "cold-models", self.root / "cold-data")
        service.ingestion.model_identity = lambda: copy.deepcopy(self.service.identity)
        barrier = threading.Barrier(3)
        outputs, errors = [], []

        def invoke(action):
            try:
                barrier.wait(5)
                outputs.append(action())
            except Exception as error:
                errors.append(error)

        workers = [threading.Thread(target=invoke, args=(lambda: service.resident_runtime("e5"),)), threading.Thread(target=invoke, args=(lambda: service.run("e5", {"texts": ["query"], "kind": "query"}),))]
        for worker in workers:
            worker.start()
        barrier.wait(5)
        for worker in workers:
            worker.join(5)
        self.assertEqual(errors, [])
        self.assertFalse(any(worker.is_alive() for worker in workers))
        self.assertEqual(calls, ["e5"])
        self.assertEqual(len(outputs), 2)
        self.assertIs(service.resident_runtime("e5"), service.runtimes["e5"])
        self.assertEqual(service.models["e5"]["active_count"], 0)
        self.assertEqual(sum(item["kind"] == "loaded" for item in service.events), 1)

    def test_actual_http_handler_exposes_canonical_methods_and_errors(self):
        stub = types.ModuleType("model_runtime")
        stub.MODEL_SPECS = {}
        stub.ModelRuntime = object
        stub.validate_payload = lambda *args: None
        name = "retrieval_http_test_server"
        spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name("server.py"))
        module = importlib.util.module_from_spec(spec)
        with patch.dict(sys.modules, {"model_runtime": stub}):
            spec.loader.exec_module(module)
        self.add()
        httpd = ThreadingHTTPServer(("127.0.0.1", 0), module.Handler)
        httpd.service = self.service
        thread = threading.Thread(target=httpd.serve_forever)
        thread.start()
        connection = HTTPConnection(*httpd.server_address, timeout=5)
        try:
            for endpoint in ("/rag/search", "/rag/route-and-retrieve", "/rag/route"):
                connection.request("POST", endpoint, json.dumps({"query": "task"}), {"Content-Type": "application/json"})
                response = connection.getresponse()
                value = json.loads(response.read())
                self.assertEqual(response.status, 200)
                self.assertEqual(value["routing"]["department_ids"], ["microskills"])
            connection.request("GET", "/rag/status")
            response = connection.getresponse()
            self.assertEqual(response.status, 200)
            self.assertEqual(json.loads(response.read())["departments"][0]["indexed_chunks"], 1)
            for payload, status in (({"department_id": "microskills", "record_id": "chunk-a"}, 200), ({"department_id": "microskills", "record_id": "absent"}, 404), ({"department_id": "bad", "record_id": "x"}, 400)):
                connection.request("POST", "/rag/get", json.dumps(payload))
                response = connection.getresponse()
                response.read()
                self.assertEqual(response.status, status)
            connection.request("POST", "/rag/search", "[]")
            response = connection.getresponse()
            response.read()
            self.assertEqual(response.status, 400)
        finally:
            connection.close()
            httpd.shutdown()
            thread.join(5)
            httpd.server_close()


@unittest.skipUnless(os.environ.get("RAG_REAL_CHROMA") == "1", "Set RAG_REAL_CHROMA=1 in the guest dependency environment")
class RealChromaTests(RetrievalFixture, unittest.TestCase):
    def test_real_tokenizer_window_offsets_preserve_unicode_and_prefix_budget(self):
        from tokenizers import Tokenizer
        from tokenizers.models import WordLevel
        from tokenizers.pre_tokenizers import Whitespace
        from tokenizers.processors import TemplateProcessing
        tokenizer = Tokenizer(WordLevel({"[UNK]": 0, "[CLS]": 1, "[SEP]": 2, "query": 3, ":": 4, "Türkçe": 5, "東京": 6, "🙂": 7}, unk_token="[UNK]"))
        tokenizer.pre_tokenizer = Whitespace()
        tokenizer.post_processor = TemplateProcessing(single="[CLS] $A [SEP]", special_tokens=[("[CLS]", 1), ("[SEP]", 2)])
        text = "Türkçe 東京 🙂 " * 800
        windows, prepared = token_windows(tokenizer, text, "query", 512)
        self.assertEqual("".join(windows), text)
        self.assertGreater(prepared["windows"], 1)
        self.assertTrue(all(len(tokenizer.encode("query: " + window).ids) <= 512 for window in windows))

    def test_real_temporary_chroma_query_get_and_existing_client_reuse(self):
        import chromadb
        from chromadb.config import Settings
        self.add(identifier="near", source_key="near", text="Relevant full original", chunk="Relevant chunk")
        self.add(identifier="far", source_key="far", record_id="far-record", chunk="Other chunk")
        fake = self.ingestion.collections.pop("microskills")
        directory = self.ingestion.department_path("microskills")
        client = chromadb.PersistentClient(path=str(directory), settings=Settings(anonymized_telemetry=False))
        collection = client.create_collection("documents", embedding_function=None)
        collection.upsert(ids=list(fake.rows), documents=[row["text"] for row in fake.rows.values()], metadatas=[row["metadata"] for row in fake.rows.values()], embeddings=[vector(), vector(0, 1)])
        self.ingestion.clients["microskills"] = client
        with patch.object(chromadb, "PersistentClient", side_effect=AssertionError("Must reuse ingestion client")):
            result = self.retrieval.search({"query": "test", "top_k": 2})
        self.assertEqual([item["id"] for item in result["results"]], ["near", "far"])
        self.assertEqual(result["results"][0]["metric"], "l2")
        self.assertAlmostEqual(result["results"][0]["distance"], 0.0)
        self.assertAlmostEqual(result["results"][1]["distance"], 2.0)
        self.assertEqual(self.retrieval.get({"department_id": "microskills", "record_id": "near"})["text"], "Relevant full original")
        self.assertEqual(collection.count(), 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
