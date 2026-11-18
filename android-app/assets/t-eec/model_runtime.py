import argparse
import json
import math
import re
import sys
from pathlib import Path

import numpy as np
import onnxruntime as ort
from tokenizers import Tokenizer


MODEL_SPECS = {
    "e5": {"name": "multilingual-e5-small", "resident": True},
    "tinybert": {"name": "ms-marco-TinyBERT-L-2-v2", "resident": True},
    "nli": {"name": "nli-deberta-v3-xsmall", "resident": False},
    "gliner": {"name": "gliner_small-v2.1", "resident": False},
}


def strings(value, field):
    if not isinstance(value, list) or not value or any(not isinstance(x, str) or not x.strip() for x in value):
        raise ValueError(field + " must be a nonempty list of nonempty strings")
    return value


def finite(value):
    if not np.isfinite(value).all():
        raise RuntimeError("Model returned nonfinite values")
    return value


def validate_payload(model_id, payload):
    if not isinstance(payload, dict):
        raise ValueError("Request body must be an object")
    if model_id == "e5":
        strings(payload.get("texts", [payload["text"]] if "text" in payload else None), "texts")
        if payload.get("kind", "query") not in ("query", "passage"):
            raise ValueError("kind must be query or passage")
    elif model_id == "tinybert":
        strings([payload.get("query")], "query")
        strings(payload.get("docs"), "docs")
    elif model_id == "nli":
        pairs = payload.get("pairs")
        if not isinstance(pairs, list) or not pairs:
            raise ValueError("pairs must be a nonempty list")
        for pair in pairs:
            if not isinstance(pair, dict):
                raise ValueError("pairs must contain premise/hypothesis objects")
            strings([pair.get("premise"), pair.get("hypothesis")], "premise/hypothesis")
    elif model_id == "gliner":
        strings([payload.get("text")], "text")
        labels = strings(payload.get("labels"), "labels")
        if len(set(labels)) != len(labels):
            raise ValueError("labels must be unique")
        threshold = payload.get("threshold", 0.5)
        if isinstance(threshold, bool) or not isinstance(threshold, (int, float)) or not math.isfinite(threshold) or not 0 <= threshold <= 1:
            raise ValueError("threshold must be finite and between 0 and 1")
    else:
        raise ValueError("Unknown model")


