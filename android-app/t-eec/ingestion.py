import copy
import hashlib
import json
import math
import os
import stat
import tempfile
import threading
import time
import uuid
from pathlib import Path


DEPARTMENT_IDS = ("microskills", "department-2", "department-3", "department-4", "department-5", "department-6")


class ConflictError(Exception):
    pass


def digest(value):
    return hashlib.sha256(value).hexdigest()


def file_digest(path):
    value = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for part in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(part)
    return value.hexdigest()


def encoded(value):
    return json.dumps(value, ensure_ascii=False, allow_nan=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def atomic_write(path, content):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix="." + path.name + ".", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(content)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
        directory = os.open(str(path.parent), os.O_RDONLY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def default_config():
    return {"schema": "t-eec.ingest-config/1", "revision": 1,
            "tokenizer": {"id": "e5-tokenizer", "chunk_tokens": 256, "overlap_tokens": 0},
            "sources": [{"id": "microskills-file", "side": "android", "path": "/storage/emulated/0/micro_skills_real.json", "recursive": True}],
            "departments": [{"id": key, "name": "MICROSKILLS" if index == 0 else "Departman " + str(index + 1), "rules": [], "phrases": []} for index, key in enumerate(DEPARTMENT_IDS)]}


def validate_sources(sources):
    if not isinstance(sources, list) or not sources:
        raise ValueError("sources must contain at least one source")
    for source in sources:
        if not isinstance(source, dict) or source.get("side") not in ("android", "ubuntu"):
            raise ValueError("Every source requires side android or ubuntu")
        path = source.get("path")
        if not isinstance(path, str) or not path.startswith("/") or "\x00" in path:
            raise ValueError("Every source requires an absolute path without NUL")
        if "recursive" in source and not isinstance(source["recursive"], bool):
            raise ValueError("recursive must be a boolean")
        if "id" in source and not isinstance(source["id"], str):
            raise ValueError("source id must be text")
    return copy.deepcopy(sources)


def validate_config(value):
    if not isinstance(value, dict) or value.get("schema") != "t-eec.ingest-config/1":
        raise ValueError("Unsupported ingestion config schema")
    if type(value.get("revision")) is not int or value["revision"] < 1:
        raise ValueError("revision must be a positive integer")
    tokenizer = value.get("tokenizer", {})
    if not isinstance(tokenizer, dict) or tokenizer.get("id") != "e5-tokenizer":
        raise ValueError("Only e5-tokenizer is configured")
    size, overlap = tokenizer.get("chunk_tokens"), tokenizer.get("overlap_tokens")
    if type(size) is not int or size < 1 or type(overlap) is not int or overlap < 0 or overlap >= size:
        raise ValueError("chunk_tokens must be positive and 0 <= overlap_tokens < chunk_tokens")
    validate_sources(value.get("sources"))
    departments = value.get("departments")
    if not isinstance(departments, list) or len(departments) != 6 or any(not isinstance(item, dict) for item in departments):
        raise ValueError("Exactly six departments are required")
    if [item.get("id") for item in departments] != list(DEPARTMENT_IDS):
        raise ValueError("Department identities and order must be preserved")
    for item in departments:
        if not isinstance(item.get("name"), str) or not item["name"].strip():
            raise ValueError("Department names must be nonempty text")
        for key in ("rules", "phrases"):
            if not isinstance(item.get(key), list) or any(not isinstance(text, str) for text in item[key]):
                raise ValueError(key + " must be an array of user text")
    encoded(value)
    return copy.deepcopy(value)


def byte_offsets(text):
    offsets = [0]
    for character in text:
        offsets.append(offsets[-1] + len(character.encode("utf-8")))
    return offsets


def record_spans(text, suffix):
    decoder = json.JSONDecoder(parse_constant=lambda value: (_ for _ in ()).throw(ValueError("Invalid JSON constant: " + value)))
    if suffix in (".jsonl", ".ndjson"):
        position = 0
        for number, line in enumerate(text.split("\n"), 1):
            start = position + len(line) - len(line.lstrip(" \t\r\n"))
            if number == 1 and line.startswith("\ufeff"):
                start += 1
                while start < len(text) and text[start] in " \t\r":
                    start += 1
            if line.strip(" \t\r\n"):
                try:
                    value, end = decoder.raw_decode(text, start)
                    if end > position + len(line) or text[end:position + len(line)].strip(" \t\r\n"):
                        raise ValueError("Unexpected trailing content")
                except ValueError as error:
                    raise ValueError("Malformed JSONL line " + str(number) + ": " + str(error)) from error
                yield start, end, value
            position += len(line) + 1
        return
    if suffix != ".json":
        yield 0, len(text), None
        return
    position = 1 if text.startswith("\ufeff") else 0
    while position < len(text) and text[position] in " \t\r\n":
        position += 1
    if position >= len(text):
        raise ValueError("Empty JSON source")
    if text[position] != "[":
        value, end = decoder.raw_decode(text, position)
        if text[end:].strip(" \t\r\n"):
            raise ValueError("Unexpected content after JSON value")
        yield position, end, value
        return
    position += 1
    while position < len(text) and text[position] in " \t\r\n":
        position += 1
    if position < len(text) and text[position] == "]":
        if text[position + 1:].strip(" \t\r\n"):
            raise ValueError("Unexpected content after JSON array")
        return
    while True:
        value, end = decoder.raw_decode(text, position)
        yield position, end, value
        position = end
        while position < len(text) and text[position] in " \t\r\n":
            position += 1
        if position < len(text) and text[position] == "]":
            if text[position + 1:].strip(" \t\r\n"):
                raise ValueError("Unexpected content after JSON array")
            return
        if position >= len(text) or text[position] != ",":
            raise ValueError("Expected comma or closing bracket in JSON array")
        position += 1
        while position < len(text) and text[position] in " \t\r\n":
            position += 1


def prepare_records(source, tokenizer, options):
    path = Path(source["resolved_path"])
    with path.open("rb") as handle:
        before = os.fstat(handle.fileno())
        raw = handle.read()
        after = os.fstat(handle.fileno())
    if (before.st_size, before.st_mtime_ns, before.st_ino) != (after.st_size, after.st_mtime_ns, after.st_ino):
        raise ValueError("Source changed while being read")
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ValueError("Source is not valid UTF-8 text: " + str(error)) from error
    if any(ord(character) < 32 and character not in "\t\n\r\f" for character in text):
        raise ValueError("Binary/control bytes in source")
    source_hash = digest(raw)
    source_key = digest(encoded({"side": source["side"], "path": source["path"]}))
    source_bytes = byte_offsets(text)
    records, identities = [], set()
    for index, (start, end, value) in enumerate(record_spans(text, path.suffix.lower())):
        content = text[start:end]
        skill_code = value.get("skill_code") if isinstance(value, dict) else None
        identity = [source_key, "skill_code", skill_code] if skill_code is not None else [source_key, "record_index", index]
        record_id = digest(encoded(identity))
        if record_id in identities:
            raise ValueError("Duplicate skill_code in source: " + str(skill_code))
        identities.add(record_id)
        tokens = tokenizer.encode(content, add_special_tokens=False)
        offsets = [list(pair) for pair in tokens.offsets]
        if len(tokens.ids) != len(offsets) or any(not 0 <= first <= last <= len(content) for first, last in offsets):
            raise ValueError("Tokenizer returned invalid Unicode character offsets")
        content_bytes = byte_offsets(content)
        chunks = []
        size, overlap = options["chunk_tokens"], options["overlap_tokens"]
        for first in range(0, len(tokens.ids), size - overlap):
            last = min(first + size, len(tokens.ids))
            char_start = 0 if first == 0 else min(pair[0] for pair in offsets[first:last])
            char_end = len(content) if last == len(tokens.ids) else max(max(pair[1] for pair in offsets[first:last]), offsets[last][0])
            chunks.append({"index": len(chunks), "token_start": first, "token_end": last, "token_ids": tokens.ids[first:last], "offsets": offsets[first:last], "char_start": char_start, "char_end": char_end, "byte_start": content_bytes[char_start], "byte_end": content_bytes[char_end], "text": content[char_start:char_end]})
            if last == len(tokens.ids):
                break
        provenance = dict(source, key=source_key, sha256=source_hash, bytes=len(raw), char_start=start, char_end=end, byte_start=source_bytes[start], byte_end=source_bytes[end], record_index=index)
        metadata = {key: item for key, item in value.items() if isinstance(item, (str, bool, int)) or isinstance(item, float) and math.isfinite(item)} if isinstance(value, dict) else {}
        records.append({"id": record_id, "skill_code": skill_code, "text": content, "source": provenance, "metadata": metadata, "token_count": len(tokens.ids), "chunks": chunks})
    summary = dict(source, key=source_key, sha256=source_hash, bytes=len(raw), records=len(records), chunks=sum(len(item["chunks"]) for item in records), tokens=sum(item["token_count"] for item in records))
    return records, summary


class IngestionService:
    def __init__(self, models_dir, data_dir, host_root="/host-rootfs", embed=None, check_embedding=None):
        self.models_dir = Path(models_dir)
        self.data_dir = Path(data_dir)
        self.host_root = Path(host_root)
        self.embed = embed
        self.check_embedding = check_embedding
        self.identity_cache = {}
        self.settings_path = self.data_dir / "ingestion-settings.json"
        self.jobs_dir = self.data_dir / "ingestion-jobs"
        self.jobs_dir.mkdir(parents=True, exist_ok=True)
        self.lock = threading.RLock()
        self.store_lock = threading.RLock()
        self.clients = {}
        self.collections = {}
        self.jobs = {}
        self.recovery_errors = []
        if self.settings_path.exists():
            self.settings = validate_config(json.loads(self.settings_path.read_text(encoding="utf-8")))
        else:
            self.settings = default_config()
            atomic_write(self.settings_path, encoded(self.settings))
        for path in sorted(self.jobs_dir.glob("*.json")):
            try:
                job = json.loads(path.read_text(encoding="utf-8"))
                if not isinstance(job, dict) or job.get("id") != path.stem or job.get("state") not in ("queued", "running", "completed", "failed", "interrupted"):
                    raise ValueError("Invalid persisted job")
                if job["state"] in ("queued", "running"):
                    job.update(state="interrupted", finished_at=time.time(), error="Service restarted before this job completed; it was not replayed")
                    atomic_write(path, encoded(job))
                self.jobs[job["id"]] = job
            except Exception as error:
                self.recovery_errors.append({"path": str(path), "error": str(error)})

    def config(self):
        with self.lock:
            return copy.deepcopy(self.settings)

    def save_config(self, payload):
        value = validate_config(payload)
        with self.lock:
            if value["revision"] != self.settings["revision"]:
                raise ConflictError("Settings revision conflict; reload current settings")
            value["revision"] += 1
            atomic_write(self.settings_path, encoded(value))
            self.settings = value
            return copy.deepcopy(value)

    def department_path(self, key):
        if key not in DEPARTMENT_IDS:
            raise ValueError("Unknown department: " + str(key))
        return self.data_dir / "departments" / key

    def collection(self, key):
        with self.store_lock:
            if key not in self.clients:
                import chromadb
                from chromadb.config import Settings
                client = chromadb.PersistentClient(path=str(self.department_path(key)), settings=Settings(anonymized_telemetry=False))
                collection = client.get_or_create_collection("documents", embedding_function=None)
                self.clients[key] = client
                self.collections[key] = collection
            return self.collections[key]

    def manifest(self, key):
        path = self.department_path(key) / "manifest.json"
        if not path.exists():
            return {"schema": "t-eec.prepared-manifest/1", "sources": {}, "pending": {}, "last_error": None}
        value = json.loads(path.read_text(encoding="utf-8"))
        if value.get("schema") != "t-eec.prepared-manifest/1" or not isinstance(value.get("sources"), dict):
            raise ValueError("Invalid department manifest: " + key)
        value.setdefault("pending", {})
        return value

    def status(self):
        config = self.config()
        departments = []
        with self.store_lock:
            for item in config["departments"]:
                entry = {"id": item["id"], "name": item["name"], "chroma_path": str(self.department_path(item["id"]) / "chroma.sqlite3"), "ready": False, "prepared_records": 0, "chunks": 0, "tokens": 0, "vector_records": 0, "bytes": 0, "last_ingested_at": None, "last_error": None, "pending_sources": 0, "indexed_sources": 0, "prepared_sources": 0}
                try:
                    entry["vector_records"] = self.collection(item["id"]).count()
                    manifest = self.manifest(item["id"])
                    values = list(manifest["sources"].values())
                    for public, stored in (("prepared_records", "records"), ("chunks", "chunks"), ("tokens", "tokens"), ("bytes", "bytes")):
                        entry[public] = sum(source[stored] for source in values)
                    entry["last_ingested_at"] = max((source["last_ingested_at"] for source in values), default=None)
                    entry["last_error"] = manifest.get("last_error")
                    entry["pending_sources"] = len(manifest["pending"])
                    entry["indexed_sources"] = sum(source.get("state") == "indexed" for source in values)
                    entry["prepared_sources"] = len(set(manifest["sources"]) | set(manifest["pending"]))
                    entry["pending_records"] = sum(source["records"] for source in manifest["pending"].values())
                    entry["ready"] = not manifest["pending"]
                    if manifest["pending"] and not entry["last_error"]:
                        entry["last_error"] = "Indexing was interrupted or is in progress; pending sources require explicit re-ingestion"
                except Exception as error:
                    entry["last_error"] = type(error).__name__ + ": " + str(error)
                departments.append(entry)
        with self.lock:
            jobs = copy.deepcopy(sorted(self.jobs.values(), key=lambda item: item["created_at"], reverse=True)[:20])
            return {"mode": "e5_embedding", "tokenizer": dict(config["tokenizer"], path=str(self.models_dir / "multilingual-e5-small" / "tokenizer.json")), "departments": departments, "jobs": jobs, "job_count": len(self.jobs), "active_jobs": sum(item["state"] in ("queued", "running") for item in self.jobs.values()), "paths": {"service": str(Path(__file__).parent), "settings": str(self.settings_path), "data": str(self.data_dir)}, "recovery_errors": copy.deepcopy(self.recovery_errors)}

    def job(self, key):
        with self.lock:
            if key not in self.jobs:
                raise KeyError("Unknown ingestion job: " + str(key))
            return copy.deepcopy(self.jobs[key])

    def persist_job(self, job):
        atomic_write(self.jobs_dir / (job["id"] + ".json"), encoded(job))

    def publish_job(self, job):
        with self.lock:
            self.persist_job(job)
            self.jobs[job["id"]] = copy.deepcopy(job)

    def start_job(self, payload):
        if not isinstance(payload, dict) or payload.get("action") not in ("preview", "ingest"):
            raise ValueError("action must be preview or ingest")
        with self.lock:
            sources = validate_sources(payload.get("sources", self.settings["sources"]))
            selected = payload.get("department_ids")
            if not isinstance(selected, list) or not selected or any(key not in DEPARTMENT_IDS for key in selected) or len(set(selected)) != len(selected):
                raise ValueError("department_ids must select one or more unique departments")
            if any(job["state"] in ("queued", "running") for job in self.jobs.values()):
                raise ConflictError("Another ingestion or preview job is active")
            job = {"id": uuid.uuid4().hex, "action": payload["action"], "state": "queued", "created_at": time.time(), "finished_at": None, "sources": sources, "department_ids": copy.deepcopy(selected), "config": copy.deepcopy(self.settings), "progress": {"files": 0, "records": 0, "chunks": 0, "tokens": 0}, "result": {"sources": [], "departments": [], "samples": [], "warnings": []}, "error": None}
            self.persist_job(job)
            self.jobs[job["id"]] = job
            try:
                threading.Thread(target=self._execute, args=(job["id"],), name="semantic-ingest-" + job["id"], daemon=True).start()
            except Exception as error:
                job.update(state="failed", finished_at=time.time(), error=str(error))
                self.persist_job(job)
            return copy.deepcopy(job)

    def discover(self, sources):
        files, errors, warnings = [], [], []
        visited, seen_files = set(), set()

        def visit(side, original, actual, recursive):
            context = {"side": side, "path": original, "resolved_path": str(actual)}
            try:
                info = actual.stat()
                if stat.S_ISDIR(info.st_mode):
                    identity = (info.st_dev, info.st_ino)
                    if identity in visited:
                        warnings.append(dict(context, warning="Directory cycle or duplicate directory skipped"))
                        return
                    visited.add(identity)
                    for child in sorted(actual.iterdir(), key=lambda path: path.name):
                        child_original = os.path.join(original, child.name)
                        if child.is_dir() and not recursive:
                            warnings.append({"side": side, "path": child_original, "warning": "Subdirectory skipped because recursive is false"})
                        else:
                            visit(side, child_original, child, recursive)
                elif stat.S_ISREG(info.st_mode):
                    identity = (side, original)
                    if identity in seen_files:
                        warnings.append(dict(context, warning="Duplicate source path skipped"))
                    else:
                        seen_files.add(identity)
                        files.append(context)
                else:
                    raise ValueError("Source is not a regular file or directory")
            except Exception as error:
                errors.append(dict(context, state="failed", error=type(error).__name__ + ": " + str(error)))

        for source in sources:
            original = os.path.normpath(source["path"])
            actual = self.host_root / original.lstrip("/") if source["side"] == "android" else Path(original)
            visit(source["side"], original, actual, source.get("recursive", True))
        return files, errors, warnings

    def fingerprint(self, summary, tokenizer_snapshot, embedding_snapshot):
        return digest(encoded({"schema": "t-eec.indexed/1", "sha256": summary["sha256"], "tokenizer": tokenizer_snapshot, "embedding": embedding_snapshot}))

    def already_indexed(self, key, summary, fingerprint):
        with self.store_lock:
            manifest = self.manifest(key)
            prior = manifest["sources"].get(summary["key"])
            if not prior or summary["key"] in manifest["pending"] or prior.get("state") != "indexed" or prior.get("fingerprint") != fingerprint:
                return False
            prepared = self.department_path(key) / prior["prepared_file"]
            if not prepared.is_file() or file_digest(prepared) != prior.get("prepared_sha256"):
                return False
            actual = self.collection(key).get(where={"_ingest_source_key": summary["key"]}, include=[])["ids"]
            return set(actual) == set(prior.get("vector_ids", []))

    def commit_source(self, key, records, summary, tokenizer_snapshot, embedding_snapshot, vectors, job):
        collection = self.collection(key)
        manifest = self.manifest(key)
        fingerprint = self.fingerprint(summary, tokenizer_snapshot, embedding_snapshot)
        prior = manifest["sources"].get(summary["key"])
        directory = self.department_path(key)
        if self.already_indexed(key, summary, fingerprint):
            return dict(prior, state="unchanged")
        filename = "prepared/" + summary["key"] + "-" + fingerprint + ".jsonl"
        prepared_bytes = b"".join(encoded(record) + b"\n" for record in records)
        atomic_write(directory / filename, prepared_bytes)
        items = [(record, chunk) for record in records for chunk in record["chunks"]]
        ids = [digest(encoded([summary["key"], fingerprint, record["id"], chunk["index"]])) for record, chunk in items]
        value = dict(summary, prepared_file=filename, prepared_sha256=digest(prepared_bytes), fingerprint=fingerprint, tokenizer=tokenizer_snapshot, embedding=embedding_snapshot, job_id=job["id"], config_revision=job["config"]["revision"], last_ingested_at=time.time(), vector_ids=ids, state="pending")
        manifest["pending"][summary["key"]] = value
        atomic_write(directory / "manifest.json", encoded(manifest))
        old_ids = collection.get(where={"_ingest_source_key": summary["key"]}, include=[])["ids"]
        for first in range(0, len(items), 8):
            batch = items[first:first + 8]
            metadata = [dict(record["metadata"], _ingest_source_key=summary["key"], _ingest_source_side=summary["side"], _ingest_source_path=summary["path"], _ingest_source_sha256=summary["sha256"], _ingest_record_id=record["id"], _ingest_chunk_index=chunk["index"], _ingest_source_byte_start=record["source"]["byte_start"] + chunk["byte_start"], _ingest_source_byte_end=record["source"]["byte_start"] + chunk["byte_end"], _ingest_fingerprint=fingerprint) for record, chunk in batch]
            collection.upsert(ids=ids[first:first + 8], embeddings=vectors[first:first + 8], documents=[chunk["text"] for record, chunk in batch], metadatas=metadata)
        stale = sorted(set(old_ids) - set(ids))
        for first in range(0, len(stale), 256):
            collection.delete(ids=stale[first:first + 256])
        actual = collection.get(where={"_ingest_source_key": summary["key"]}, include=[])["ids"]
        if set(actual) != set(ids):
            raise RuntimeError("Source vector IDs differ after persistence")
        value["state"] = "indexed"
        manifest["sources"][summary["key"]] = value
        manifest["pending"].pop(summary["key"], None)
        manifest["last_error"] = None
        atomic_write(directory / "manifest.json", encoded(manifest))
        for obsolete in (directory / "prepared").glob(summary["key"] + "-*.jsonl"):
            if obsolete != directory / filename:
                obsolete.unlink(missing_ok=True)
        return value

    def embedding_snapshot(self):
        path = self.models_dir / "multilingual-e5-small"
        config_path = path / "config.json"
        config = json.loads(config_path.read_text(encoding="utf-8"))
        limit = config.get("max_position_embeddings", 512)
        if type(limit) is not int or limit < 1:
            raise ValueError("Invalid E5 maximum token length")
        return {"id": "e5", "kind": "passage", "normalization": "mean_pool_l2", "model_sha256": self.asset_digest(path / "onnx" / "model_int8.onnx"), "config_sha256": self.asset_digest(config_path), "max_tokens": min(limit, 512)}

    def asset_digest(self, path):
        with self.lock:
            info = path.stat()
            signature = (info.st_dev, info.st_ino, info.st_size, info.st_mtime_ns, info.st_ctime_ns)
            cached = self.identity_cache.get(str(path))
            if cached and cached[0] == signature:
                return cached[1]
            value = file_digest(path)
            after = path.stat()
            if signature != (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns, after.st_ctime_ns):
                raise ValueError("Model asset changed while computing identity: " + str(path))
            self.identity_cache[str(path)] = (signature, value)
            return value

    def model_identity(self):
        return dict(self.embedding_snapshot(), tokenizer_sha256=self.asset_digest(self.models_dir / "multilingual-e5-small" / "tokenizer.json"))

    def embed_records(self, records, tokenizer, snapshot, job):
        texts = [chunk["text"] for record in records for chunk in record["chunks"]]
        if any(len(tokenizer.encode("passage: " + text).ids) > snapshot["max_tokens"] for text in texts):
            raise ValueError("Chunk exceeds E5 token limit with passage prefix and special tokens; reduce chunk_tokens")
        if self.embed is None:
            raise RuntimeError("E5 embedding callback is unavailable")
        vectors = []
        for first in range(0, len(texts), 8):
            expected = dict(snapshot, tokenizer_sha256=job["tokenizer_snapshot"]["sha256"])
            if expected != self.model_identity():
                raise ValueError("Model assets changed after the job snapshot; start a new job")
            if self.check_embedding is not None:
                self.check_embedding(expected)
            batch = self.embed(texts[first:first + 8])
            if self.check_embedding is not None:
                self.check_embedding(expected)
            if not isinstance(batch, list) or len(batch) != len(texts[first:first + 8]) or any(not isinstance(vector, list) or len(vector) != 384 or not any(vector) or any(not isinstance(number, (float, int)) or not math.isfinite(number) for number in vector) for vector in batch):
                raise ValueError("E5 returned invalid embeddings")
            vectors.extend(batch)
            job["progress"]["embedded_chunks"] = job["progress"].get("embedded_chunks", 0) + len(batch)
            self.publish_job(job)
        return vectors

    def record_department_error(self, key, error):
        with self.store_lock:
            manifest = self.manifest(key)
            manifest["last_error"] = error
            atomic_write(self.department_path(key) / "manifest.json", encoded(manifest))

    def _execute(self, key):
        with self.lock:
            job = copy.deepcopy(self.jobs[key])
            job["state"] = "running"
        try:
            self.publish_job(job)
            from tokenizers import Tokenizer
            tokenizer_path = self.models_dir / "multilingual-e5-small" / "tokenizer.json"
            tokenizer_hash = digest(tokenizer_path.read_bytes())
            tokenizer = Tokenizer.from_file(str(tokenizer_path))
            tokenizer.no_padding()
            tokenizer.no_truncation()
            if tokenizer_hash != digest(tokenizer_path.read_bytes()):
                raise ValueError("Tokenizer changed while loading")
            tokenizer_snapshot = dict(job["config"]["tokenizer"], sha256=tokenizer_hash, add_special_tokens=False, padding=False, truncation=False)
            job["tokenizer_snapshot"] = tokenizer_snapshot
            embedding_snapshot = self.embedding_snapshot() if job["action"] == "ingest" else None
            job["embedding_snapshot"] = embedding_snapshot
            if embedding_snapshot and tokenizer_snapshot["chunk_tokens"] + len(tokenizer.encode("passage: ").ids) > embedding_snapshot["max_tokens"]:
                raise ValueError("chunk_tokens leaves no room for E5 passage prefix and special tokens")
            files, failures, warnings = self.discover(job["sources"])
            job["result"]["sources"].extend(failures)
            job["result"]["warnings"].extend(warnings)
            department_results = {department: {"id": department, "records": 0, "chunks": 0, "tokens": 0, "sources": [], "errors": []} for department in job["department_ids"]}
            if job["action"] == "ingest":
                for department in DEPARTMENT_IDS:
                    try:
                        self.collection(department)
                    except Exception as error:
                        warnings.append({"department_id": department, "error": "Could not initialize Chroma: " + str(error)})
                job["result"]["warnings"] = warnings
            for source in files:
                try:
                    records, summary = prepare_records(source, tokenizer, tokenizer_snapshot)
                    vectors = None
                    if job["action"] == "ingest":
                        fingerprint = self.fingerprint(summary, tokenizer_snapshot, embedding_snapshot)
                        if any(not self.already_indexed(department, summary, fingerprint) for department in job["department_ids"]):
                            vectors = self.embed_records(records, tokenizer, embedding_snapshot, job)
                    destinations = []
                    for department in job["department_ids"]:
                        result = department_results[department]
                        try:
                            stored = self.commit_source(department, records, summary, tokenizer_snapshot, embedding_snapshot, vectors, job) if job["action"] == "ingest" else dict(summary, state="previewed")
                            result["sources"].append({"key": summary["key"], "path": summary["path"], "state": stored["state"]})
                            for name in ("records", "chunks", "tokens"):
                                result[name] += summary[name]
                            destinations.append({"id": department, "state": stored["state"]})
                        except Exception as error:
                            message = type(error).__name__ + ": " + str(error)
                            result["errors"].append({"path": source["path"], "error": message})
                            failures.append({"department_id": department, "path": source["path"], "error": message})
                            destinations.append({"id": department, "state": "failed", "error": message})
                    source_state = "failed" if any(item["state"] == "failed" for item in destinations) else ("indexed" if job["action"] == "ingest" else "previewed")
                    job["result"]["sources"].append(dict(summary, state=source_state, departments=destinations))
                    for name in ("records", "chunks", "tokens"):
                        job["progress"][name] += summary[name]
                    for record in records[:max(0, 3 - len(job["result"]["samples"]))]:
                        job["result"]["samples"].append({"id": record["id"], "skill_code": record["skill_code"], "path": source["path"], "text": record["text"][:512], "token_count": record["token_count"], "chunks": len(record["chunks"]), "sample_truncated": len(record["text"]) > 512})
                except Exception as error:
                    failure = dict(source, state="failed", error=type(error).__name__ + ": " + str(error))
                    failures.append(failure)
                    job["result"]["sources"].append(failure)
                job["progress"]["files"] += 1
                job["result"]["departments"] = list(department_results.values())
                self.publish_job(job)
            if failures:
                raise RuntimeError(str(len(failures)) + " source or destination failure(s); inspect result.sources and result.departments")
            job["state"] = "completed"
        except Exception as error:
            job["state"] = "failed"
            job["error"] = type(error).__name__ + ": " + str(error)
            if job["action"] == "ingest":
                for department in job["department_ids"]:
                    try:
                        self.record_department_error(department, job["error"])
                    except Exception as storage_error:
                        job["result"]["warnings"].append({"department_id": department, "error": "Could not persist department error: " + str(storage_error)})
        finally:
            with self.lock:
                job["finished_at"] = time.time()
                try:
                    self.publish_job(job)
                except Exception as error:
                    job.update(state="failed", error="Could not persist final job state: " + str(error))
                    self.jobs[key] = copy.deepcopy(job)
