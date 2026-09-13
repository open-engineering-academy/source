"""Shared diagnostic type for the academy metadata OELS adapter.

Kept in its own module so the schema walker and the validator core avoid a
circular import while still sharing the same diagnostic shape.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Diagnostic:
    code: str
    message: str
    path: str
    source: str = "open-engineering-lsp"

    def format(self) -> str:
        loc = self.path or "<root>"
        return f"[{self.code}] {loc}: {self.message}"
