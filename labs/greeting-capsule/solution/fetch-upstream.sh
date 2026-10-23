#!/usr/bin/env bash
# Fetch the upstream capsule contract artefacts at the pinned SHA
# bf071c2c1b57 from open-engineering-capsules/source into an
# untracked ../build/upstream/ directory (the lab-local .gitignore
# ignores build/; build/ is one of PRUNED_DIR_NAMES in
# scripts/oels_ci_validate.py so fetched OE-shaped fixtures do not
# trigger UnknownDefinition gaps under --fail-on-gap).
#
# This script does NOT copy a schema into the Academy; it downloads
# the normative files at lab time and leaves them in an untracked
# directory. Nothing under `build/` is committed (memo23 §3.2 / memo26
# §5: no fork, no shadow).
#
# Pinned commit:
#   https://github.com/open-engineering-capsules/source/commit/bf071c2c1b57
#
# While `open-engineering-capsules/source` is a private repository the
# anonymous `raw.githubusercontent.com` URL returns 404; the script
# falls back to `gh api` (authenticated against GitHub) when `curl`
# fails. Once the repository is public the `curl` path alone succeeds.
set -euo pipefail

PINNED_SHA="bf071c2c1b57"
REPO="open-engineering-capsules/source"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${PINNED_SHA}"

HERE="$(cd "$(dirname "$0")" && pwd)"
LAB_ROOT="$(cd "$HERE/.." && pwd)"
OUT="$LAB_ROOT/build/upstream"

mkdir -p "$OUT/fixtures/valid" "$OUT/fixtures/invalid" "$OUT/fixtures/scenarios"

fetch() {
  local path="$1" dest="$2"
  if curl -fsSL "$RAW_BASE/$path" -o "$dest" 2>/dev/null; then
    return 0
  fi
  if command -v gh >/dev/null 2>&1; then
    if gh api "repos/${REPO}/contents/${path}?ref=${PINNED_SHA}" \
         -H "Accept: application/vnd.github.raw" >"$dest" 2>/dev/null \
         && [ -s "$dest" ]; then
      return 0
    fi
  fi
  rm -f "$dest"
  echo "fetch-upstream: failed to retrieve $path" >&2
  echo "  tried: $RAW_BASE/$path" >&2
  echo "  tried: gh api repos/${REPO}/contents/${path}?ref=${PINNED_SHA}" >&2
  echo "  hint: if the repository is private, run 'gh auth login' first." >&2
  return 1
}

# Documented set used by the walkthrough. Keep this list in sync with
# the pinned tree (see memo2 §5 follow-up (a) and fixtures/README.md).
fetch capsule.schema.json           "$OUT/capsule.schema.json"
fetch fixtures/README.md            "$OUT/fixtures/README.md"
fetch fixtures/valid/greeting.yaml  "$OUT/fixtures/valid/greeting.yaml"
fetch fixtures/invalid/missing-outputs.yaml \
      "$OUT/fixtures/invalid/missing-outputs.yaml"
fetch fixtures/scenarios/resolve-greeting.yaml \
      "$OUT/fixtures/scenarios/resolve-greeting.yaml"

echo "fetch-upstream: downloaded upstream artefacts at ${PINNED_SHA} into ${OUT}"
