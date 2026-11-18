import copy
import importlib.util
import json
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path
from unittest.mock import patch

from ingestion import ConflictError, IngestionService


class IngestionFixture:
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.models = self.root / "models"
        self.data = self.root / "data"
        self.host_root = self.root / "host-rootfs"
        self.service = IngestionService(self.models, self.data, host_root=str(self.host_root))

    def source(self, path, side="ubuntu", recursive=True):
        return {"side": side, "path": str(path), "recursive": recursive}

    def department(self, department_id="microskills"):
        return next(item for item in self.service.status()["departments"] if item["id"] == department_id)

    def prepared_files(self, department_id="microskills"):
        return sorted((self.data / "departments" / department_id / "prepared").glob("*.jsonl"))

    def prepared(self, department_id="microskills"):
        return [json.loads(line) for path in self.prepared_files(department_id) for line in path.read_text(encoding="utf-8").split("\n") if line]

    def submit(self, sources, action="ingest", department_ids=None):
        job = self.service.start_job({"action": action, "sources": sources, "department_ids": department_ids or ["microskills"]})
        return self.wait_for_job(job)

    def wait_for_job(self, job):
        deadline = time.monotonic() + 45
        while time.monotonic() < deadline:
            current = self.service.job(job["id"])
            if current["state"] not in ("queued", "running"):
                return current
            time.sleep(0.02)
        self.fail("Ingestion fixture job did not finish: " + json.dumps(self.service.job(job["id"])))

    def write_source(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return path


class IngestionConfigTests(IngestionFixture, unittest.TestCase):
    def test_six_department_defaults_and_config_copies(self):
        config = self.service.config()
        self.assertEqual(len(config["departments"]), 6)
        self.assertEqual(len({item["id"] for item in config["departments"]}), 6)
        self.assertEqual(config["departments"][0]["name"], "MICROSKILLS")
        self.assertEqual(config["tokenizer"]["id"], "e5-tokenizer")
        config["departments"][0]["name"] = "mutated copy"
        self.assertEqual(self.service.config()["departments"][0]["name"], "MICROSKILLS")

    def test_settings_revision_conflict_and_restart_persistence(self):
        stale = self.service.config()
        changed = copy.deepcopy(stale)
        changed["departments"][1].update(name="İkinci bölüm", rules=["Only a saved note"], phrases=["café"])
        saved = self.service.save_config(changed)
        self.assertEqual(saved["revision"], stale["revision"] + 1)
        with self.assertRaises(ConflictError):
            self.service.save_config(stale)
        restored = IngestionService(self.models, self.data, host_root=str(self.host_root))
        self.assertEqual(restored.config(), saved)
        self.assertEqual(saved["departments"][1]["rules"], ["Only a saved note"])
        self.assertEqual(saved["departments"][1]["phrases"], ["café"])

    def test_invalid_chunk_bounds_do_not_replace_saved_settings(self):
        original = self.service.config()
        for chunk_tokens, overlap_tokens in ((0, 0), (8, -1), (8, 8)):
            with self.subTest(chunk_tokens=chunk_tokens, overlap_tokens=overlap_tokens):
                changed = copy.deepcopy(original)
                changed["tokenizer"].update(chunk_tokens=chunk_tokens, overlap_tokens=overlap_tokens)
                with self.assertRaises(ValueError):
                    self.service.save_config(changed)
                self.assertEqual(self.service.config(), original)

    def test_concurrent_jobs_conflict_and_interrupted_jobs_are_not_replayed(self):
        source = self.source(self.root / "unused.txt")
        with patch("ingestion.threading.Thread") as thread:
            queued = self.service.start_job({"action": "ingest", "sources": [source], "department_ids": ["microskills"]})
            with self.assertRaises(ConflictError):
                self.service.start_job({"action": "preview", "sources": [source], "department_ids": ["microskills"]})
            self.assertEqual(thread.call_count, 1)
        path = self.data / "ingestion-jobs" / (queued["id"] + ".json")
        persisted = json.loads(path.read_text(encoding="utf-8"))
        persisted["state"] = "running"
        path.write_text(json.dumps(persisted), encoding="utf-8")
        with patch("ingestion.threading.Thread") as thread:
            restored = IngestionService(self.models, self.data, host_root=str(self.host_root))
            recovered = restored.job(queued["id"])
            self.assertEqual(recovered["state"], "interrupted")
            self.assertTrue(recovered["error"])
            self.assertIsNotNone(recovered["finished_at"])
            thread.assert_not_called()
        self.assertEqual(json.loads(path.read_text(encoding="utf-8"))["state"], "interrupted")

    def test_queued_job_keeps_its_original_settings_snapshot(self):
        original = self.service.config()
        with patch("ingestion.threading.Thread"):
            queued = self.service.start_job({"action": "preview", "sources": [self.source(self.root / "snapshot.txt")], "department_ids": ["microskills"]})
        changed = copy.deepcopy(original)
        changed["departments"][0].update(rules=["new note"], phrases=["new phrase"])
        changed["tokenizer"].update(chunk_tokens=16, overlap_tokens=1)
        saved = self.service.save_config(changed)
        self.assertNotEqual(saved, original)
        self.assertEqual(queued["config"], original)
        self.assertEqual(self.service.job(queued["id"])["config"], original)
        persisted = json.loads((self.data / "ingestion-jobs" / (queued["id"] + ".json")).read_text(encoding="utf-8"))
        self.assertEqual(persisted["config"], original)


@unittest.skipUnless(importlib.util.find_spec("tokenizers") and importlib.util.find_spec("chromadb"), "Real tokenizers and Chroma dependencies are required")
class IngestionIntegrationTests(IngestionFixture, unittest.TestCase):
    def collection(self, department_id="microskills"):
        import chromadb
        from chromadb.config import Settings

        return chromadb.PersistentClient(path=str(Path(self.department(department_id)["chroma_path"]).parent), settings=Settings(anonymized_telemetry=False)).get_collection("documents", embedding_function=None)

    def setUp(self):
        super().setUp()
        from tokenizers import Tokenizer
        from tokenizers.models import WordLevel
        from tokenizers.pre_tokenizers import Whitespace

        self.tokenizer = Tokenizer(WordLevel({"[UNK]": 0, "alpha": 1, "beta": 2, "gamma": 3, "delta": 4, "café": 5, "İstanbul": 6, "中文": 7, "😀": 8}, unk_token="[UNK]"))
        self.tokenizer.pre_tokenizer = Whitespace()
        path = self.models / "multilingual-e5-small" / "tokenizer.json"
        path.parent.mkdir(parents=True)
        self.tokenizer.save(str(path))
        (path.parent / "config.json").write_text('{"model_type":"bert","max_position_embeddings":512}', encoding="utf-8")
        (path.parent / "onnx").mkdir()
        (path.parent / "onnx" / "model_int8.onnx").write_bytes(b"deterministic embedding fixture")
        self.embedding_calls = []
        self.embedding_error = None

        def embed_fixture(texts):
            self.embedding_calls.append(list(texts))
            if self.embedding_error:
                raise RuntimeError(self.embedding_error)
            return [[1.0, float(len(text)), float(sum(text.encode("utf-8")) % 101), float(text.count("alpha"))] + [0.001] * 380 for text in texts]

        self.service = IngestionService(self.models, self.data, host_root=str(self.host_root), embed=embed_fixture)
        config = self.service.config()
        config["tokenizer"].update(chunk_tokens=8, overlap_tokens=2)
        self.service.save_config(config)

    def test_six_independent_chroma_stores_disable_embedding_and_stay_empty(self):
        import chromadb
        from chromadb.config import Settings

        created = []
        persistent_client = chromadb.PersistentClient

        class ObservedClient:
            def __init__(self, *args, **kwargs):
                self.client = persistent_client(*args, **kwargs)

            def __getattr__(self, name):
                return getattr(self.client, name)

            def get_or_create_collection(self, *args, **kwargs):
                created.append(dict(kwargs))
                return self.client.get_or_create_collection(*args, **kwargs)

        with patch("chromadb.PersistentClient", ObservedClient):
            status = self.service.status()
        self.assertEqual(status["mode"], "e5_embedding")
        departments = status["departments"]
        self.assertEqual(len(departments), 6)
        paths = [Path(item["chroma_path"]).resolve() for item in departments]
        self.assertEqual(len(set(paths)), 6)
        self.assertGreaterEqual(len(created), 6)
        self.assertTrue(all("embedding_function" in item and item["embedding_function"] is None for item in created))
        for department, path in zip(departments, paths):
            with self.subTest(department=department["id"]):
                self.assertTrue(department["ready"], department)
                self.assertEqual(path.name, "chroma.sqlite3")
                self.assertTrue(path.is_file())
                self.assertNotEqual(path.parent, (self.data / "chroma").resolve())
                self.assertEqual(department["prepared_records"], 0)
                self.assertEqual(department["vector_records"], 0)
                self.assertEqual(persistent_client(path=str(path.parent), settings=Settings(anonymized_telemetry=False)).get_collection("documents", embedding_function=None).count(), 0)

    def test_raw_json_records_keep_full_text_skill_codes_and_source_offsets(self):
        first = '{ "skill_code" : "MS-İ", "title": "café", "extra" : {"x": [1, 2]}, "quoted": "brace } comma ," }'
        second = '{"skill_code":"MS-2","title":"😀 中文","details":"alpha beta"}'
        original = "[\n  " + first + ",\n\t" + second + "\n]\n"
        path = self.write_source("skills.json", original)
        job = self.submit([self.source(path)])
        self.assertEqual(job["state"], "completed", job)
        self.assertTrue(self.embedding_calls)
        records = sorted(self.prepared(), key=lambda item: item["source"]["record_index"])
        self.assertEqual([item["text"] for item in records], [first, second])
        self.assertEqual([item["skill_code"] for item in records], ["MS-İ", "MS-2"])
        for record in records:
            source = record["source"]
            self.assertEqual(original[source["char_start"]:source["char_end"]], record["text"])
            self.assertEqual(original.encode("utf-8")[source["byte_start"]:source["byte_end"]].decode("utf-8"), record["text"])
            self.assertEqual(source["path"], str(path))
            self.assertEqual(source["side"], "ubuntu")
            self.assertEqual(source["bytes"], len(original.encode("utf-8")))
        self.assertEqual(self.department()["prepared_records"], 2)
        self.assertEqual(self.department()["vector_records"], self.department()["chunks"])

    def test_unicode_chunks_match_tokenizer_ids_offsets_and_overlap(self):
        text = "İstanbul café 中文 😀 alpha beta gamma delta " * 6
        path = self.write_source("unicode.txt", text)
        job = self.submit([self.source(path)])
        self.assertEqual(job["state"], "completed", job)
        record, = self.prepared()
        self.assertEqual(record["text"], text)
        encoded = self.tokenizer.encode(text, add_special_tokens=False)
        self.assertEqual(record["token_count"], len(encoded.ids))
        chunks = record["chunks"]
        self.assertGreater(len(chunks), 1)
        self.assertEqual(chunks[0]["token_start"], 0)
        self.assertEqual(chunks[-1]["token_end"], len(encoded.ids))
        for index, chunk in enumerate(chunks):
            start, end = chunk["token_start"], chunk["token_end"]
            self.assertGreater(end, start)
            self.assertLessEqual(end - start, 8)
            self.assertEqual(chunk["token_ids"], encoded.ids[start:end])
            self.assertEqual(chunk["offsets"], [list(pair) for pair in encoded.offsets[start:end]])
            self.assertEqual(chunk["text"], text[chunk["char_start"]:chunk["char_end"]])
            self.assertEqual(chunk["byte_start"], len(text[:chunk["char_start"]].encode("utf-8")))
            self.assertEqual(chunk["byte_end"], len(text[:chunk["char_end"]].encode("utf-8")))
            self.assertEqual(text.encode("utf-8")[chunk["byte_start"]:chunk["byte_end"]].decode("utf-8"), chunk["text"])
            if index:
                self.assertEqual(start, chunks[index - 1]["token_end"] - 2)

    def test_repeat_ingestion_is_idempotent_and_revisions_replace_old_records(self):
        path = self.write_source("revisions.json", '[{"skill_code":"A","text":"alpha"},{"skill_code":"B","text":"beta"}]')
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        first_records = self.prepared()
        first_files = self.prepared_files()
        first_calls = copy.deepcopy(self.embedding_calls)
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        self.assertEqual(self.prepared(), first_records)
        self.assertEqual(self.prepared_files(), first_files)
        self.assertEqual(self.embedding_calls, first_calls)
        path.write_text('[{"skill_code":"C","text":"gamma delta"}]', encoding="utf-8")
        changed = self.submit([self.source(path)])
        self.assertEqual(changed["state"], "completed", changed)
        records = self.prepared()
        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["skill_code"], "C")
        self.assertNotIn(records[0]["id"], {item["id"] for item in first_records})
        self.assertEqual(len(self.prepared_files()), 1)
        self.assertEqual(self.department()["prepared_records"], 1)
        self.assertEqual(self.department()["vector_records"], self.department()["chunks"])
        vectors = self.collection().get(include=["documents", "metadatas"])
        self.assertEqual(set(vectors["documents"]), {chunk["text"] for chunk in records[0]["chunks"]})
        self.assertEqual(len(vectors["ids"]), len(records[0]["chunks"]))

    def test_preview_preserves_existing_prepared_files_and_manifest(self):
        path = self.write_source("preview.txt", "alpha beta")
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        department = self.data / "departments" / "microskills"
        before = {str(item.relative_to(department)): item.read_bytes() for item in department.rglob("*") if item.is_file() and item.suffix in (".json", ".jsonl")}
        vector_count = self.department()["vector_records"]
        self.embedding_calls.clear()
        path.write_text("gamma delta café " * 20, encoding="utf-8")
        with patch("model_runtime.ModelRuntime.encode", side_effect=AssertionError("Preview must not encode")) as encode, patch("model_runtime.ModelRuntime.forward", side_effect=AssertionError("Preview must not run ONNX")) as forward:
            preview = self.submit([self.source(path)], action="preview")
            encode.assert_not_called()
            forward.assert_not_called()
        self.assertEqual(preview["state"], "completed", preview)
        self.assertGreater(preview["progress"]["tokens"], 2)
        self.assertEqual(self.embedding_calls, [])
        after = {str(item.relative_to(department)): item.read_bytes() for item in department.rglob("*") if item.is_file() and item.suffix in (".json", ".jsonl")}
        self.assertEqual(after, before)
        self.assertEqual(self.prepared()[0]["text"], "alpha beta")
        self.assertEqual(self.department()["vector_records"], vector_count)

    def test_failed_revision_keeps_previous_prepared_records_and_reports_failure(self):
        path = self.write_source("broken.json", '[{"skill_code":"A","text":"alpha"}]')
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        before = self.prepared()
        path.write_text('[{"skill_code":', encoding="utf-8")
        failed = self.submit([self.source(path)])
        self.assertEqual(failed["state"], "failed", failed)
        self.assertTrue(failed["error"])
        self.assertTrue(any(item["state"] == "failed" and item.get("error") for item in failed["result"]["sources"]))
        self.assertEqual(self.prepared(), before)
        restored = IngestionService(self.models, self.data, host_root=str(self.host_root))
        self.assertEqual(restored.job(failed["id"])["state"], "failed")

    def test_recursive_binary_failure_and_cycle_warning_preserve_valid_files(self):
        path = self.write_source("tree/first.txt", "alpha beta")
        self.write_source("tree/nested/second.txt", "gamma delta")
        (path.parent / "binary.bin").write_bytes(b"\x00\xff\x80binary")
        (path.parent / "nested" / "cycle").symlink_to(path.parent, target_is_directory=True)
        job = self.submit([self.source(path.parent)])
        self.assertEqual(job["state"], "failed", job)
        self.assertTrue(job["error"])
        self.assertTrue(job["result"]["warnings"])
        self.assertEqual({item["text"] for item in self.prepared()}, {"alpha beta", "gamma delta"})
        self.assertEqual(self.department()["vector_records"], self.department()["chunks"])

    def test_nonrecursive_directory_omits_nested_files(self):
        path = self.write_source("shallow/first.txt", "alpha")
        self.write_source("shallow/nested/second.txt", "beta")
        job = self.submit([self.source(path.parent, recursive=False)])
        self.assertEqual(job["state"], "completed", job)
        self.assertEqual([item["text"] for item in self.prepared()], ["alpha"])
        self.assertTrue(job["result"]["warnings"])

    def test_android_paths_preserve_original_provenance_and_selected_departments(self):
        original = "/storage/emulated/0/ingestion-fixture.json"
        path = self.host_root / original.lstrip("/")
        path.parent.mkdir(parents=True)
        path.write_text('[{"skill_code":"ANDROID","text":"café"}]', encoding="utf-8")
        selected = ["microskills", "department-3"]
        job = self.submit([self.source(original, side="android")], department_ids=selected)
        self.assertEqual(job["state"], "completed", job)
        for department_id in selected:
            record, = self.prepared(department_id)
            self.assertEqual(record["source"]["side"], "android")
            self.assertEqual(record["source"]["path"], original)
            self.assertEqual(Path(record["source"]["resolved_path"]), path)
        for department in self.service.status()["departments"]:
            self.assertEqual(department["prepared_records"], 1 if department["id"] in selected else 0)
            self.assertEqual(department["vector_records"], department["chunks"] if department["id"] in selected else 0)

    def test_embedding_failure_keeps_previous_records_and_vectors(self):
        path = self.write_source("encoder-failure.txt", "alpha beta")
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        records = self.prepared()
        collection = self.collection()
        before = collection.get(include=["documents", "embeddings"])
        path.write_text("gamma delta café " * 5, encoding="utf-8")
        self.embedding_error = "fixture encoder unavailable"
        failed = self.submit([self.source(path)])
        self.assertEqual(failed["state"], "failed", failed)
        self.assertTrue(failed["error"])
        self.assertIn("fixture encoder unavailable", json.dumps(failed["result"]))
        self.assertEqual(self.prepared(), records)
        after = collection.get(include=["documents", "embeddings"])
        self.assertEqual(after["ids"], before["ids"])
        self.assertEqual(after["documents"], before["documents"])
        self.assertEqual(after["embeddings"].tolist(), before["embeddings"].tolist())

    def test_embedding_model_change_rebuilds_unchanged_source(self):
        path = self.write_source("model-revision.txt", "alpha beta gamma")
        self.assertEqual(self.submit([self.source(path)])["state"], "completed")
        first_calls = len(self.embedding_calls)
        first_files = self.prepared_files()
        model = self.models / "multilingual-e5-small" / "onnx" / "model_int8.onnx"
        model.write_bytes(b"different deterministic embedding fixture")
        rebuilt = self.submit([self.source(path)])
        self.assertEqual(rebuilt["state"], "completed", rebuilt)
        self.assertGreater(len(self.embedding_calls), first_calls)
        self.assertNotEqual(self.prepared_files(), first_files)
        self.assertEqual(len(self.prepared_files()), 1)
        self.assertEqual(self.prepared()[0]["text"], "alpha beta gamma")
        self.assertEqual(self.department()["vector_records"], self.department()["chunks"])

    def test_preview_works_without_encoder_assets(self):
        path = self.write_source("preview-only.txt", "İstanbul café alpha beta")
        model = self.models / "multilingual-e5-small"
        (model / "config.json").unlink()
        (model / "onnx" / "model_int8.onnx").unlink()
        job = self.submit([self.source(path)], action="preview")
        self.assertEqual(job["state"], "completed", job)
        self.assertEqual(self.embedding_calls, [])
        self.assertEqual(self.prepared_files(), [])
        self.assertEqual(self.department()["vector_records"], 0)

    def test_vectors_persist_for_a_fresh_python_process(self):
        path = self.write_source("persistent.txt", "alpha beta gamma delta " * 5)
        job = self.submit([self.source(path)])
        self.assertEqual(job["state"], "completed", job)
        department = self.department()
        command = "import chromadb,json,sys; collection=chromadb.PersistentClient(path=sys.argv[1]).get_collection('documents',embedding_function=None); result=collection.get(include=['embeddings']); print(json.dumps({'count':collection.count(),'dimensions':[len(vector) for vector in result['embeddings']]}))"
        result = subprocess.run([sys.executable, "-c", command, str(Path(department["chroma_path"]).parent)], check=True, text=True, capture_output=True, timeout=45)
        observed = json.loads(result.stdout)
        self.assertEqual(observed["count"], department["chunks"])
        self.assertGreater(observed["count"], 0)
        self.assertEqual(observed["dimensions"], [384] * observed["count"])

    def test_scalar_metadata_retains_json_types_and_namespaced_provenance(self):
        item = {"skill_code": "MS-plain", "enabled": True, "weight": 1.25, "rank": 3, "source_key": "user-key", "path": "user-path", "text": "alpha\u2028beta", "nested": {"value": 2}}
        path = self.write_source("metadata.json", json.dumps([item], ensure_ascii=False))
        job = self.submit([self.source(path)])
        self.assertEqual(job["state"], "completed", job)
        records = self.prepared()
        self.assertEqual(len(records), 1)
        metadatas = self.collection().get(include=["metadatas"])["metadatas"]
        self.assertTrue(metadatas)
        for metadata in metadatas:
            for key in ("skill_code", "enabled", "weight", "rank", "source_key", "path", "text"):
                self.assertEqual(metadata[key], item[key])
                self.assertIs(type(metadata[key]), type(item[key]))
            self.assertEqual(metadata["_ingest_source_path"], str(path))
            self.assertEqual(metadata["_ingest_source_key"], records[0]["source"]["key"])

    def test_chroma_write_failure_persists_pending_state_and_explicit_retry_recovers(self):
        path = self.write_source("pending.txt", "alpha beta gamma")
        collection = self.collection()
        with patch.object(type(collection), "upsert", side_effect=RuntimeError("fixture write unavailable")):
            failed = self.submit([self.source(path)])
        self.assertEqual(failed["state"], "failed", failed)
        self.assertTrue(failed["error"])
        self.assertIn("fixture write unavailable", json.dumps(failed["result"]))
        department = self.department()
        self.assertFalse(department["ready"])
        self.assertEqual(department["pending_sources"], 1)
        self.assertEqual(department["indexed_sources"], 0)
        self.assertEqual(department["vector_records"], 0)
        restored = IngestionService(self.models, self.data, host_root=str(self.host_root))
        persisted = next(item for item in restored.status()["departments"] if item["id"] == "microskills")
        self.assertEqual(persisted["pending_sources"], 1)
        self.assertFalse(persisted["ready"])
        retried = self.submit([self.source(path)])
        self.assertEqual(retried["state"], "completed", retried)
        recovered = self.department()
        self.assertTrue(recovered["ready"], recovered)
        self.assertEqual(recovered["pending_sources"], 0)
        self.assertEqual(recovered["indexed_sources"], 1)
        self.assertEqual(recovered["vector_records"], recovered["chunks"])

    def test_status_remains_responsive_during_a_pending_chroma_write(self):
        path = self.write_source("responsive.txt", "alpha beta gamma")
        collection = self.collection()
        original_upsert = type(collection).upsert
        entered, release, finished = threading.Event(), threading.Event(), threading.Event()
        snapshots = []
        reader = None

        def blocked_upsert(instance, *args, **kwargs):
            entered.set()
            if not release.wait(15):
                raise RuntimeError("Fixture Chroma write was not released")
            return original_upsert(instance, *args, **kwargs)

        def read_status():
            try:
                snapshots.append(self.service.status())
            finally:
                finished.set()

        with patch.object(type(collection), "upsert", blocked_upsert):
            job = self.service.start_job({"action": "ingest", "sources": [self.source(path)], "department_ids": ["microskills"]})
            try:
                self.assertTrue(entered.wait(10), self.service.job(job["id"]))
                reader = threading.Thread(target=read_status, daemon=True)
                reader.start()
                self.assertTrue(finished.wait(3), "Status blocked behind a pending Chroma write")
                pending = next(item for item in snapshots[0]["departments"] if item["id"] == "microskills")
                self.assertFalse(pending["ready"])
                self.assertEqual(pending["pending_sources"], 1)
            finally:
                release.set()
                completed = self.wait_for_job(job)
                if reader:
                    reader.join(10)
        self.assertEqual(completed["state"], "completed", completed)

    def test_http_config_conflicts_job_lookup_and_preview_routes(self):
        from http.server import ThreadingHTTPServer
        from urllib.error import HTTPError
        from urllib.request import Request, urlopen

        from server import Handler, SemanticService

        httpd = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        httpd.service = SemanticService(self.models, self.data)
        httpd.service.ingestion = self.service
        thread = threading.Thread(target=httpd.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(httpd.server_close)
        self.addCleanup(thread.join, 5)
        self.addCleanup(httpd.shutdown)
        base = "http://127.0.0.1:" + str(httpd.server_port)

        def request(route, body=None):
            data = None if body is None else json.dumps(body).encode("utf-8")
            message = Request(base + route, data=data, headers={"Content-Type": "application/json"})
            try:
                response = urlopen(message, timeout=10)
            except HTTPError as error:
                response = error
            with response:
                return response.status, json.load(response)

        status, config = request("/ingest/config")
        self.assertEqual(status, 200)
        changed = copy.deepcopy(config)
        changed["departments"][0]["name"] = "Fixture department"
        self.assertEqual(request("/ingest/config", changed)[0], 200)
        self.assertEqual(request("/ingest/config", config)[0], 409)
        self.assertEqual(request("/ingest/jobs?id=missing-job")[0], 404)
        path = self.write_source("http-preview.txt", "alpha café beta")
        status, accepted = request("/ingest/jobs", {"action": "preview", "sources": [self.source(path)], "department_ids": ["microskills"]})
        self.assertEqual(status, 202)
        job = accepted["job"]
        deadline = time.monotonic() + 10
        while job["state"] in ("queued", "running") and time.monotonic() < deadline:
            status, result = request("/ingest/jobs?id=" + job["id"])
            self.assertEqual(status, 200)
            job = result["job"]
            time.sleep(0.02)
        self.assertEqual(job["state"], "completed", job)
        self.assertEqual(self.embedding_calls, [])
        self.assertEqual(self.prepared_files(), [])

    def test_ingestion_reuses_resident_e5_and_rejects_changed_assets_without_revoking_health(self):
        from server import SemanticService

        owner = SemanticService(self.models, self.data)
        self.service = owner.ingestion
        with patch("server.ModelRuntime") as constructor:
            runtime = constructor.return_value
            runtime.signature = {"fixture": True}
            runtime.run.side_effect = lambda payload: {"embeddings": [[1.0] + [0.001] * 383 for text in payload["texts"]], "dimensions": 384}
            owner.run("e5", {"texts": ["alpha"], "kind": "passage"})
            initial_cursor = owner.cursor
            path = self.write_source("resident.txt", "alpha beta gamma " * 4)
            completed = self.submit([self.source(path)])
            self.assertEqual(completed["state"], "completed", completed)
            constructor.assert_called_once_with("e5", self.models)
            self.assertGreater(runtime.run.call_count, 1)
            events = [item for item in owner.events if item["seq"] > initial_cursor and item["model_id"] == "e5"]
            self.assertTrue(any(item["kind"] == "start" for item in events))
            self.assertEqual(sum(item["kind"] == "start" for item in events), sum(item["kind"] == "end" for item in events))
            self.assertEqual(owner.models["e5"]["active_count"], 0)
            self.assertTrue(owner.models["e5"]["ready"])
            calls = runtime.run.call_count
            cursor = owner.cursor
            (self.models / "multilingual-e5-small" / "onnx" / "model_int8.onnx").write_bytes(b"changed after resident runtime load")
            rejected = self.submit([self.source(path)])
            self.assertEqual(rejected["state"], "failed", rejected)
            self.assertIn("Loaded E5 assets differ", json.dumps(rejected["result"]))
            self.assertEqual(runtime.run.call_count, calls)
            self.assertEqual(owner.cursor, cursor)
            self.assertTrue(owner.models["e5"]["ready"])
            self.assertIsNone(owner.models["e5"]["last_error"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
