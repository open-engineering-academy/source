"""Python contract tests for Identifier (Academy oe.* conventions)."""

import pytest

from open_engineering_kernel import Identifier, InvalidIdentifierError


def test_parse_academy_compact():
    ident = Identifier.parse("oe.course.pico")
    assert ident.namespace == "oe"
    assert ident.kind == "course"
    assert ident.name == "pico"
    assert ident.as_str() == "oe.course.pico"
    assert str(ident) == "oe.course.pico"


def test_parse_lab_style():
    ident = Identifier.parse("oe.lab.hello-pico")
    assert ident.kind == "lab"
    assert ident.name == "hello-pico"


def test_parse_full_namespace():
    ident = Identifier.parse("open-engineering.pico.lamp")
    assert ident.namespace == "open-engineering"
    assert ident.kind == "pico"
    assert ident.name == "lamp"


def test_parse_normalizes_case_and_whitespace():
    ident = Identifier.parse("  OE.Course.Pico  ")
    assert ident.as_str() == "oe.course.pico"


def test_construct_from_parts():
    ident = Identifier("oe", "course", "pico")
    assert ident.as_str() == "oe.course.pico"


def test_equality():
    a = Identifier.parse("oe.course.pico")
    b = Identifier("oe", "course", "pico")
    assert a == b


def test_reject_wrong_segment_count():
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("a.b")
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("a.b.c.d")
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("oe.lesson.pico.01-introduction")
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("")


def test_reject_invalid_characters():
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("open_engineering.pico.lamp")
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("open engineering.pico.lamp")


def test_reject_hyphen_edges():
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("-oe.pico.lamp")
    with pytest.raises(InvalidIdentifierError):
        Identifier.parse("oe-.pico.lamp")
