"""Contract tests: ``greeting.py`` must honour ``capsule.yaml`` literally.

Reads ``solution/capsule.yaml`` at test time and asserts that each
declared input and output is handled by the implementation with the
declared name and type. This closes the loop memo23 §5 rules 3 and 4
(explicit dependencies / contract-based integration) at the capability
boundary.
"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
SOLUTION = HERE.parent
sys.path.insert(0, str(SOLUTION))

from greeting import MissingRequiredInput, greeting  # noqa: E402


def _load_capsule() -> dict:
    with (SOLUTION / "capsule.yaml").open() as fh:
        return yaml.safe_load(fh)


_TYPE_TO_PY = {"string": str}


class ContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.capsule = _load_capsule()
        cls.inputs = cls.capsule["spec"].get("inputs", {}) or {}
        cls.outputs = cls.capsule["spec"].get("outputs", {}) or {}

    def test_capability_identifier_is_oe_greeting(self) -> None:
        self.assertEqual(self.capsule["spec"]["capability"], "oe.greeting")

    def test_each_required_input_raises_when_missing(self) -> None:
        required = [n for n, d in self.inputs.items() if d.get("required")]
        self.assertTrue(required, "capsule declares at least one required input")
        for name in required:
            with self.subTest(input=name):
                with self.assertRaises(MissingRequiredInput) as cm:
                    greeting({})
                self.assertEqual(cm.exception.name, name)

    def test_declared_input_names_and_types_are_honoured(self) -> None:
        # Build a well-typed sample input dict from the declared types,
        # call the capability, and assert the output names/types match
        # the declared outputs. This asserts the implementation honours
        # each declared name and type (as the task requires).
        sample = {}
        for name, decl in self.inputs.items():
            py_type = _TYPE_TO_PY.get(decl["type"])
            self.assertIsNotNone(py_type, f"unknown declared input type {decl['type']!r}")
            sample[name] = "Pico"
        result = greeting(sample)
        self.assertEqual(set(result.keys()), set(self.outputs.keys()))
        for name, decl in self.outputs.items():
            py_type = _TYPE_TO_PY.get(decl["type"])
            self.assertIsNotNone(py_type, f"unknown declared output type {decl['type']!r}")
            self.assertIsInstance(result[name], py_type)


if __name__ == "__main__":
    unittest.main()
