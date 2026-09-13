"""Schema walker for the OELS-equivalent validator.

Split out of ``oels_metadata_validator.py`` to keep both files under the
codebase's 150-line editing convention. Emits ``UnknownProperty``,
``MissingRequiredProperty``, ``IncorrectType``, and ``InvalidEnumValue``
diagnostics with the same codes the Open Engineering Language Server uses.
"""

from __future__ import annotations

from typing import Any

from oels_metadata_diagnostics import Diagnostic

PRIMITIVE_MATCHERS = {
    "string": lambda v: isinstance(v, str),
    "boolean": lambda v: isinstance(v, bool),
    "number": lambda v: isinstance(v, (int, float)) and not isinstance(v, bool),
    "integer": lambda v: isinstance(v, int) and not isinstance(v, bool),
    "null": lambda v: v is None,
}


def _describe(value: Any) -> str:
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    if isinstance(value, dict):
        return "object"
    return type(value).__name__


def walk_object(
    node: Any, schema: dict[str, Any], path: str, out: list
) -> None:
    schema_type = schema.get("type")
    enum = schema.get("enum")
    if enum is not None:
        if node not in enum:
            allowed = ", ".join(repr(v) for v in enum)
            out.append(
                Diagnostic(
                    "InvalidEnumValue",
                    f"value {node!r} is not one of the allowed values: {allowed}",
                    path,
                )
            )
        return
    if schema_type == "object":
        if not isinstance(node, dict):
            out.append(
                Diagnostic(
                    "IncorrectType",
                    f"expected object, got {_describe(node)}",
                    path,
                )
            )
            return
        properties = schema.get("properties", {}) or {}
        required = schema.get("required", []) or []
        additional = schema.get("additionalProperties", False)
        for req in required:
            if req not in node:
                out.append(
                    Diagnostic(
                        "MissingRequiredProperty",
                        f'missing required property "{req}"',
                        path,
                    )
                )
        for key, value in node.items():
            child_path = f"{path}.{key}" if path else key
            if key in properties:
                walk_object(value, properties[key], child_path, out)
                continue
            if additional is True:
                continue
            out.append(
                Diagnostic(
                    "UnknownProperty",
                    f'unknown property "{key}"',
                    path or "<root>",
                )
            )
        return
    if schema_type == "array":
        if not isinstance(node, list):
            out.append(
                Diagnostic(
                    "IncorrectType",
                    f"expected array, got {_describe(node)}",
                    path,
                )
            )
            return
        items_schema = schema.get("items")
        if isinstance(items_schema, dict):
            for i, item in enumerate(node):
                walk_object(item, items_schema, f"{path}[{i}]", out)
        return
    if isinstance(schema_type, str) and schema_type in PRIMITIVE_MATCHERS:
        matcher = PRIMITIVE_MATCHERS[schema_type]
        if not matcher(node):
            out.append(
                Diagnostic(
                    "IncorrectType",
                    f"expected {schema_type}, got {_describe(node)}",
                    path or "<root>",
                )
            )
