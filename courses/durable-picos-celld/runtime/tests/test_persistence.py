"""Persistence tests — the Memo 7 acceptance gate.

invoke → invoke → restart runtime → invoke
Expected event_count: 3
"""

from pathlib import Path
from oe_pico_runtime import DurableRuntime, RuntimeCapability


def test_state_survives_restart(tmp_path):
    db = tmp_path / "durable.db"

    rt1 = DurableRuntime(db)
    assert RuntimeCapability.DURABLE_STATE in rt1.capabilities()
    rt1.deploy("hello-pico")
    rt1.invoke("hello-pico", "hello", {"name": "One"})
    rt1.invoke("hello-pico", "hello", {"name": "Two"})
    assert rt1.inspect("hello-pico").event_count == 2
    rt1.close()  # process dies

    # New process, same durable store
    rt2 = DurableRuntime.reopen(db)
    s = rt2.inspect("hello-pico")
    assert s.event_count == 2
    assert s.message == "Hello, Two!"

    s3 = rt2.invoke("hello-pico", "hello", {"name": "Three"})
    assert s3.event_count == 3
    assert s3.message == "Hello, Three!"
    rt2.close()


def test_suspend_resume_keeps_state(tmp_path):
    db = tmp_path / "hibernation.db"
    rt = DurableRuntime(db)
    rt.deploy("hello-pico")
    rt.invoke("hello-pico", "hello", {"name": "A"})
    rt.suspend("hello-pico")  # drop memory, keep SQLite
    s = rt.resume("hello-pico")
    assert s.event_count == 1
    rt.close()


def test_multi_identity_survives_restart(tmp_path):
    db = tmp_path / "multi.db"
    rt1 = DurableRuntime(db)
    for i in range(7):
        rt1.invoke("alice", "hello", {"name": "Alice"})
    for i in range(2):
        rt1.invoke("bob", "hello", {"name": "Bob"})
    rt1.close()

    rt2 = DurableRuntime.reopen(db)
    assert rt2.inspect("alice").event_count == 7
    assert rt2.inspect("bob").event_count == 2
    rt2.close()
