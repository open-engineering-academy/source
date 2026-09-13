"""OELS-equivalent schema validator for projected academy metadata.

Mirrors the subset of the Open Engineering Language Server (OELS) validation
contract that applies to the four academy Definitions (Course, Lab, Lesson,
Quiz). Emits diagnostics with the same codes OELS surfaces to editor clients
so the adapter path is auditable against the same semantics:

- ``MalformedResource`` — YAML/JSON parse failure.
- ``MalformedIdentifier`` — ``metadata.name`` does not match DNS-1123.
- ``UnknownDefinition`` — no Definition targets the ``apiVersion``/``kind``.
- ``MissingRequiredProperty`` — required property absent from an object.
- ``UnknownProperty`` — property not declared and ``additionalProperties: false``.
- ``IncorrectType`` — value type does not match the schema.
- ``InvalidEnumValue`` — value not in the schema's ``enum``.

The validator is deliberately structural: it does not re-implement OELS's
cross-document reference resolver, so unresolved reference diagnostics are
raised only when a fixture is authored to test that path explicitly.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

from oels_metadata_diagnostics import Diagnostic
from oels_metadata_validator_walk import walk_object

IDENTIFIER_REGEX = re.compile(r"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$")
DEFINITION_API_PREFIX = "open-engineering.io/"


@dataclass
class Definition:
    api_version: str
    kind: str
    name: str
    target_api_version: str
    target_kind: str
    schema: dict[str, Any]
    source: Path

    @property
    def target_key(self) -> tuple[str, str]:
        return (self.target_api_version, self.target_kind)


@dataclass
class Registry:
    by_target: dict[tuple[str, str], Definition] = field(default_factory=dict)

    def register(self, defn: Definition) -> None:
        self.by_target[defn.target_key] = defn

    def find(self, api_version: str, kind: str) -> Definition | None:
        return self.by_target.get((api_version, kind))


def load_definition(data: Any, source: Path) -> Definition:
    if not isinstance(data, dict):
        raise ValueError(f"Definition {source} must be a mapping at root")
    api_version = data.get("apiVersion")
    if not isinstance(api_version, str) or not api_version.startswith(
        DEFINITION_API_PREFIX
    ):
        raise ValueError(f"Definition {source}: apiVersion must start with {DEFINITION_API_PREFIX}")
    if data.get("kind") != "Definition":
        raise ValueError(f"Definition {source}: kind must be 'Definition'")
    metadata = data.get("metadata") or {}
    name = metadata.get("name")
    if not isinstance(name, str) or not name:
        raise ValueError(f"Definition {source}: metadata.name is required")
    spec = data.get("spec") or {}
    target = spec.get("target") or {}
    target_api = target.get("apiVersion")
    target_kind = target.get("kind")
    if not isinstance(target_api, str) or not target_api:
        raise ValueError(f"Definition {source}: spec.target.apiVersion is required")
    if not isinstance(target_kind, str) or not target_kind:
        raise ValueError(f"Definition {source}: spec.target.kind is required")
    schema = spec.get("schema") or {}
    if not isinstance(schema, dict):
        raise ValueError(f"Definition {source}: spec.schema must be a mapping")
    return Definition(
        api_version=api_version,
        kind="Definition",
        name=name,
        target_api_version=target_api,
        target_kind=target_kind,
        schema=schema,
        source=source,
    )


def validate_resource(
    resource: Any, registry: Registry
) -> list[Diagnostic]:
    """Validate an already-parsed OE-shape resource against the registry."""

    diags: list[Diagnostic] = []
    if not isinstance(resource, dict):
        diags.append(
            Diagnostic("MalformedResource", "resource root must be a mapping", "")
        )
        return diags
    api_version = resource.get("apiVersion")
    kind = resource.get("kind")
    if not isinstance(api_version, str) or not api_version.startswith(
        DEFINITION_API_PREFIX
    ):
        # Silently ignored by OELS — not an OE resource.
        return diags
    if not isinstance(kind, str) or not kind:
        return diags
    metadata = resource.get("metadata")
    if isinstance(metadata, dict):
        name = metadata.get("name")
        if isinstance(name, str) and not IDENTIFIER_REGEX.match(name):
            diags.append(
                Diagnostic(
                    "MalformedIdentifier",
                    f'identifier "{name}" is not a valid Open Engineering identifier',
                    "metadata.name",
                )
            )
    definition = registry.find(api_version, kind)
    if definition is None:
        diags.append(
            Diagnostic(
                "UnknownDefinition",
                f'no Definition targets apiVersion="{api_version}" kind="{kind}"',
                "",
            )
        )
        return diags
    walk_object(resource, definition.schema, "", diags)
    return diags


def iter_all_diagnostics(
    entries: Iterable[tuple[Path, Any]], registry: Registry
) -> dict[str, list[Diagnostic]]:
    result: dict[str, list[Diagnostic]] = {}
    for path, resource in entries:
        result[str(path)] = validate_resource(resource, registry)
    return result