class ModelRuntime:
    def __init__(self, model_id, models_dir):
        self.model_id = model_id
        self.path = Path(models_dir) / MODEL_SPECS[model_id]["name"]
        self.tokenizer = Tokenizer.from_file(str(self.path / "tokenizer.json"))
        self.tokenizer.no_truncation()
        self.tokenizer.no_padding()
        config_name = "gliner_config.json" if model_id == "gliner" else "config.json"
        self.config = json.loads((self.path / config_name).read_text())
        options = ort.SessionOptions()
        options.intra_op_num_threads = 2
        options.inter_op_num_threads = 1
        options.execution_mode = ort.ExecutionMode.ORT_SEQUENTIAL
        options.enable_cpu_mem_arena = False
        self.session = ort.InferenceSession(str(self.path / "onnx" / "model_int8.onnx"), sess_options=options, providers=["CPUExecutionProvider"])
        self.signature = [{"name": item.name, "type": item.type, "shape": item.shape} for item in self.session.get_inputs()]
        if self.session.get_providers() != ["CPUExecutionProvider"]:
            raise RuntimeError("Expected exclusive CPUExecutionProvider")

    def encode(self, values):
        encoded = self.tokenizer.encode_batch(values)
        length = max(len(item.ids) for item in encoded)
        if length > 512:
            raise ValueError("Input exceeds the model's 512 subtoken limit; split the input")
        pad_id = self.tokenizer.token_to_id("<pad>")
        if pad_id is None:
            pad_id = self.tokenizer.token_to_id("[PAD]")
        if pad_id is None:
            pad_id = self.config.get("pad_token_id", 0)
        inputs = {
            "input_ids": np.array([x.ids + [pad_id] * (length - len(x.ids)) for x in encoded], dtype=np.int64),
            "attention_mask": np.array([x.attention_mask + [0] * (length - len(x.ids)) for x in encoded], dtype=np.int64),
            "token_type_ids": np.array([x.type_ids + [0] * (length - len(x.ids)) for x in encoded], dtype=np.int64),
        }
        return inputs

    def forward(self, inputs):
        types = {"tensor(int64)": np.int64, "tensor(int32)": np.int32, "tensor(bool)": np.bool_, "tensor(float)": np.float32}
        feed = {}
        for item in self.session.get_inputs():
            if item.name not in inputs:
                raise RuntimeError("Unimplemented ONNX input: " + item.name)
            feed[item.name] = inputs[item.name].astype(types[item.type], copy=False)
        return finite(self.session.run(None, feed)[0])

    def run(self, payload):
        validate_payload(self.model_id, payload)
        if self.model_id == "e5":
            values = payload.get("texts", [payload["text"]] if "text" in payload else None)
            kind = payload.get("kind", "query")
            inputs = self.encode([kind + ": " + value for value in values])
            hidden = self.forward(inputs)
            if hidden.ndim != 3:
                raise RuntimeError("E5 output must be token embeddings")
            mask = inputs["attention_mask"][..., None].astype(np.float32)
            pooled = (hidden * mask).sum(axis=1) / mask.sum(axis=1)
            norm = np.linalg.norm(pooled, axis=1, keepdims=True)
            if (norm <= 0).any():
                raise RuntimeError("E5 produced zero vectors")
            vectors = finite(pooled / norm)
            if vectors.shape[1] != 384:
                raise RuntimeError("E5 dimension must be 384")
            return {"embeddings": vectors.tolist(), "dimensions": 384, "kind": kind, "prefix_applied": kind + ": "}
        if self.model_id == "tinybert":
            scores = self.forward(self.encode([(payload["query"], text) for text in payload["docs"]])).reshape(-1)
            if len(scores) != len(payload["docs"]):
                raise RuntimeError("Unexpected reranker output shape")
            return {"scores": scores.tolist(), "ranking": sorted(range(len(scores)), key=lambda index: float(scores[index]), reverse=True)}
        if self.model_id == "nli":
            scores = self.forward(self.encode([(p["premise"], p["hypothesis"]) for p in payload["pairs"]]))
            labels = [self.config["id2label"][str(index)].lower() for index in range(scores.shape[-1])]
            if set(labels) != {"contradiction", "entailment", "neutral"}:
                raise RuntimeError("NLI labels are not explicit contradiction/entailment/neutral")
            exp = np.exp(scores - scores.max(axis=-1, keepdims=True))
            probabilities = finite(exp / exp.sum(axis=-1, keepdims=True))
            return {"labels": labels, "predictions": [{"label": labels[int(row.argmax())], "probabilities": dict(zip(labels, row.tolist())), "logits": logits.tolist()} for row, logits in zip(probabilities, scores)]}
        return self.entities(payload)

    def entities(self, payload):
        text, labels = payload["text"], payload["labels"]
        matches = list(re.finditer(r"\w+(?:[-_]\w+)*|\S", text))
        if not matches:
            raise ValueError("text has no entity tokens")
        if len(matches) > self.config.get("max_len", 384):
            raise ValueError("Text exceeds GLiNER word limit; split the input")
        if len(labels) > self.config.get("max_types", 25):
            raise ValueError("Too many entity labels")
        prompt = []
        for label in labels:
            prompt.extend([self.config.get("ent_token", "<<ENT>>"), label])
        prompt.append(self.config.get("sep_token", "<<SEP>>"))
        encoded = self.tokenizer.encode(prompt + [m.group() for m in matches], is_pretokenized=True)
        if len(encoded.ids) > 512:
            raise ValueError("Prompt and text exceed GLiNER 512 subtoken limit; split the input")
        words_mask, previous = [], None
        for word_id in encoded.word_ids:
            words_mask.append(word_id - len(prompt) + 1 if word_id is not None and word_id >= len(prompt) and word_id != previous else 0)
            previous = word_id
        width, count = self.config.get("max_width", 12), len(matches)
        spans = [(start, start + delta) for start in range(count) for delta in range(width)]
        inputs = {
            "input_ids": np.array([encoded.ids], dtype=np.int64),
            "attention_mask": np.array([encoded.attention_mask], dtype=np.int64),
            "token_type_ids": np.array([encoded.type_ids], dtype=np.int64),
            "words_mask": np.array([words_mask], dtype=np.int64),
            "text_lengths": np.array([[count]], dtype=np.int64),
            "span_idx": np.array([spans], dtype=np.int64),
            "span_mask": np.array([[end < count for start, end in spans]], dtype=np.bool_),
        }
        logits = self.forward(inputs)
        expected = (1, count, width, len(labels))
        if logits.shape != expected:
            raise RuntimeError("Unexpected GLiNER logits shape: " + str(logits.shape) + " expected " + str(expected))
        scores = 1 / (1 + np.exp(-np.clip(logits[0], -80, 80)))
        candidates = []
        for start, delta, label in np.argwhere(scores > payload.get("threshold", 0.5)):
            end = int(start + delta)
            if end < count:
                candidates.append((float(scores[start, delta, label]), int(start), end, int(label)))
        accepted = []
        for score, start, end, label in sorted(candidates, key=lambda item: item[0], reverse=True):
            if any(start <= previous_end and end >= previous_start for _, previous_start, previous_end, _ in accepted):
                continue
            accepted.append((score, start, end, label))
        entities = []
        for score, start, end, label in sorted(accepted, key=lambda item: item[1]):
            first, last = matches[start].start(), matches[end].end()
            entities.append({"start": first, "end": last, "text": text[first:last], "label": labels[label], "score": score})
        return {"entities": entities, "threshold": payload.get("threshold", 0.5), "word_count": count, "logits_shape": list(logits.shape)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--worker", choices=MODEL_SPECS, required=True)
    parser.add_argument("--models-dir", required=True)
    args = parser.parse_args()
    try:
        payload = json.loads(sys.stdin.readline())
        runtime = ModelRuntime(args.worker, args.models_dir)
        print(json.dumps({"kind": "loaded", "signature": runtime.signature}), flush=True)
        print(json.dumps({"kind": "result", "result": runtime.run(payload)}, allow_nan=False), flush=True)
    except Exception as error:
        print(json.dumps({"kind": "error", "error_type": type(error).__name__, "error": type(error).__name__ + ": " + str(error)}), flush=True)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
