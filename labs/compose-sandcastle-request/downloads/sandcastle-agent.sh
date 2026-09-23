#!/usr/bin/env bash
# Task-driven engineering-agent inner loop for the Part 2 lab. Runs
# *inside* the sandbox workspace. Uses only tools present on PATH
# (constrained by the driver). Reads the greeting *from the
# EngineeringTask* mounted at ./.engineering-task.yaml — the agent
# never sees the original Crossplane XR.
#
# Usage: sandcastle-agent.sh <workspace-dir> <branch-name>
set -euo pipefail

WORKSPACE="${1:?workspace dir required}"
BRANCH="${2:?branch name required}"

cd "$WORKSPACE"
log() { printf '[agent] %s\n' "$*"; }

TASK_FILE="./.engineering-task.yaml"
if [ ! -f "$TASK_FILE" ]; then
  log "task: missing $TASK_FILE — the driver must materialise the EngineeringTask"
  exit 1
fi

log "inspect: reading EngineeringTask ($TASK_FILE) — no XR present"
GREETING="$(TASK_PATH="$TASK_FILE" python3 <<'PY'
import os, re, sys
path = os.environ.get("TASK_PATH", "")
val = None
for line in open(path):
    m = re.match(r"^\s{4}greeting\s*:\s*(.+?)\s*$", line)
    if m:
        v = m.group(1).strip()
        if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
            v = v[1:-1]
        val = v
        break
if val is None:
    sys.stderr.write("agent: could not find spec.inputs.greeting in task\n")
    sys.exit(3)
print(val)
PY
)"
log "inspect: greeting requested by task = ${GREETING}"

log "generate: writing rules/hello.yaml with the requested greeting"
mkdir -p rules
python3 - "$GREETING" <<'PY' > rules/hello.yaml
import sys
greeting = sys.argv[1]
esc = greeting.replace("\\", "\\\\").replace('"', '\\"')
print("id: rule.hello")
print("kind: greeting")
print(f'value: "{esc}"')
PY

log "validate: pico parse rules/hello.yaml"
mkdir -p build
attempts=0
while ! pico parse rules/hello.yaml --out build/parsed.json >/dev/null 2>&1; do
  attempts=$((attempts + 1))
  if [ "$attempts" -ge 3 ]; then
    log "validate: giving up after $attempts attempts"
    exit 1
  fi
  log "validate: attempt $attempts failed - regenerating"
done
log "validate: OK (parser accepted the rule)"

log "compose (in-workspace sanity check): pico compose"
pico compose build/parsed.json --out build/hello-world-pico >/dev/null
RENDERED="$(./build/hello-world-pico)"
log "compose: artifact prints ${RENDERED}"

log "commit: adding rules/hello.yaml on branch ${BRANCH}"
git checkout -q -b "$BRANCH"
git config user.email "agent@sandcastle.local"
git config user.name "Sandcastle Agent"
git add rules/hello.yaml
git commit -q -m "Add hello-world-pico rule for task greetings"

log "commit: done. build/, .engineering-task.yaml, and other scratch files are NOT committed."
