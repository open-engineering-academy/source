"""Pico Runtime SPI — the abstraction boundary.

Pico definitions talk to this interface.
Adapters (native, celld, future) implement it.
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from enum import Enum, auto
from typing import Any, Optional

from .pico import PicoState


class RuntimeCapability(Enum):
    INVOKE = auto()
    INSPECT = auto()
    DURABLE_STATE = auto()
    MULTI_IDENTITY = auto()
    SUSPEND = auto()
    RESUME = auto()


class PicoRuntime(ABC):
    """Abstract Pico runtime.

    Operations map to the Memo 7 conceptual SPI:
      deploy / start / invoke / inspect / suspend / resume / delete
    """

    @abstractmethod
    def capabilities(self) -> set[RuntimeCapability]:
        ...

    @abstractmethod
    def deploy(self, pico_id: str) -> PicoState:
        """Ensure a Pico identity exists and is addressable."""
        ...

    @abstractmethod
    def invoke(self, pico_id: str, event: str = "hello", payload: Optional[dict[str, Any]] = None) -> PicoState:
        """Send an event to a Pico and return resulting state."""
        ...

    @abstractmethod
    def inspect(self, pico_id: str) -> PicoState:
        """Return current Pico state without mutating it."""
        ...

    @abstractmethod
    def delete(self, pico_id: str) -> None:
        """Remove a Pico identity and its state from this runtime."""
        ...

    def suspend(self, pico_id: str) -> None:
        """Optional: release execution resources while keeping durable state."""
        raise NotImplementedError("suspend not supported by this runtime")

    def resume(self, pico_id: str) -> PicoState:
        """Optional: reactivate a suspended Pico."""
        raise NotImplementedError("resume not supported by this runtime")
