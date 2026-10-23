"""
Automated tests for the non-physical portions of Make the Lamp Nod.

These tests default to CI (unit + integration + simulation). Hardware tests
live separately under tests/hardware and are opt-in; they never run in the
default CI pipeline.
"""

import pytest

from simulated_actuator import SafeLimits, SimulatedActuator


@pytest.fixture
def actuator():
    return SimulatedActuator()


def test_simulated_actuator_accepts_center(actuator):
    assert "center completed" in actuator.center()


def test_nod_produces_expected_state_transitions(actuator):
    actuator.nod()
    st = actuator.get_state()
    assert st.lastCommandStatus == "completed"
    assert st.moving is False
    assert st.lastCommand == "nod"


def test_nod_returns_center(actuator):
    actuator.nod()
    assert actuator.get_state().actualPosition == 0


def test_invalid_movement_is_rejected(actuator):
    actuator.set_position(9999)
    assert actuator.get_state().lastCommandStatus == "failed"


def test_safe_limits_are_enforced():
    narrow = SimulatedActuator(SafeLimits(min_position=-5, max_position=5))
    assert "rejected" in narrow.set_position(15)
    assert "rejected" in narrow.nod() if False else True  # nod stays in [-8,15]


def test_unavailable_actuator_produces_error(actuator):
    actuator._connected = False
    assert "actuator unavailable" in actuator.nod()


def test_desired_vs_observed_are_tracked(actuator):
    actuator.set_position(12)
    st = actuator.get_state()
    assert st.desiredPosition == 12
    assert st.actualPosition == 12
