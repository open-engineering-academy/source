#!/usr/bin/env python3
"""Reproducible internal-link checker for academy ``*.qmd``/``*.md`` files.

Walks the repository, resolves inline markdown links ``[text](target)``
relative to the containing file (or repository root for absolute paths),
and reports any target that does not exist on disk. Honours Quarto's
``.qmd``→``.html`` rendering equivalence and treats directory links as
satisfied by a sibling ``index.qmd`` or ``index.html``.

Skips protocol links (``http(s):``, ``mailto:``, ``tel:``, ``data:``),
same-page anchors (``#...``), and the pruned build/output directories
listed in ``PRUNED_DIR_NAMES``. Stdlib only; mirrors the exit-code and
output conventions of ``scripts/oels_ci_validate.py``.

Exit codes:
  0 — every resolved internal link exists
  1 — one or more broken links were detected
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


def _exists(resolved: Path, trailing_slash: bool) -> bool:
    if trailing_slash:
        return resolved.is_dir() and (
            (resolved / "index.qmd").exists() or (resolved / "index.html").exists()
        )
    if resolved.exists():
        return True
    if resolved.suffix == ".html":
        qmd_sibling = resolved.with_suffix(".qmd")
        if qmd_sibling.exists():
            return True
    return False


def _check_file(path: Path, repo_root: Path) -> tuple[int, list[tuple[int, str, Path]]]:
    errors: list[tuple[int, str, Path]] = []
    checked = 0
    source_dir = path.parent
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return checked, errors
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
            if not _exists(resolved, trailing_slash):
                errors.append((lineno, target, resolved))
    return checked, errors


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument(
        "--root", type=Path, default=REPO_ROOT_DEFAULT,
        help="Repository root to scan (default: parent of scripts/).",
    )
    ap.add_argument(
        "--quiet", action="store_true",
        help="Suppress the per-run summary; print broken links only.",
    )
    args = ap.parse_args(argv)

    repo_root = args.root.resolve()
    if not repo_root.is_dir():
        print(f"verify-links: root is not a directory: {repo_root}", file=sys.stderr)
        return 2

    total_checked = 0
    total_errors = 0
    for source in _walk_sources(repo_root):
        rel = source.relative_to(repo_root)
        checked, errors = _check_file(source, repo_root)
        total_checked += checked
        for lineno, target, resolved in errors:
            print(f"{rel}:{lineno}: broken link -> {target} (resolved: {resolved})")
            total_errors += 1

    if not args.quiet:
        print(f"verify-links: checked={total_checked} errors={total_errors}")
    return 0 if total_errors == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
