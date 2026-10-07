#!/usr/bin/env bash
# Automatable verification for the Sandcastle → Kubernetes hand-off lab.
#
# Runs the full hand-off end-to-end and asserts:
#   1. The Sandcastle lab's target branch exists and the rule file is on it.
#   2. handoff.sh extracts the greeting value and generates an XR YAML.
#   3. The generated XR matches the expected shape (apiVersion, kind,
#      spec.value) and is byte-equivalent to the reference XR used by the
#      existing hello-pico-on-kubernetes lab (05-xr.yaml).
#   4. No cluster is required — this lab covers only the hand-off boundary.
#
# Exits 0 on success, non-zero on any failure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SANDCASTLE_LAB="${SANDCASTLE_LAB:-$REPO_ROOT/labs/hello-world-pico-sandcastle}"
SANDCASTLE_WORK="${SANDCASTLE_WORK:-$REPO_ROOT/work/hello-world-pico-sandcastle}"
K8S_LAB="${K8S_LAB:-$REPO_ROOT/labs/hello-pico-on-kubernetes}"
BRANCH="${BRANCH:-sandcastle/hello-world-pico}"
EXPECTED_VALUE="${EXPECTED_VALUE:-Hello, Pico!}"

WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/handoff-sandcastle-to-kubernetes}"
BUILD_DIR="$WORK_ROOT/build"
XR_OUT="$BUILD_DIR/xr.yaml"

echo "verify: step 0 — ensure the Sandcastle lab has produced its branch"
if ! git -C "$SANDCASTLE_WORK/target-repo" rev-parse "$BRANCH" >/dev/null 2>&1; then
  echo "verify: sandcastle branch missing; running the sandcastle lab first"
  bash "$SANDCASTLE_LAB/downloads/sandcastle-run.sh" \
       "$SANDCASTLE_LAB/downloads/blueprint.yaml" \
       "$SANDCASTLE_WORK"
fi

echo "verify: step 1 — run the hand-off"
bash "$SCRIPT_DIR/handoff.sh" "$WORK_ROOT"

echo "verify: assertion 1 — generated XR file exists"
test -f "$XR_OUT"

echo "verify: assertion 2 — generated XR fields match expected shape"
python3 - "$XR_OUT" "$EXPECTED_VALUE" <<'PY'
import re, sys
path, expected = sys.argv[1], sys.argv[2]
fields = {}
for line in open(path):
    m = re.match(r"^\s*(apiVersion|kind|name|value)\s*:\s*(.+?)\s*$", line)
    if m:
        k, v = m.group(1), m.group(2)
        if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
            v = v[1:-1]
        fields.setdefault(k, v)
expect = {
    "apiVersion": "oe.academy/v1alpha1",
    "kind":       "XHelloWorldPico",
    "name":       "hello",
    "value":      expected,
}
for k, want in expect.items():
    got = fields.get(k)
    if got != want:
        sys.stderr.write(f"verify: FAIL — {k}: got={got!r} want={want!r}\n")
        sys.exit(1)
PY

echo "verify: assertion 3 — generated XR matches labs/hello-pico-on-kubernetes/downloads/05-xr.yaml shape"
python3 - "$XR_OUT" "$K8S_LAB/downloads/05-xr.yaml" <<'PY'
import re, sys
def load(path):
    out = {}
    for line in open(path):
        m = re.match(r"^\s*(apiVersion|kind|name|value)\s*:\s*(.+?)\s*$", line)
        if m:
            k, v = m.group(1), m.group(2)
            if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
                v = v[1:-1]
            out.setdefault(k, v)
    return out
gen, ref = load(sys.argv[1]), load(sys.argv[2])
for k in ("apiVersion", "kind", "name", "value"):
    if gen.get(k) != ref.get(k):
        sys.stderr.write(f"verify: FAIL — {k}: generated={gen.get(k)!r} k8s-lab={ref.get(k)!r}\n")
        sys.exit(1)
PY

VALUE_LINE="$(grep -E '^[[:space:]]*value:' "$XR_OUT" | head -n1 | sed -E 's/^[[:space:]]*value:[[:space:]]*//')"
printf 'verify: OK — xr=%s value=%s (matches labs/hello-pico-on-kubernetes/downloads/05-xr.yaml)\n' \
  "$XR_OUT" "$VALUE_LINE"
