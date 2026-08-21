"""Unit tests: Pico behaviour independent of runtime."""

from oe_pico_runtime import HelloPico
import pytest


def test_initial_state():
    p = HelloPico("hello-pico")
    s = p.inspect()
    assert s.id == "hello-pico"
    assert s.event_count == 0
    assert s.message == ""


def test_hello_increments():
    p = HelloPico()
    s1 = p.hello("Willem")
    assert s1.event_count == 1
    assert s1.message == "Hello, Willem!"
    assert s1.last_run is not None
    s2 = p.hello("Ada")
    assert s2.event_count == 2
    assert s2.message == "Hello, Ada!"


def test_hello_rejects_empty_name():
    p = HelloPico()
    with pytest.raises(ValueError):
        p.hello("")
    with pytest.raises(ValueError):
        p.hello("   ")
