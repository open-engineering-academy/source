"""
Actuator contract + simulated implementation.

Simulation-before-physics: the SimulatedActuator implements the same logical
actuator contract as a future DynamixelAX12AActuator. Every capability is
therefore testable without hardware, in CI, and by learners without a lamp.

Consumers request capabilities (nod, center, stop, set-position). They never
issue raw register writes.
"""

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Optional


@dataclass
class ActuatorState:
    desiredPosition: int = 0
    actualPosition: int = 0
    moving: bool = False
    torqueEnabled: bool = True
    connected: bool = True
    temperature: Optional[float] = None
    voltage: Optional[float] = None
    lastCommand: Optional[str] = None
    lastCommandStatus: Optional[str] = None  # requested|accepted|executing|completed|failed
    lastUpdated: Optional[str] = None


class SafeLimits:
    def __init__(self, min_position=-30, max_position=30):
        self.min_position = min_position
        self.max_position = max_position

    def within(self, position: int) -> bool:
        return self.min_position <= position <= self.max_position


class ActuatorContract:
    """The logical actuator contract both adapters implement."""

    def nod(self) -> str: ...
    def center(self) -> str: ...
    def stop(self) -> str: ...
    def set_position(self, degrees: int) -> str: ...
    def get_state(self) -> ActuatorState: ...


class SimulatedActuator(ActuatorContract):
    def __init__(self, limits: SafeLimits | None = None):
        self.limits = limits or SafeLimits()
        self.state = ActuatorState()
        self._connected = True

    def _now(self) -> str:
        return datetime.now(timezone.utc).isoformat()

    def nod(self) -> str:
        if not self._connected:
            self.state.lastCommandStatus = "failed"
            return "nod failed: actuator unavailable"
        if not self.limits.within(self.state.actualPosition):
            self.state.lastCommandStatus = "failed"
            return "command rejected: outside configured safe limits"
        self.state.lastCommand = "nod"
        self.state.lastCommandStatus = "executing"
        self.state.moving = True
        # center -> down -> up -> center
        for pos in (0, 15, -8, 0):
            self.state.desiredPosition = pos
            self.state.actualPosition = pos
        self.state.moving = False
        self.state.lastCommandStatus = "completed"
        self.state.lastUpdated = self._now()
        return "nod completed"

    def center(self) -> str:
        self.state.lastCommand = "center"
        self.state.desiredPosition = 0
        self.state.actualPosition = 0
        self.state.lastCommandStatus = "completed"
        self.state.lastUpdated = self._now()
        return "center completed"

    def stop(self) -> str:
        self.state.lastCommand = "stop"
        self.state.moving = False
        self.state.lastCommandStatus = "completed"
        self.state.lastUpdated = self._now()
        return "stop completed"

    def set_position(self, degrees: int) -> str:
        if not self.limits.within(degrees):
            self.state.lastCommandStatus = "failed"
            return f"command rejected: outside configured safe limits ({degrees})"
        self.state.lastCommand = "set-position"
        self.state.desiredPosition = degrees
        self.state.actualPosition = degrees
        self.state.lastCommandStatus = "completed"
        self.state.lastUpdated = self._now()
        return "set-position completed"

    def get_state(self) -> ActuatorState:
        return self.state
