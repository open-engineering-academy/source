#!/usr/bin/env python3
"""Reproducible internal-link checker for academy ``*.qmd``/``*.md`` files.

Walks the repository, resolves inline markdown links ``[text](target)``
relative to the containing file (or repository root for absolute paths),
and classifies each resolved target as:

- OK — target exists on disk, or the ``.html`` form has a sibling ``.qmd``.
- ERROR — target does not exist on disk at all (hard-broken link).
- WARNING — the target is an existing directory with no ``index.qmd`` or
  ``index.html``. The on-disk resource is present, but the rendered site
  will 404 on the directory URL. Reported separately so that resource
  dirs (``downloads/``, ``solution/``, ``screenshots/``) are not
  conflated with genuinely missing files.

Skips protocol links (``http(s):``, ``mailto:``, ``tel:``, ``data:``),
same-page anchors (``#...``), inline-code spans, fenced code blocks,
and the pruned build/output directories listed in ``PRUNED_DIR_NAMES``.
Stdlib only; mirrors the exit-code and output conventions of
``scripts/oels_ci_validate.py``.

Exit codes:
  0 — no errors (warnings may be present unless ``--strict``)
  1 — one or more ERRORs (or WARNINGs under ``--strict``)
  2 — setup failure (bad ``--root``)
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO_ROOT_DEFAULT = Path(__file__).resolve().parents[1]

PRUNED_DIR_NAMES: frozenset[str] = frozenset({
    "_site", "_freeze", ".quarto", "node_modules",
    "dist", "build", ".git", "docs", "work",
    "archive", "templates",
})

PRUNED_RELATIVE_DIRS: frozenset[str] = frozenset({
    "shared/includes",
})

SOURCE_SUFFIXES: tuple[str, ...] = (".qmd", ".md")

SKIP_PREFIXES: tuple[str, ...] = (
    "http://", "https://", "mailto:", "tel:", "data:",
    "ftp://", "ftps://", "ssh://", "git://", "javascript:",
)

LINK_RE = re.compile(r"!?\[([^\]]*)\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")

FENCE_RE = re.compile(r"^(\s*)(`{3,}|~{3,})")
INLINE_CODE_RE = re.compile(r"`[^`\n]*`")


def _walk_sources(root: Path):
    for path in sorted(root.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix not in SOURCE_SUFFIXES:
            continue
        rel = path.relative_to(root)
        rel_parts = rel.parts
        if any(p in PRUNED_DIR_NAMES or p.startswith(".") for p in rel_parts[:-1]):
            continue
        rel_posix = rel.as_posix()
        if any(
            rel_posix.startswith(d + "/") for d in PRUNED_RELATIVE_DIRS
        ):
            continue
        yield path


def _strip_code(line: str, in_fence: bool) -> str:
    if in_fence:
        return ""
    return INLINE_CODE_RE.sub("", line)


def _resolve(target: str, source_dir: Path, repo_root: Path) -> Path:
    if target.startswith("/"):
        return (repo_root / target.lstrip("/")).resolve()
    return (source_dir / target).resolve()


def _classify(resolved: Path, trailing_slash: bool) -> str:
    """Return ``"ok"``, ``"warning"``, or ``"error"`` for a resolved target.

    - ``"ok"`` — file exists, or ``.html`` form has a sibling ``.qmd``,
      or the directory has an ``index.qmd``/``index.html`` page.
    - ``"warning"`` — target resolves to an existing directory with no
      ``index.qmd``/``index.html`` (resource dir without a page target).
    - ``"error"`` — target does not exist on disk.
    """
    if trailing_slash:
        if resolved.is_dir():
            if (resolved / "index.qmd").exists() or (resolved / "index.html").exists():
                return "ok"
            return "warning"
        return "error"
    if resolved.exists():
        if resolved.is_dir():
            if (resolved / "index.qmd").exists() or (resolved / "index.html").exists():
                return "ok"
            return "warning"
        return "ok"
    if resolved.suffix == ".html":
        if resolved.with_suffix(".qmd").exists():
            return "ok"
    return "error"


def _check_file(
    path: Path, repo_root: Path
) -> tuple[int, list[tuple[int, str, Path, str]]]:
    findings: list[tuple[int, str, Path, str]] = []
    checked = 0
    source_dir = path.parent
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return checked, findings
    in_fence = False
    fence_marker = ""
    for lineno, raw_line in enumerate(text.splitlines(), start=1):
        fence_match = FENCE_RE.match(raw_line)
        if fence_match:
            marker = fence_match.group(2)[0]
            if not in_fence:
                in_fence = True
                fence_marker = marker
            elif fence_marker and raw_line.lstrip().startswith(fence_marker * 3):
                in_fence = False
                fence_marker = ""
            continue
        line = _strip_code(raw_line, in_fence)
        if not line:
            continue
        for match in LINK_RE.finditer(line):
            target = match.group(2).strip()
            if not target or target.startswith("#"):
                continue
            if target.lower().startswith(SKIP_PREFIXES):
                continue
            cleaned = target.split("#", 1)[0].split("?", 1)[0]
            if not cleaned:
                continue
            checked += 1
            trailing_slash = cleaned.endswith("/")
            resolved = _resolve(cleaned, source_dir, repo_root)
            severity = _classify(resolved, trailing_slash)
            if severity != "ok":
                findings.append((lineno, target, resolved, severity))
    return checked, findings


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "--root", type=Path, default=REPO_ROOT_DEFAULT,
        help="Repository root to scan (default: parent of scripts/).",
    )
    ap.add_argument(
        "--quiet", action="store_true",
        help="Suppress the per-run summary; print findings only.",
    )
    ap.add_argument(
        "--strict", action="store_true",
        help="Treat WARNINGs (existing dirs without index.qmd/html) as errors.",
    )
    args = ap.parse_args(argv)

    repo_root = args.root.resolve()
    if not repo_root.is_dir():
        print(f"verify-links: root is not a directory: {repo_root}", file=sys.stderr)
        return 2

    total_checked = 0
    total_errors = 0
    total_warnings = 0
    for source in _walk_sources(repo_root):
        rel = source.relative_to(repo_root)
        checked, findings = _check_file(source, repo_root)
        total_checked += checked
        for lineno, target, resolved, severity in findings:
            label = "ERROR broken link" if severity == "error" else "WARNING dir without index"
            print(f"{rel}:{lineno}: {label} -> {target} (resolved: {resolved})")
            if severity == "error":
                total_errors += 1
            else:
                total_warnings += 1

    if not args.quiet:
        print(
            f"verify-links: checked={total_checked} "
            f"errors={total_errors} warnings={total_warnings}"
        )
    failed = total_errors > 0 or (args.strict and total_warnings > 0)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
