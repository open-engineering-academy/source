#!/usr/bin/env bash
# Automatable verification for the Hello World Pico Sandcastle lab.
# Runs the full Sandcastle path end-to-end and asserts:
#   1. The target branch exists on the durable target repo with the
#      expected file at the expected path.
#   2. Recomposing from a fresh clone of the target repo produces a
#      Pico artifact that prints "Hello, Pico!".
#   3. The sandbox workspace was disposed at the end of the run.
# Exits 0 on success, non-zero on any failure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/hello-world-pico-sandcastle}"
BLUEPRINT="${BLUEPRINT:-$SCRIPT_DIR/blueprint.yaml}"
BRANCH="${BRANCH:-sandcastle/hello-world-pico}"
EXPECTED="${EXPECTED:-Hello, Pico!}"

bash "$SCRIPT_DIR/sandcastle-run.sh" "$BLUEPRINT" "$WORK_ROOT"

echo "verify: assertion 1 — branch and file exist on the durable target repo"
git -C "$WORK_ROOT/target-repo" rev-parse "$BRANCH" >/dev/null
git -C "$WORK_ROOT/target-repo" show "${BRANCH}:rules/hello.yaml" >/dev/null

echo "verify: assertion 2 — recomposed Pico artifact prints expected greeting"
grep -Fqx -- "$EXPECTED" "$WORK_ROOT/results/pico-output.txt"

echo "verify: assertion 3 — sandbox workspace has been disposed"
if [ -d "$WORK_ROOT/sandbox" ]; then
  printf 'verify: FAIL — sandbox workspace should have been disposed\n' >&2
  exit 1
fi

COMMIT="$(git -C "$WORK_ROOT/target-repo" rev-parse "$BRANCH")"
GREETING="$(cat "$WORK_ROOT/results/pico-output.txt")"
printf 'verify: OK — branch=%s commit=%s greeting=%q sandbox=disposed\n' \
  "$BRANCH" "$COMMIT" "$GREETING"
