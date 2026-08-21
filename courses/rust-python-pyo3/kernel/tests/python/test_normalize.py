"""Python contract tests for the simple normalize helper."""

from open_engineering_kernel import normalize_identifier


def test_normalize():
    assert normalize_identifier("  OE.PICO.LAMP  ") == "oe.pico.lamp"
    assert normalize_identifier("Already.Lower") == "already.lower"
