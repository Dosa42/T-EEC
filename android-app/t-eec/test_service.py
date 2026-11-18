import json
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import patch

from model_runtime import MODEL_SPECS, validate_payload
from server import SemanticService


class ServiceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.root = Path(self.directory.name)
        for key, spec in MODEL_SPECS.items():
            directory = self.root / "models" / spec["name"]
            (directory / "onnx").mkdir(parents=True)
            for name in ("onnx/model_int8.onnx", "tokenizer.json", "gliner_config.json" if key == "gliner" else "config.json"):
                (directory / name).write_text("{}")
        self.service = SemanticService(self.root / "models", self.root / "data")

    def tearDown(self):
        self.directory.cleanup()

    def enable(self):
        self.service.selftest["passed"] = True
        for model in self.service.models.values():
            model["ready"] = True
        for component in self.service.components.values():
            component["ready"] = True

    def test_assets_and_previous_result_do_not_establish_readiness(self):
        (self.service.data_dir / "last-selftest.json").write_text(json.dumps({"selftest": {"passed": True}}))
        snapshot = self.service.snapshot()
        self.assertFalse(snapshot["ready"])
        self.assertTrue(all(item["connected"] for item in snapshot["models"]))
        self.assertFalse(any(item["ready"] for item in snapshot["models"]))

    def test_readiness_requires_every_model_component_and_current_assets(self):
        self.enable()
        self.assertTrue(self.service.snapshot()["ready"])
        self.service.models["nli"]["ready"] = False
        self.assertFalse(self.service.snapshot()["ready"])
        self.service.models["nli"]["ready"] = True
        self.service.components["langchain"]["ready"] = False
        self.assertFalse(self.service.snapshot()["ready"])
        self.service.components["langchain"]["ready"] = True
        path = self.root / "models" / MODEL_SPECS["gliner"]["name"] / "onnx/model_int8.onnx"
        path.unlink()
        self.assertFalse(self.service.snapshot()["ready"])

    def test_health_chroma_failure_revokes_readiness(self):
        self.enable()

        class BrokenClient:
            def heartbeat(self):
                raise OSError("persistent storage unavailable")

        self.service.chroma = BrokenClient()
        snapshot = self.service.snapshot()
        self.assertFalse(snapshot["ready"])
        self.assertIn("storage unavailable", snapshot["components"]["chroma"]["last_error"])

    def test_rapid_inference_retains_both_transitions(self):
        with self.service.activity("tinybert", "test"):
            self.assertEqual(self.service.models["tinybert"]["active_count"], 1)
        result = self.service.events_after(0)
        self.assertEqual([item["kind"] for item in result["events"]], ["start", "end"])
        self.assertEqual([item["active_count"] for item in result["events"]], [1, 0])
        self.assertEqual(result["cursor"], 2)
        self.assertEqual(self.service.events_after(2)["events"], [])

    def test_concurrent_counter_and_failure_return_to_zero(self):
        entered = threading.Barrier(3)
        release = threading.Event()

        def worker():
            try:
                with self.service.activity("e5", "test"):
                    entered.wait()
                    release.wait()
                    raise RuntimeError("inference failed")
            except RuntimeError:
                pass

        threads = [threading.Thread(target=worker) for _ in range(2)]
        for thread in threads:
            thread.start()
        entered.wait(timeout=5)
        self.assertEqual(self.service.models["e5"]["active_count"], 2)
        release.set()
        for thread in threads:
            thread.join(timeout=5)
            self.assertFalse(thread.is_alive())
        self.assertEqual(self.service.models["e5"]["active_count"], 0)
        self.assertFalse(self.service.models["e5"]["ready"])
        self.assertEqual(sum(item["kind"] == "error" for item in self.service.events), 2)

    def test_invalid_input_never_starts_inference(self):
        with self.assertRaises(ValueError):
            self.service.run("e5", {"texts": []})
        with self.assertRaises(ValueError):
            validate_payload("gliner", {"text": "Alice", "labels": ["person"], "threshold": float("nan")})
        self.assertEqual(self.service.cursor, 0)

    def test_event_history_gap_is_explicit(self):
        for _ in range(2050):
            self.service.event("test")
        result = self.service.events_after(0)
        self.assertTrue(result["truncated"])
        self.assertEqual(result["oldest_seq"], 3)
        self.assertEqual(len(result["events"]), 2048)
        self.assertTrue(self.service.events_after(9999)["truncated"])

    def test_selftest_duplicate_start_is_rejected(self):
        with patch("server.threading.Thread") as thread:
            self.assertTrue(self.service.start_selftest())
            self.assertFalse(self.service.start_selftest())
            self.assertEqual(thread.call_count, 1)
            self.assertFalse(self.service.snapshot()["ready"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
