import copy
import bisect
import hashlib
import json
import math
import re
import threading
from pathlib import Path

from ingestion import ConflictError, DEPARTMENT_IDS, encoded


def default_routing_config():
    return {"schema": "t-eec.routing-config/1", "selection": {"mode": "score_window", "max_departments": 2, "score_window": 0.05, "min_score": None}, "fallback_department_ids": ["microskills"], "departments": {"microskills": {"description": "Reusable microskills, executable procedures, technical knowledge and problem-solving instructions.", "examples": ["Find the relevant procedure or skill for this technical task.", "Bu görev için ilgili beceriyi ve uygulama adımlarını bul."]}}}


def department_ids(value):
    if not isinstance(value, list) or not value or any(not isinstance(key, str) or key not in DEPARTMENT_IDS for key in value) or len(set(value)) != len(value):
        raise ValueError("department_ids must contain unique known department identities")
    return list(value)


def valid_vector(value, dimensions=384):
    return isinstance(value, list) and len(value) == dimensions and all(type(number) in (int, float) and math.isfinite(number) for number in value) and any(value)


def cosine(left, right):
    denominator = math.sqrt(sum(value * value for value in left) * sum(value * value for value in right))
    return sum(a * b for a, b in zip(left, right)) / denominator if denominator else 0.0


def token_windows(tokenizer, text, kind, limit):
    prefix = kind + ": "
    full = tokenizer.encode(prefix + text)
    raw = tokenizer.encode(text, add_special_tokens=False)
    metadata = {"policy": "token_windows_mean_l2", "windows": 1, "input_tokens": len(raw.ids), "prefixed_tokens": len(full.ids), "max_tokens": limit, "truncated": False}
    if len(full.ids) <= limit:
        return [text], metadata
    budget = limit - len(tokenizer.encode(prefix).ids)
    if budget < 1:
        raise ValueError("E5 token limit leaves no room after the prefix")
    boundaries = sorted({last for first, last in raw.offsets if 0 <= first < last <= len(text)} | {len(text)})
    chunks, start = [], 0
    while start < len(text):
        if chunks and not text[start:].strip() and len(tokenizer.encode(prefix + chunks[-1] + text[start:]).ids) <= limit:
            chunks[-1] += text[start:]
            break
        low = bisect.bisect_right(boundaries, start)
        high = min(len(boundaries) - 1, low + budget - 1)
        best = None
        while low <= high:
            middle = (low + high) // 2
            end = boundaries[middle]
            candidate = text[start:end]
            if candidate.strip() and len(tokenizer.encode(prefix + candidate).ids) <= limit:
                best = end
                low = middle + 1
            else:
                high = middle - 1
        if best is None:
            raise ValueError("A query character span cannot fit the E5 token limit")
        chunks.append(text[start:best])
        start = best
    metadata["windows"] = len(chunks)
    return chunks, metadata


