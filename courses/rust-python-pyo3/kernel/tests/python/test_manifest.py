"""Python contract tests for manifest validation."""

from open_engineering_kernel import validate_manifest


def test_valid_minimal():
    result = validate_manifest({"kind": "pico", "name": "lamp"})
    assert result["valid"] is True
    assert result["errors"] == []
    assert result["manifest"]["kind"] == "pico"
    assert result["manifest"]["name"] == "lamp"
    assert result["manifest"]["identifier"] == "oe.pico.lamp"


def test_valid_with_version():
    result = validate_manifest(
        {"kind": "pico", "name": "lamp", "version": "1.0.0"}
    )
    assert result["valid"] is True
    assert result["manifest"]["version"] == "1.0.0"


def test_missing_kind():
    result = validate_manifest({"name": "lamp"})
    assert result["valid"] is False
    assert any("kind" in e for e in result["errors"])
    assert result["manifest"] is None


def test_missing_name():
    result = validate_manifest({"kind": "pico"})
    assert result["valid"] is False
    assert any("name" in e for e in result["errors"])


def test_explicit_identifier():
    result = validate_manifest(
        {
            "kind": "pico",
            "name": "lamp",
            "identifier": "oe.pico.lamp",
        }
    )
    assert result["valid"] is True
    assert result["manifest"]["identifier"] == "oe.pico.lamp"


def test_academy_course_style_identifier():
    result = validate_manifest(
        {
            "kind": "course",
            "name": "pico",
            "identifier": "oe.course.pico",
        }
    )
    assert result["valid"] is True
    assert result["manifest"]["identifier"] == "oe.course.pico"
