"""Deterministic academy-metadata → OE-shape adapter.

Projects a flat academy ``metadata.yaml`` (as authored today under
``courses/``, ``labs/``, and ``templates/{course,lab,lesson,quiz}/``) into the
OE resource shape recognised by the Open Engineering Language Server (OELS):
``apiVersion``/``kind``/``metadata``/``spec``.

The projection is the mapping the ``memo13.md`` inventory calls out
explicitly: ``id`` → ``metadata.name`` by replacing dots with dashes, the
academy ``id`` is preserved verbatim as ``metadata.id`` so cross-course and
cross-lab links are not rewritten, and every other top-level field flows into
``spec`` unchanged. See ``memo14.md`` for the classification matrix.

This module never edits an existing file. It performs projection in memory
so the flat academy metadata files stay authoritative on disk.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

DEFAULT_API_VERSION = "open-engineering.io/v1alpha1"
COURSE_METADATA_FIELDS_RESERVED = {"id", "slug"}
LAB_METADATA_FIELDS_RESERVED = {"id"}
LESSON_METADATA_FIELDS_RESERVED = {"id"}
QUIZ_METADATA_FIELDS_RESERVED = {"id"}


class UnsupportedShapeError(ValueError):
    """Raised when a metadata document is not a mapping or has no id."""


@dataclass(frozen=True)
class ProjectionResult:
    kind: str  # Course | Lab | Lesson | Quiz
    projected: dict[str, Any]
    source_path: Path


def classify_metadata_path(path: Path) -> str:
    """Decide which OE ``kind`` a metadata.yaml file projects to."""

    parts = path.parts
    if "templates" in parts:
        # templates/{course,lab,lesson,quiz}/metadata.yaml
        try:
            idx = parts.index("templates")
            role = parts[idx + 1]
        except (IndexError, ValueError) as exc:
            raise UnsupportedShapeError(
                f"cannot classify template metadata path: {path}"
            ) from exc
        role_to_kind = {
            "course": "Course",
            "lab": "Lab",
            "lesson": "Lesson",
            "quiz": "Quiz",
        }
        if role not in role_to_kind:
            raise UnsupportedShapeError(
                f"unknown templates/<role> for {path}: role={role!r}"
            )
        return role_to_kind[role]
    if "labs" in parts:
        return "Lab"
    if "courses" in parts:
        return "Course"
    raise UnsupportedShapeError(
        f"metadata path does not fall under courses/, labs/, or templates/: {path}"
    )


def project_metadata_to_oe(
    data: Any,
    kind: str,
    api_version: str = DEFAULT_API_VERSION,
) -> dict[str, Any]:
    """Wrap flat academy metadata in the OE apiVersion/kind/metadata/spec envelope."""

    if not isinstance(data, dict):
        raise UnsupportedShapeError(
            f"metadata root must be a mapping, got {type(data).__name__}"
        )

    raw_id = data.get("id")
    if not isinstance(raw_id, str) or not raw_id:
        raise UnsupportedShapeError("metadata.id is required (flat academy schema)")

    projected_name = raw_id.replace(".", "-")

    reserved_map = {
        "Course": COURSE_METADATA_FIELDS_RESERVED,
        "Lab": LAB_METADATA_FIELDS_RESERVED,
        "Lesson": LESSON_METADATA_FIELDS_RESERVED,
        "Quiz": QUIZ_METADATA_FIELDS_RESERVED,
    }
    reserved = reserved_map[kind]

    metadata_block: dict[str, Any] = {
        "name": projected_name,
        "id": raw_id,
    }
    if "slug" in data and isinstance(data["slug"], str):
        metadata_block["slug"] = data["slug"]

    spec_block = {
        key: value for key, value in data.items() if key not in reserved
    }

    return {
        "apiVersion": api_version,
        "kind": kind,
        "metadata": metadata_block,
        "spec": spec_block,
    }


def project_file(path: Path, data: Any) -> ProjectionResult:
    kind = classify_metadata_path(path)
    projected = project_metadata_to_oe(data, kind)
    return ProjectionResult(kind=kind, projected=projected, source_path=path)
