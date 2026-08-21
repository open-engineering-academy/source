"""Runtime contract tests — same contract for Native and Durable."""

import pytest
from oe_pico_runtime import NativeRuntime, DurableRuntime, RuntimeCapability


@pytest.fixture(params=["native", "durable"])
def runtime(request, tmp_path):
    if request.param == "native":
        yield NativeRuntime()
    else:
        rt = DurableRuntime(tmp_path / "picos.db")
        yield rt
        rt.close()


def test_deploy_and_inspect(runtime):
    s = runtime.deploy("hello-pico")
    assert s.id == "hello-pico"
    assert s.event_count == 0
    assert runtime.inspect("hello-pico").event_count == 0


def test_invoke_hello(runtime):
    runtime.deploy("hello-pico")
    s = runtime.invoke("hello-pico", "hello", {"name": "Willem"})
    assert s.message == "Hello, Willem!"
    assert s.event_count == 1


def test_multiple_invocations(runtime):
    runtime.deploy("p1")
    runtime.invoke("p1", "hello", {"name": "A"})
    runtime.invoke("p1", "hello", {"name": "B"})
    assert runtime.inspect("p1").event_count == 2


def test_multi_identity_isolation(runtime):
    runtime.deploy("alice")
    runtime.deploy("bob")
    for _ in range(3):
        runtime.invoke("alice", "hello", {"name": "Alice"})
    runtime.invoke("bob", "hello", {"name": "Bob"})
    assert runtime.inspect("alice").event_count == 3
    assert runtime.inspect("bob").event_count == 1


def test_delete(runtime):
    runtime.deploy("tmp")
    runtime.invoke("tmp", "hello", {"name": "X"})
    runtime.delete("tmp")
    with pytest.raises(KeyError):
        runtime.inspect("tmp")


def test_capabilities_include_core(runtime):
    caps = runtime.capabilities()
    assert RuntimeCapability.INVOKE in caps
    assert RuntimeCapability.INSPECT in caps
