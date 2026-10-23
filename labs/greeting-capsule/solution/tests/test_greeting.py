"""Unit tests for the stdlib `greeting` implementation."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from greeting import MissingRequiredInput, greeting  # noqa: E402


class GreetingTests(unittest.TestCase):
    def test_returns_greeting_output(self) -> None:
        self.assertEqual(greeting({"value": "Pico"}), {"greeting": "Hello, Pico!"})

    def test_matches_hello_pico_lab_output(self) -> None:
        # Capability-level parity with labs/hello-pico (which prints
        # "Hello, Pico!" from a flat Rule).
        self.assertEqual(greeting({"value": "Pico"})["greeting"], "Hello, Pico!")

    def test_missing_required_input_is_structured_error(self) -> None:
        with self.assertRaises(MissingRequiredInput) as cm:
            greeting({})
        self.assertEqual(cm.exception.name, "value")

    def test_none_counts_as_missing(self) -> None:
        with self.assertRaises(MissingRequiredInput):
            greeting({"value": None})

    def test_non_string_input_rejected(self) -> None:
        with self.assertRaises(TypeError):
            greeting({"value": 42})


if __name__ == "__main__":
    unittest.main()
