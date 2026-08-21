"""Native (in-process, volatile) Pico runtime.

State lives only in memory. Process death loses everything.
Useful as a baseline and for unit tests.
"""

from __future__ import annotations

from typing import Any, Optional

from .pico import HelloPico, PicoState
from .spi import PicoRuntime, RuntimeCapability


class NativeRuntime(PicoRuntime):
    def __init__(self) -> None:
        self._picos: dict[str, HelloPico] = {}

    def capabilities(self) -> set[RuntimeCapability]:
        return {
            RuntimeCapability.INVOKE,
            RuntimeCapability.INSPECT,
            RuntimeCapability.MULTI_IDENTITY,
        }

    def deploy(self, pico_id: str) -> PicoState:
        if pico_id not in self._picos:
            self._picos[pico_id] = HelloPico(pico_id)
        return self._picos[pico_id].inspect()

    def invoke(self, pico_id: str, event: str = "hello", payload: Optional[dict[str, Any]] = None) -> PicoState:
        if pico_id not in self._picos:
            self.deploy(pico_id)
        payload = payload or {}
        if event != "hello":
            raise ValueError(f"unsupported event: {event}")
        name = payload.get("name", "Pico")
        return self._picos[pico_id].hello(name)

    def inspect(self, pico_id: str) -> PicoState:
        if pico_id not in self._picos:
            raise KeyError(f"pico not found: {pico_id}")
        return self._picos[pico_id].inspect()

    def delete(self, pico_id: str) -> None:
        self._picos.pop(pico_id, None)
