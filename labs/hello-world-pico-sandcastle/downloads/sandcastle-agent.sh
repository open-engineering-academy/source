#!/usr/bin/env bash
# Engineering-agent inner iteration loop, run *inside* the sandbox
# workspace. Uses only tools present on PATH (constrained by the
# driver).
#
# Usage: sandcastle-agent.sh <workspace-dir> <branch-name>
set -euo pipefail

WORKSPACE="${1:?workspace dir required}"
BRANCH="${2:?branch name required}"

cd "$WORKSPACE"
log() { printf '[agent] %s\n' "$*"; }

log "inspect: reading Pico Rule conventions (id/kind/value from Hello Pico)"

log "generate: writing rules/hello.yaml"
mkdir -p rules
cat > rules/hello.yaml <<'YAML'
id: rule.hello
kind: greeting
value: "Hello, Pico!"
YAML

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
GREETING="$(./build/hello-world-pico)"
log "compose: artifact prints ${GREETING}"

log "commit: adding rules/hello.yaml on branch ${BRANCH}"
git checkout -q -b "$BRANCH"
git config user.email "agent@sandcastle.local"
git config user.name "Sandcastle Agent"
git add rules/hello.yaml
git commit -q -m "Add hello-world-pico rule"

log "commit: done. build/ and other scratch files are NOT committed."
