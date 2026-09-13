#!/usr/bin/env python3
"""OELS validation gate for academy CI.

Runs deterministic OELS-equivalent validation over the nine academy
courses and the shared top-level labs/templates, using the memo14
adapter and per-course bounded workspace roots documented in memo15
(the pinned OELS stdio server cannot initialize the full repository
inside the CI time budget; memo14's adapter is the on-repo semantic
mirror of the same diagnostic contract).

Iteration:
- one pass per course root under ``courses/<slug>/`` for the nine
  courses listed in ``COURSE_ROOTS``;
- one shared pass over top-level ``labs/*`` metadata;
- one shared pass over ``templates/{course,lab,lesson,quiz}/metadata.yaml``.

Per-course reporting classifies each YAML/JSON file into one of five
buckets: adapter-validated, OELS-recognized native OE resource,
intentionally non-OE, excluded (pruned/generated), and unsupported/gap
(OE-recognized without a matching Definition, or an unsupported
extension). A malformed contract fixture is asserted to yield
``MalformedResource`` specifically.

Exit codes:
  0 — every adapter-validated metadata file passes and the malformed
      fixture yields its documented diagnostic code
  1 — one or more supported semantic failures were detected
  2 — driver setup failure (missing definitions, missing fixture)
"""
from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

REPO_ROOT = Path(__file__).resolve().parents[1]
WORK_DIR = REPO_ROOT / "work"
sys.path.insert(0, str(WORK_DIR))

try:
    import yaml
except ModuleNotFoundError:
    print("oels-ci-validate: PyYAML is required (pip install pyyaml)", file=sys.stderr)
    raise SystemExit(2)

from oels_metadata_adapter import UnsupportedShapeError, project_file  # noqa: E402
from oels_metadata_diagnostics import Diagnostic  # noqa: E402
from oels_metadata_validator import (  # noqa: E402
    Registry,
    load_definition,
    validate_resource,
)

DEFINITIONS_DIR = REPO_ROOT / "definitions"
FIXTURES_DIR = REPO_ROOT / "work" / "oels-contract" / "fixtures"
MALFORMED_FIXTURE = FIXTURES_DIR / "malformed.yaml"

COURSE_ROOTS: tuple[str, ...] = (
    "crossplane",
    "durable-picos-celld",
    "engineering-stories",
    "kubernetes",
    "make-the-lamp-nod",
    "manifold",
    "pico",
    "rust-python-pyo3",
    "sandcastle",
)

TEMPLATE_ROOTS: tuple[str, ...] = (
    "templates/course",
    "templates/lab",
    "templates/lesson",
    "templates/quiz",
)

PRUNED_DIR_NAMES = {
    "_site", "_freeze", ".quarto", "node_modules",
    "dist", "build", ".git", "docs",
}
RESOURCE_SUFFIXES = (".yaml", ".yml", ".json")
OE_API_PREFIX = "open-engineering.io/"
ADAPTER_METADATA_NAME = "metadata.yaml"


@dataclass
class BucketCounts:
    adapter_validated: int = 0
    native_oe: int = 0
    non_oe: int = 0
    excluded: int = 0
    unsupported_or_gap: int = 0

    def add(self, other: "BucketCounts") -> None:
        self.adapter_validated += other.adapter_validated
        self.native_oe += other.native_oe
        self.non_oe += other.non_oe
        self.excluded += other.excluded
        self.unsupported_or_gap += other.unsupported_or_gap


@dataclass
class ScopeReport:
    scope: str
    root: Path
    counts: BucketCounts = field(default_factory=BucketCounts)
    failures: list[str] = field(default_factory=list)
    gaps: list[str] = field(default_factory=list)
    template_notes: list[str] = field(default_factory=list)


