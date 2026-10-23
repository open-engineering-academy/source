#!/usr/bin/env bash
# Automatable verification for the Compose-Sandcastle-Request lab.
#
# Runs the full compose → construct path end-to-end and asserts:
#   1. compose.sh turns xr-request.yaml into an EngineeringTask whose
#      shape matches the reference expected-task.yaml on the fields
#      that cross the compose → construct boundary (kind, task name,
#      target branch, greeting input, requestedBy provenance).
#   2. sandcastle-run.sh produces the requested branch on the durable
#      target repo, containing rules/hello.yaml with the greeting the
#      XR asked for (parametric, not hard-coded).
#   3. Recomposing that branch through the reference pico CLI prints
#      the same greeting.
#   4. The sandbox workspace was disposed at the end of the run.
#   5. The construction stage never saw the XR file (the XR only
#      appears on the compose side; only the EngineeringTask crosses
#      into the sandbox).
#
# Exits 0 on success, non-zero on any failure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/compose-sandcastle-request}"
XR="${XR:-$SCRIPT_DIR/xr-request.yaml}"
EXPECTED_TASK="${EXPECTED_TASK:-$SCRIPT_DIR/expected-task.yaml}"
TASK_OUT="$WORK_ROOT/task/engineering-task.yaml"

rm -rf "$WORK_ROOT"
mkdir -p "$WORK_ROOT"

echo "verify: step 1 — run compose.sh (XR → EngineeringTask)"
bash "$SCRIPT_DIR/compose.sh" "$XR" "$WORK_ROOT"

echo "verify: assertion 1 — generated task matches expected shape on boundary fields"
python3 - "$TASK_OUT" "$EXPECTED_TASK" <<'PY'
import re, sys
def parse(path):
    out = {}
    stack = []
    with open(path) as f:
        for raw in f:
            line = raw.rstrip("\n")
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            indent = len(line) - len(line.lstrip(" "))
            depth = indent // 2
            stack = stack[:depth]
            stripped = line.strip()
            if ":" in stripped and not stripped.startswith("-"):
                k, _, v = stripped.partition(":")
                k = k.strip()
                v = v.strip()
                if v == "":
                    stack.append(k)
                    continue
                if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
                    v = v[1:-1]
                out[".".join(stack + [k])] = v
    return out
gen, ref = parse(sys.argv[1]), parse(sys.argv[2])
keys = [
    "kind",
    "metadata.name",
    "spec.requestedBy.apiVersion",
    "spec.requestedBy.kind",
    "spec.requestedBy.name",
    "spec.artifact.kind",
    "spec.inputs.greeting",
    "spec.target.branch",
]
bad = [k for k in keys if gen.get(k) != ref.get(k)]
if bad:
    for k in bad:
        sys.stderr.write(f"verify: FAIL — {k}: got={gen.get(k)!r} want={ref.get(k)!r}\n")
    sys.exit(1)
PY

echo "verify: step 2 — run sandcastle-run.sh (EngineeringTask → durable branch)"
bash "$SCRIPT_DIR/sandcastle-run.sh" "$TASK_OUT" "$WORK_ROOT"

# Pull the branch and expected greeting out of the generated task so
# the assertions honour whatever XR the learner supplied.
BRANCH="$(python3 -c 'import re,sys
for l in open(sys.argv[1]):
    m = re.match(r"^\s{4}branch\s*:\s*(.+?)\s*$", l)
    if m:
        v = m.group(1).strip()
        if len(v) >= 2 and v[0] == v[-1] and v[0] in ("\x27", "\x22"): v = v[1:-1]
        print(v); break' "$TASK_OUT")"
EXPECTED_VALUE="$(python3 -c 'import re,sys
for l in open(sys.argv[1]):
    m = re.match(r"^\s{4}greeting\s*:\s*(.+?)\s*$", l)
    if m:
        v = m.group(1).strip()
        if len(v) >= 2 and v[0] == v[-1] and v[0] in ("\x27", "\x22"): v = v[1:-1]
        print(v); break' "$TASK_OUT")"

echo "verify: assertion 2 — branch exists on target repo with rules/hello.yaml carrying the requested greeting"
git -C "$WORK_ROOT/target-repo" rev-parse "$BRANCH" >/dev/null
git -C "$WORK_ROOT/target-repo" show "${BRANCH}:rules/hello.yaml" >/dev/null
BRANCH_VALUE="$(git -C "$WORK_ROOT/target-repo" show "${BRANCH}:rules/hello.yaml" \
  | grep -E '^value:' | head -n1 | sed -E 's/^value:[[:space:]]*//' \
  | sed -E 's/^"(.*)"$/\1/;s/^'"'"'(.*)'"'"'$/\1/')"
if [ "$BRANCH_VALUE" != "$EXPECTED_VALUE" ]; then
  printf 'verify: FAIL — rules/hello.yaml value=%q want=%q\n' "$BRANCH_VALUE" "$EXPECTED_VALUE" >&2
  exit 1
fi

echo "verify: assertion 3 — recomposed pico artifact prints the same greeting"
grep -Fqx -- "$EXPECTED_VALUE" "$WORK_ROOT/results/pico-output.txt"

echo "verify: assertion 4 — sandbox workspace has been disposed"
if [ -d "$WORK_ROOT/sandbox" ]; then
  printf 'verify: FAIL — sandbox workspace should have been disposed\n' >&2
  exit 1
fi

echo "verify: assertion 5 — construction stage never saw the XR"
# The recomposed target-branch clone represents everything that
# survived the boundary; the XR must not appear in it.
if grep -RlqE '^kind:[[:space:]]+XHelloWorldPico' "$WORK_ROOT/results/target-branch" 2>/dev/null; then
  printf 'verify: FAIL — XR shape leaked into the durable branch\n' >&2
  exit 1
fi
if [ -f "$WORK_ROOT/results/target-branch/.engineering-task.yaml" ]; then
  printf 'verify: FAIL — EngineeringTask leaked across the artifact boundary\n' >&2
  exit 1
fi

COMMIT="$(git -C "$WORK_ROOT/target-repo" rev-parse "$BRANCH")"
printf 'verify: OK — branch=%s commit=%s greeting=%q task=%s sandbox=disposed\n' \
  "$BRANCH" "$COMMIT" "$EXPECTED_VALUE" "$TASK_OUT"