class RetrievalService:
    def __init__(self, service):
        self.service = service
        self.ingestion = service.ingestion
        self.config_path = self.ingestion.data_dir / "routing-settings.json"
        self.profile_lock = threading.Lock()
        self.profile_cache = None

    def config(self):
        value = json.loads(self.config_path.read_text(encoding="utf-8")) if self.config_path.exists() else default_routing_config()
        if not isinstance(value, dict) or value.get("schema") != "t-eec.routing-config/1":
            raise ValueError("Unsupported routing config schema")
        selection = value.get("selection")
        if not isinstance(selection, dict) or selection.get("mode") not in ("top_n", "score_window"):
            raise ValueError("selection.mode must be top_n or score_window")
        if type(selection.get("max_departments")) is not int or selection["max_departments"] < 1:
            raise ValueError("selection.max_departments must be a positive integer")
        window = selection.get("score_window")
        if type(window) not in (float, int) or not math.isfinite(window) or window < 0:
            raise ValueError("selection.score_window must be a finite nonnegative number")
        minimum = selection.get("min_score")
        if minimum is not None and (type(minimum) not in (float, int) or not math.isfinite(minimum) or not -1 <= minimum <= 1):
            raise ValueError("selection.min_score must be null or a cosine score between -1 and 1")
        fallback = value.get("fallback_department_ids")
        if fallback != []:
            department_ids(fallback)
        profiles = value.get("departments")
        if not isinstance(profiles, dict) or any(key not in DEPARTMENT_IDS for key in profiles):
            raise ValueError("routing departments must map known identities to profiles")
        for profile in profiles.values():
            if not isinstance(profile, dict) or not isinstance(profile.get("description", ""), str) or not isinstance(profile.get("examples", []), list) or any(not isinstance(text, str) for text in profile.get("examples", [])):
                raise ValueError("Routing profiles require text descriptions and text example arrays")
        return value

    def validate_request(self, payload, search=False):
        if not isinstance(payload, dict) or not isinstance(payload.get("query"), str) or not payload["query"].strip():
            raise ValueError("query must be nonempty text")
        if "department_ids" in payload:
            department_ids(payload["department_ids"])
        if search:
            if type(payload.get("top_k", 5)) is not int or payload.get("top_k", 5) < 1:
                raise ValueError("top_k must be a positive integer")
            if type(payload.get("rerank", False)) is not bool:
                raise ValueError("rerank must be a boolean")

    def manifests(self, selected):
        with self.ingestion.store_lock:
            return {key: self.ingestion.manifest(key) for key in selected}

    def indexed_sources(self, manifest):
        return {key: source for key, source in manifest["sources"].items() if source.get("state") == "indexed" and key not in manifest["pending"] and source.get("vector_ids")}

    def status(self):
        settings = self.ingestion.config()
        manifests = self.manifests(DEPARTMENT_IDS)
        departments = []
        with self.ingestion.store_lock:
            loaded = set(self.ingestion.collections)
        for item in settings["departments"]:
            manifest = manifests[item["id"]]
            indexed = self.indexed_sources(manifest)
            departments.append({"id": item["id"], "name": item["name"], "indexed_sources": len(indexed), "indexed_chunks": sum(len(source["vector_ids"]) for source in indexed.values()), "pending_sources": len(manifest["pending"]), "loaded": item["id"] in loaded, "last_error": manifest.get("last_error")})
        with self.ingestion.lock:
            active = [{"id": job["id"], "state": job["state"], "progress": copy.deepcopy(job["progress"])} for job in self.ingestion.jobs.values() if job["state"] in ("queued", "running")]
        return {"schema": "t-eec.retrieval-status/1", "ready": self.service.snapshot(probe=False)["ready"], "departments": departments, "routing": {"config_path": str(self.config_path), "config": self.config(), "literal_matching": "casefolded_substring", "rules_execute_code": False}, "active_jobs": active, "paths": {"service": str(Path(__file__).parent), "data": str(self.ingestion.data_dir)}}

    def embed_query(self, query):
        identity = self.ingestion.model_identity()
        self.service.check_ingestion_assets(identity)
        result, preparation = self.embed_texts([query], "query", identity)
        self.validate_identity(identity)
        return result[0], identity, preparation[0]

    def embed_texts(self, texts, kind, identity):
        tokenizer = self.service.resident_runtime("e5").tokenizer
        parts = [token_windows(tokenizer, text, kind, identity["max_tokens"]) for text in texts]
        flattened = [window for windows, _ in parts for window in windows]
        vectors = []
        for first in range(0, len(flattened), 8):
            batch = flattened[first:first + 8]
            result = self.service.run("e5", {"texts": batch, "kind": kind})["result"]["embeddings"]
            if not isinstance(result, list) or len(result) != len(batch) or any(not valid_vector(value) for value in result):
                raise ValueError("E5 returned invalid retrieval embeddings")
            vectors.extend(result)
        pooled, offset = [], 0
        for windows, _ in parts:
            batch = vectors[offset:offset + len(windows)]
            value = [sum(row[index] for row in batch) / len(batch) for index in range(384)]
            norm = math.sqrt(sum(item * item for item in value))
            if not norm or not math.isfinite(norm):
                raise ValueError("E5 window embeddings cannot be normalized")
            pooled.append([item / norm for item in value])
            offset += len(windows)
        self.validate_identity(identity)
        return pooled, [preparation for _, preparation in parts]

    def validate_identity(self, identity):
        if identity != self.ingestion.model_identity():
            raise ConflictError("E5 assets changed during retrieval; retry with stable assets")
        self.service.check_ingestion_assets(identity)

    def profiles(self, departments, config):
        values = []
        for item in departments:
            profile = config["departments"].get(item["id"], {})
            description = profile.get("description", item.get("description", ""))
            examples = profile.get("examples", item.get("examples", []))
            if not isinstance(description, str) or not isinstance(examples, list) or any(not isinstance(text, str) for text in examples):
                raise ValueError("Department routing descriptions and examples must be text")
            placeholder = re.fullmatch(r"(?:department|departman)[\s_-]*[2-6]", item["name"].strip(), re.IGNORECASE)
            if placeholder and not description.strip() and not any(text.strip() for text in examples):
                continue
            values.append((item["id"], "\n".join([item["name"], description] + examples).strip()))
        return values

    def profile_vectors(self, profiles, identity):
        signature = hashlib.sha256(encoded([profiles, identity])).hexdigest()
        with self.profile_lock:
            if self.profile_cache and self.profile_cache[0] == signature:
                return self.profile_cache[1]
            result, _ = self.embed_texts([text for _, text in profiles], "passage", identity)
            self.profile_cache = (signature, result)
            return result

    def choose(self, query, explicit=None, vector=None, identity=None, preparation=None):
        config = self.config()
        result = {"department_ids": [], "reason": "empty", "scores": [], "matched": [], "selection": config["selection"]}
        if explicit is not None:
            result.update(department_ids=department_ids(explicit), reason="explicit")
            return result, vector, identity, preparation
        settings = self.ingestion.config()
        manifests = self.manifests(DEPARTMENT_IDS)
        populated = [item for item in settings["departments"] if self.indexed_sources(manifests[item["id"]])]
        query_folded = query.casefold()
        for item in populated:
            for field in ("phrases", "rules"):
                for text in item[field]:
                    if text.strip() and text.strip().casefold() in query_folded:
                        result["matched"].append({"department_id": item["id"], "field": field, "text": text})
        if result["matched"]:
            result.update(department_ids=list(dict.fromkeys(match["department_id"] for match in result["matched"])), reason="literal")
            return result, vector, identity, preparation
        profiles = self.profiles(populated, config)
        if len(profiles) == 1:
            result.update(department_ids=[profiles[0][0]], reason="single_populated_department")
            return result, vector, identity, preparation
        if profiles:
            if vector is None:
                vector, identity, preparation = self.embed_query(query)
            profile_vectors = self.profile_vectors(profiles, identity)
            scores = sorted(({"department_id": key, "score": cosine(vector, embedding)} for (key, _), embedding in zip(profiles, profile_vectors)), key=lambda item: (-item["score"], item["department_id"]))
            result["scores"] = scores
            selection = config["selection"]
            selected = [item for item in scores if selection["min_score"] is None or item["score"] >= selection["min_score"]]
            if selected and selection["mode"] == "score_window":
                selected = [item for item in selected if item["score"] >= selected[0]["score"] - selection["score_window"]]
            selected = selected[:selection["max_departments"]]
            if selected:
                result.update(department_ids=[item["department_id"] for item in selected], reason="semantic")
                return result, vector, identity, preparation
        available = {item["id"] for item in populated}
        fallback = [key for key in config["fallback_department_ids"] if key in available]
        if fallback:
            result.update(department_ids=fallback, reason="fallback")
        return result, vector, identity, preparation

    def route(self, payload):
        self.validate_request(payload)
        routing, _, _, preparation = self.choose(payload["query"], payload.get("department_ids"))
        return {"query": payload["query"], "routing": routing, "query_preparation": preparation}

    def collection(self, key):
        with self.ingestion.store_lock:
            if key in self.ingestion.collections:
                return self.ingestion.collections[key]
            if not (self.ingestion.department_path(key) / "chroma.sqlite3").is_file():
                return None
            client = self.ingestion.clients.get(key)
            if client is None:
                import chromadb
                from chromadb.config import Settings
                client = chromadb.PersistentClient(path=str(self.ingestion.department_path(key)), settings=Settings(anonymized_telemetry=False))
            collection = client.get_collection("documents", embedding_function=None)
            self.ingestion.clients[key] = client
            self.ingestion.collections[key] = collection
            return collection

    def metric(self, collection):
        configuration = getattr(collection, "configuration", None)
        if callable(configuration):
            configuration = configuration()
        if isinstance(configuration, dict):
            for name in ("hnsw", "spann"):
                options = configuration.get(name)
                if isinstance(options, dict) and options.get("space") in ("l2", "cosine", "ip"):
                    return options["space"]
        metadata = getattr(collection, "metadata", None) or {}
        value = metadata.get("hnsw:space", "l2")
        if value not in ("l2", "cosine", "ip"):
            raise ValueError("Unsupported collection distance metric: " + str(value))
        return value

    def committed(self, manifest, identifier, metadata, identity=None):
        if not isinstance(metadata, dict):
            return False
        key = metadata.get("_ingest_source_key")
        source = manifest["sources"].get(key)
        if not source or key in manifest["pending"] or source.get("state") != "indexed" or source.get("fingerprint") != metadata.get("_ingest_fingerprint") or identifier not in source.get("vector_ids", []):
            return False
        if identity is not None:
            actual = dict(source.get("embedding", {}), tokenizer_sha256=source.get("tokenizer", {}).get("sha256"))
            if actual != identity:
                return False
        return True

    def query_department(self, key, vector, identity, top_k):
        before = self.manifests([key])[key]
        if not self.indexed_sources(before):
            return [], []
        collection = self.collection(key)
        if collection is None:
            return [], [{"department_id": key, "reason": "index_database_missing"}]
        metric = self.metric(collection)
        with self.ingestion.store_lock:
            count = collection.count()
        amount = min(count, top_k)
        accepted = []
        rejected = 0
        while amount:
            with self.ingestion.store_lock:
                result = collection.query(query_embeddings=[vector], n_results=amount, include=["documents", "metadatas", "distances"])
            after = self.manifests([key])[key]
            accepted = []
            rejected = 0
            for identifier, text, metadata, distance in zip(result["ids"][0], result["documents"][0], result["metadatas"][0], result["distances"][0]):
                if self.committed(before, identifier, metadata, identity) and self.committed(after, identifier, metadata, identity):
                    accepted.append({"id": identifier, "department_id": key, "text": text, "metadata": metadata, "distance": float(distance), "metric": metric})
                else:
                    rejected += 1
            if len(accepted) >= top_k or amount >= count:
                break
            amount = min(count, max(amount + 1, amount * 2))
        warnings = [{"department_id": key, "reason": "uncommitted_or_incompatible_candidates_excluded", "count": rejected}] if rejected else []
        return accepted[:top_k], warnings

    def search(self, payload):
        self.validate_request(payload, search=True)
        query, top_k = payload["query"], payload.get("top_k", 5)
        routing, vector, identity, preparation = self.choose(query, payload.get("department_ids"))
        selected = routing["department_ids"]
        manifests = self.manifests(selected)
        populated = [key for key in selected if self.indexed_sources(manifests[key])]
        results, warnings = [], []
        if populated:
            if vector is None:
                vector, identity, preparation = self.embed_query(query)
            for key in populated:
                found, excluded = self.query_department(key, vector, identity, top_k)
                results.extend(found)
                warnings.extend(excluded)
            self.validate_identity(identity)
        metrics = {item["metric"] for item in results}
        if len(metrics) > 1:
            ranks = {}
            for key in selected:
                ranked = sorted((item for item in results if item["department_id"] == key), key=lambda item: (item["distance"], item["id"]))
                ranks.update({(item["department_id"], item["id"]): rank for rank, item in enumerate(ranked)})
            results.sort(key=lambda item: (ranks[(item["department_id"], item["id"])], selected.index(item["department_id"]), item["id"]))
            warnings.append({"reason": "mixed_distance_metrics_merged_by_department_rank"})
        else:
            results.sort(key=lambda item: (item["distance"], item["department_id"], item["id"]))
        reranked = bool(payload.get("rerank", False) and results)
        if reranked:
            scores = self.service.run("tinybert", {"query": query, "docs": [item["text"] for item in results]})["result"]["scores"]
            if not isinstance(scores, list) or len(scores) != len(results) or any(type(value) not in (float, int) or not math.isfinite(value) for value in scores):
                raise ValueError("TinyBERT returned invalid reranking scores")
            for item, score in zip(results, scores):
                item["rerank_score"] = score
            results.sort(key=lambda item: (-item["rerank_score"], item["department_id"], item["id"]))
        current = self.manifests(populated)
        results = [item for item in results if self.committed(current[item["department_id"]], item["id"], item["metadata"], identity)]
        return {"query": query, "routing": routing, "query_preparation": preparation, "results": results[:top_k], "top_k": top_k, "reranked": reranked, "model": {"id": "e5", "kind": "query", "dimensions": 384}, "warnings": warnings}

    def get(self, payload):
        if not isinstance(payload, dict):
            raise ValueError("Request must be a JSON object")
        key, identifier = payload.get("department_id"), payload.get("record_id")
        department_ids([key])
        if not isinstance(identifier, str) or not identifier.strip():
            raise ValueError("record_id must be nonempty text")
        before = self.manifests([key])[key]
        if not self.indexed_sources(before):
            raise KeyError("Record not found")
        collection = self.collection(key)
        if collection is None:
            raise KeyError("Record not found")
        with self.ingestion.store_lock:
            found = collection.get(ids=[identifier], include=["documents", "metadatas"])
            if not found["ids"]:
                found = collection.get(where={"_ingest_record_id": identifier}, include=["documents", "metadatas"])
        after = self.manifests([key])[key]
        matches = [(item, metadata) for item, metadata in zip(found["ids"], found["metadatas"]) if self.committed(before, item, metadata) and self.committed(after, item, metadata)]
        if not matches:
            raise KeyError("Record not found or currently being re-indexed")
        identities = {(metadata["_ingest_source_key"], metadata["_ingest_record_id"]) for _, metadata in matches}
        if len(identities) != 1:
            raise ConflictError("Record identity occurs in multiple sources; use a result vector id")
        vector_id, metadata = matches[0]
        source = after["sources"][metadata["_ingest_source_key"]]
        prepared = self.ingestion.department_path(key) / source["prepared_file"]
        try:
            content = prepared.read_bytes()
        except OSError as error:
            raise ConflictError("Prepared source changed during retrieval; retry") from error
        if hashlib.sha256(content).hexdigest() != source.get("prepared_sha256"):
            raise ConflictError("Prepared source does not match its manifest checksum")
        record = next((item for item in (json.loads(line) for line in content.splitlines() if line.strip()) if item.get("id") == metadata["_ingest_record_id"]), None)
        if record is None:
            raise ConflictError("Indexed record is missing from its prepared source")
        current = self.manifests([key])[key]
        if not self.committed(current, vector_id, metadata) or current["sources"][metadata["_ingest_source_key"]].get("prepared_sha256") != source.get("prepared_sha256"):
            raise ConflictError("Source changed during retrieval; retry")
        return {"department_id": key, "id": vector_id, "record_id": record["id"], "text": record["text"], "metadata": dict(record.get("metadata", {}), **metadata), "source": record["source"], "chunks": record["chunks"]}