def _load_registry() -> Registry:
    if not DEFINITIONS_DIR.is_dir():
        print(
            f"oels-ci-validate: definitions dir missing: {DEFINITIONS_DIR}",
            file=sys.stderr,
        )
        raise SystemExit(2)
    registry = Registry()
    for path in sorted(DEFINITIONS_DIR.glob("*.yaml")):
        with path.open("r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        registry.register(load_definition(data, path))
    return registry


def _walk_resources(root: Path) -> Iterable[Path]:
    """Yield every ``*.yaml``/``*.yml``/``*.json`` under ``root``.

    Applies the same pruning OELS applies (``PRUNED_DIR_NAMES`` plus
    any dotfile directory), matching the memo13/memo15 contract.
    """
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if not path.name.endswith(RESOURCE_SUFFIXES):
            continue
        parts = path.relative_to(root).parts
        if any(p in PRUNED_DIR_NAMES or p.startswith(".") for p in parts[:-1]):
            continue
        yield path


def _load_yaml(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def _is_native_oe(data: Any) -> bool:
    if not isinstance(data, dict):
        return False
    api = data.get("apiVersion")
    kind = data.get("kind")
    return isinstance(api, str) and api.startswith(OE_API_PREFIX) and isinstance(
        kind, str
    ) and bool(kind)


def _is_adapter_candidate(path: Path) -> bool:
    parts = path.parts
    if path.name != ADAPTER_METADATA_NAME:
        return False
    if "templates" in parts:
        try:
            role = parts[parts.index("templates") + 1]
        except IndexError:
            return False
        return role in {"course", "lab", "lesson", "quiz"}
    return "courses" in parts or "labs" in parts


def _is_template_metadata(path: Path) -> bool:
    return "templates" in path.parts and path.name == ADAPTER_METADATA_NAME


def _classify_and_validate(
    path: Path, registry: Registry, report: ScopeReport
) -> None:
    rel = path.relative_to(REPO_ROOT)
    if _is_adapter_candidate(path):
        try:
            data = _load_yaml(path)
        except yaml.YAMLError as exc:
            report.counts.adapter_validated += 1
            report.failures.append(
                f"{rel}: [MalformedResource] YAML parse error: {exc}"
            )
            return
        _handle_adapter_candidate(path, rel, data, registry, report)
        return
    docs = _safe_load_all(path)
    if docs is None:
        report.counts.non_oe += 1
        return
    if any(_is_native_oe(d) for d in docs):
        for doc in docs:
            if _is_native_oe(doc):
                _handle_native_oe(rel, doc, registry, report)
        return
    report.counts.non_oe += 1


def _safe_load_all(path: Path) -> list[Any] | None:
    """Load all YAML docs (or a single JSON doc). Returns None on parse error."""
    try:
        if path.suffix == ".json":
            with path.open("r", encoding="utf-8") as f:
                import json
                return [json.load(f)]
        with path.open("r", encoding="utf-8") as f:
            return [d for d in yaml.safe_load_all(f) if d is not None]
    except (yaml.YAMLError, ValueError):
        return None


def _handle_adapter_candidate(
    path: Path,
    rel: Path,
    data: Any,
    registry: Registry,
    report: ScopeReport,
) -> None:
    try:
        result = project_file(path, data)
    except UnsupportedShapeError as exc:
        report.counts.adapter_validated += 1
        report.failures.append(f"{rel}: [MalformedResource] projection failed: {exc}")
        return
    diagnostics = validate_resource(result.projected, registry)
    report.counts.adapter_validated += 1
    if _is_template_metadata(path):
        expected = {"MalformedIdentifier"}
        got = {d.code for d in diagnostics}
        unexpected = [d for d in diagnostics if d.code not in expected]
        for d in unexpected:
            report.failures.append(f"{rel}: {d.format()}")
        if got == expected and not unexpected:
            report.template_notes.append(
                f"{rel}: expected MalformedIdentifier (placeholder <slug>) present"
            )
        return
    for d in diagnostics:
        report.failures.append(f"{rel}: {d.format()}")


def _handle_native_oe(
    rel: Path, data: Any, registry: Registry, report: ScopeReport
) -> None:
    diagnostics = validate_resource(data, registry)
    api_version = data.get("apiVersion", "")
    kind = data.get("kind", "")
    if registry.find(api_version, kind) is None:
        report.counts.unsupported_or_gap += 1
        report.gaps.append(
            f"{rel}: [UnknownDefinition] no Definition for apiVersion={api_version!r} "
            f"kind={kind!r} (documented gap; see memo13 gap #4)"
        )
        return
    report.counts.native_oe += 1
    for d in diagnostics:
        report.failures.append(f"{rel}: {d.format()}")


def _count_excluded(root: Path) -> int:
    """Count YAML/JSON files pruned by OELS-equivalent discovery under ``root``."""
    excluded = 0
    for path in root.rglob("*"):
        if not path.is_file() or not path.name.endswith(RESOURCE_SUFFIXES):
            continue
        parts = path.relative_to(root).parts
        if any(p in PRUNED_DIR_NAMES or p.startswith(".") for p in parts[:-1]):
            excluded += 1
    return excluded


def _run_scope(scope: str, root: Path, registry: Registry) -> ScopeReport:
    report = ScopeReport(scope=scope, root=root)
    if not root.is_dir():
        return report
    for path in _walk_resources(root):
        _classify_and_validate(path, registry, report)
    report.counts.excluded = _count_excluded(root)
    return report


def _assert_malformed_fixture(registry: Registry) -> list[str]:
    if not MALFORMED_FIXTURE.is_file():
        return [f"malformed fixture missing: {MALFORMED_FIXTURE}"]
    try:
        with MALFORMED_FIXTURE.open("r", encoding="utf-8") as f:
            yaml.safe_load(f)
    except yaml.YAMLError:
        return []
    diagnostics = validate_resource(_load_yaml(MALFORMED_FIXTURE), registry)
    codes = {d.code for d in diagnostics}
    if "MalformedResource" in codes:
        return []
    return [
        f"malformed fixture did not yield MalformedResource (got={sorted(codes)!r}); "
        "fixture must trip the documented diagnostic code"
    ]


def _print_report(reports: list[ScopeReport], totals: BucketCounts) -> None:
    print("=" * 72)
    print("OELS CI validation report")
    print("=" * 72)
    for r in reports:
        c = r.counts
        rel_root = r.root.relative_to(REPO_ROOT) if r.root.exists() else r.root
        print(
            f"[{r.scope}] root={rel_root} "
            f"adapter={c.adapter_validated} native-oe={c.native_oe} "
            f"non-oe={c.non_oe} excluded={c.excluded} gap={c.unsupported_or_gap}"
        )
        for note in r.template_notes:
            print(f"  note: {note}")
        for gap in r.gaps:
            print(f"  gap:  {gap}")
        for fail in r.failures:
            print(f"  FAIL: {fail}")
    print("-" * 72)
    print(
        f"totals: adapter={totals.adapter_validated} native-oe={totals.native_oe} "
        f"non-oe={totals.non_oe} excluded={totals.excluded} "
        f"gap={totals.unsupported_or_gap}"
    )


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--fail-on-gap",
        action="store_true",
        help="Also fail when documented gap diagnostics (UnknownDefinition on "
        "native OE resources) are reported.",
    )
    args = ap.parse_args(argv)

    registry = _load_registry()
    reports: list[ScopeReport] = []

    for slug in COURSE_ROOTS:
        reports.append(_run_scope(f"course:{slug}", REPO_ROOT / "courses" / slug, registry))

    reports.append(_run_scope("shared:labs", REPO_ROOT / "labs", registry))

    for tpl_rel in TEMPLATE_ROOTS:
        reports.append(_run_scope(f"shared:{tpl_rel}", REPO_ROOT / tpl_rel, registry))

    totals = BucketCounts()
    for r in reports:
        totals.add(r.counts)

    fixture_failures = _assert_malformed_fixture(registry)
    all_failures = [
        f"[{r.scope}] {msg}" for r in reports for msg in r.failures
    ] + [f"[fixture] {msg}" for msg in fixture_failures]

    if args.fail_on_gap:
        all_failures += [
            f"[{r.scope}] gap-as-failure: {g}"
            for r in reports for g in r.gaps
        ]

    _print_report(reports, totals)

    if all_failures:
        print("-" * 72)
        print(f"FAILURES ({len(all_failures)}):")
        for f in all_failures:
            print(f"  {f}")
        print("oels-ci-validate: FAIL")
        return 1

    print("oels-ci-validate: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
