"""Hello Pico domain logic — independent of any runtime."""

from __future__ import annotations

from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from typing import Any, Optional


@dataclass
class PicoState:
    id: str
    version: str = "0.1.0"
    status: str = "ready"
    message: str = ""
    event_count: int = 0
    last_run: Optional[str] = None  # ISO-8601

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "PicoState":
        return cls(
            id=data["id"],
            version=data.get("version", "0.1.0"),
            status=data.get("status", "ready"),
            message=data.get("message", ""),
            event_count=int(data.get("event_count", 0)),
            last_run=data.get("last_run"),
        )


class HelloPico:
    """Canonical Hello Pico behaviour.

    Each hello(name):
      1. receives an event
      2. increments event_count
      3. records last_run
      4. produces a greeting
      5. exposes resulting state
    """

    def __init__(self, pico_id: str = "hello-pico", state: Optional[PicoState] = None):
        self._state = state or PicoState(id=pico_id)

    @property
    def state(self) -> PicoState:
        return self._state

    def hello(self, name: str = "Pico") -> PicoState:
        if not isinstance(name, str) or not name.strip():
            raise ValueError("name must be a non-empty string")
        name = name.strip()
        self._state.event_count += 1
        self._state.last_run = datetime.now(timezone.utc).isoformat()
        self._state.message = f"Hello, {name}!"
        self._state.status = "ready"
        return self._state

    def inspect(self) -> PicoState:
        return self._state
