"""Durable Pico runtime (SQLite-backed).

Demonstrates the essential property Memo 7 requires:
  Pico state belongs to the Pico and survives process restart.

This adapter models the *durable actor* behaviour that celld provides
(SQLite-backed cells). It is intentionally independent of the celld
binary so the course vertical slice is testable everywhere.

A future CelldRuntime can implement the same PicoRuntime SPI against
real celld without changing HelloPico or the contract tests.
"""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path
from typing import Any, Optional

from .pico import HelloPico, PicoState
from .spi import PicoRuntime, RuntimeCapability


class DurableRuntime(PicoRuntime):
    def __init__(self, db_path: str | Path) -> None:
        self._db_path = Path(db_path)
        self._db_path.parent.mkdir(parents=True, exist_ok=True)
        self._conn = sqlite3.connect(str(self._db_path))
        self._conn.execute(
            """
            CREATE TABLE IF NOT EXISTS pico_state (
                id TEXT PRIMARY KEY,
                payload TEXT NOT NULL
            )
            """
        )
        self._conn.commit()
        # In-memory actors reconstructed from durable state on demand
        self._picos: dict[str, HelloPico] = {}

    def capabilities(self) -> set[RuntimeCapability]:
        return {
            RuntimeCapability.INVOKE,
            RuntimeCapability.INSPECT,
            RuntimeCapability.DURABLE_STATE,
            RuntimeCapability.MULTI_IDENTITY,
            RuntimeCapability.SUSPEND,
            RuntimeCapability.RESUME,
        }

    def _load(self, pico_id: str) -> Optional[HelloPico]:
        if pico_id in self._picos:
            return self._picos[pico_id]
        row = self._conn.execute(
            "SELECT payload FROM pico_state WHERE id = ?", (pico_id,)
        ).fetchone()
        if row is None:
            return None
        state = PicoState.from_dict(json.loads(row[0]))
        pico = HelloPico(pico_id, state=state)
        self._picos[pico_id] = pico
        return pico

    def _save(self, pico: HelloPico) -> None:
        payload = json.dumps(pico.state.to_dict())
        self._conn.execute(
            """
            INSERT INTO pico_state (id, payload) VALUES (?, ?)
            ON CONFLICT(id) DO UPDATE SET payload = excluded.payload
            """,
            (pico.state.id, payload),
        )
        self._conn.commit()

    def deploy(self, pico_id: str) -> PicoState:
        pico = self._load(pico_id)
        if pico is None:
            pico = HelloPico(pico_id)
            self._picos[pico_id] = pico
            self._save(pico)
        return pico.inspect()

    def invoke(self, pico_id: str, event: str = "hello", payload: Optional[dict[str, Any]] = None) -> PicoState:
        pico = self._load(pico_id)
        if pico is None:
            self.deploy(pico_id)
            pico = self._picos[pico_id]
        payload = payload or {}
        if event != "hello":
            raise ValueError(f"unsupported event: {event}")
        name = payload.get("name", "Pico")
        state = pico.hello(name)
        self._save(pico)
        return state

    def inspect(self, pico_id: str) -> PicoState:
        pico = self._load(pico_id)
        if pico is None:
            raise KeyError(f"pico not found: {pico_id}")
        return pico.inspect()

    def delete(self, pico_id: str) -> None:
        self._picos.pop(pico_id, None)
        self._conn.execute("DELETE FROM pico_state WHERE id = ?", (pico_id,))
        self._conn.commit()

    def suspend(self, pico_id: str) -> None:
        """Drop in-memory actor; durable state remains in SQLite."""
        self._picos.pop(pico_id, None)

    def resume(self, pico_id: str) -> PicoState:
        pico = self._load(pico_id)
        if pico is None:
            raise KeyError(f"pico not found: {pico_id}")
        return pico.inspect()

    def close(self) -> None:
        self._conn.close()

    @classmethod
    def reopen(cls, db_path: str | Path) -> "DurableRuntime":
        """Simulate process restart: new runtime instance, same durable store."""
        return cls(db_path)
