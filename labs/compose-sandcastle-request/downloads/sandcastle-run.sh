#!/usr/bin/env bash
# Sandcastle driver for a Crossplane-requested EngineeringTask.
#
# Reads the task, provisions an isolated workspace with a PATH
# allowlist, materialises the task file inside the sandbox as the
# sole compose-side input the agent may read, runs the task-driven
# agent, hands the branch back to a durable target repo, captures
# durable evidence outside the sandbox, and disposes of the workspace.
#
# The XR the composition satisfied is *not* passed into the sandbox
# on purpose: the Sandcastle only sees the EngineeringTask, which is
# the compose → construct handover shape from memo2.
#
# Usage: sandcastle-run.sh <engineering-task.yaml> <work-root>
set -euo pipefail

TASK="${1:?engineering-task path required}"
WORK_ROOT="${2:?work-root path required}"

if [ ! -f "$TASK" ]; then
  printf 'sandcastle-run: engineering task not found: %s\n' "$TASK" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if [ ! -x "$REPO_ROOT/bin/pico" ]; then
  printf 'sandcastle-run: reference pico CLI not found at %s/bin/pico\n' "$REPO_ROOT" >&2
  exit 2
fi

# Extract the fields the driver needs from the EngineeringTask. Only
# the shape defined by compose.sh is supported here.
FIELDS="$(TASK_PATH="$TASK" python3 <<'PY'
import os, re, sys
path = os.environ.get("TASK_PATH", "")
kind = branch = greeting = task_name = None
for line in open(path):
    m_kind   = re.match(r"^\s*kind\s*:\s*(.+?)\s*$", line)
    m_name   = re.match(r"^\s{2}name\s*:\s*(.+?)\s*$", line)
    m_branch = re.match(r"^\s{4}branch\s*:\s*(.+?)\s*$", line)
    m_gre    = re.match(r"^\s{4}greeting\s*:\s*(.+?)\s*$", line)
    if m_kind   and kind      is None: kind      = m_kind.group(1)
    if m_name   and task_name is None: task_name = m_name.group(1)
    if m_branch and branch    is None: branch    = m_branch.group(1)
    if m_gre    and greeting  is None: greeting  = m_gre.group(1)
def unquote(v):
    if v is None: return v
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
        v = v[1:-1]
    return v
missing = [k for k, v in {
    "kind": kind, "metadata.name": task_name,
    "spec.target.branch": branch, "spec.inputs.greeting": greeting,
}.items() if not v]
if missing:
    sys.stderr.write(f"sandcastle-run: task missing required fields: {missing}\n")
    sys.exit(3)
print(unquote(kind))
print(unquote(task_name))
print(unquote(branch))
print(unquote(greeting))
PY
)"

KIND="$(printf '%s\n' "$FIELDS" | sed -n '1p')"
TASK_NAME="$(printf '%s\n' "$FIELDS" | sed -n '2p')"
BRANCH="$(printf '%s\n' "$FIELDS" | sed -n '3p')"
GREETING="$(printf '%s\n' "$FIELDS" | sed -n '4p')"

if [ "$KIND" != "EngineeringTask" ]; then
  printf 'sandcastle-run: task kind is %q, expected "EngineeringTask"\n' "$KIND" >&2
  exit 2
fi

printf 'sandcastle-run: task=%s name=%s branch=%s greeting=%q\n' \
  "$TASK" "$TASK_NAME" "$BRANCH" "$GREETING"

rm -rf "$WORK_ROOT/sandbox" "$WORK_ROOT/target-repo" "$WORK_ROOT/bin-allowlist" "$WORK_ROOT/results"
mkdir -p "$WORK_ROOT/target-repo" "$WORK_ROOT/bin-allowlist" "$WORK_ROOT/results"

# Tools/permissions: PATH allowlist. The agent process only sees these
# binaries; anything else it invokes fails with "command not found".
for tool in git python3 bash sh env mkdir cat rm chmod cp mv ls test grep sed; do
  src="$(command -v "$tool" || true)"
  if [ -z "$src" ]; then
    printf 'sandcastle-run: required host tool not on PATH: %s\n' "$tool" >&2
    exit 2
  fi
  ln -sf "$src" "$WORK_ROOT/bin-allowlist/$tool"
done
ln -sf "$REPO_ROOT/bin/pico" "$WORK_ROOT/bin-allowlist/pico"

printf 'sandcastle-run: tool allowlist:'
for f in "$WORK_ROOT/bin-allowlist"/*; do printf ' %s' "$(basename "$f")"; done
printf '\n'

# Repo/branch flow: bare "target repo" plays the durable-remote role.
git init -q --bare -b main "$WORK_ROOT/target-repo"

# Seed the target so the branch has a base commit to fork from.
SEED_DIR="$(mktemp -d)"
git init -q -b main "$SEED_DIR"
(
  cd "$SEED_DIR"
  printf 'compose-sandcastle-request target repo\n' > README.md
  git config user.email "seed@sandcastle.local"
  git config user.name "Seed"
  git add README.md
  git commit -q -m "seed target repo"
  git push -q "$WORK_ROOT/target-repo" main
)
rm -rf "$SEED_DIR"

# The sandbox workspace is a fresh clone of the target repo. The task
# file is copied *into* the sandbox as the only compose-side input the
# agent may read; the XR itself is deliberately not passed in.
git clone -q "$WORK_ROOT/target-repo" "$WORK_ROOT/sandbox"
cp "$TASK" "$WORK_ROOT/sandbox/.engineering-task.yaml"

printf 'sandcastle-run: launching agent inside %s\n' "$WORK_ROOT/sandbox"
env -i \
  HOME="$WORK_ROOT/sandbox" \
  PATH="$WORK_ROOT/bin-allowlist" \
  LANG=C.UTF-8 \
  bash "$SCRIPT_DIR/sandcastle-agent.sh" "$WORK_ROOT/sandbox" "$BRANCH"

# Hand the branch back to the target repo.
(
  cd "$WORK_ROOT/sandbox"
  git push -q origin "$BRANCH"
)

# Capture durable evidence *outside* the sandbox.
COMMIT="$(git -C "$WORK_ROOT/target-repo" rev-parse "$BRANCH")"
printf 'branch=%s\ncommit=%s\ntask=%s\ngreeting=%s\n' \
  "$BRANCH" "$COMMIT" "$TASK_NAME" "$GREETING" \
  > "$WORK_ROOT/results/branch-info.txt"

# Recompose from a *fresh* clone of the target repo to prove the branch
# is a durable artifact independent of the sandbox.
git clone -q --branch "$BRANCH" "$WORK_ROOT/target-repo" "$WORK_ROOT/results/target-branch"
(
  cd "$WORK_ROOT/results/target-branch"
  PATH="$WORK_ROOT/bin-allowlist:$PATH" pico parse rules/hello.yaml --out build/parsed.json >/dev/null
  PATH="$WORK_ROOT/bin-allowlist:$PATH" pico compose build/parsed.json --out build/hello-world-pico >/dev/null
  ./build/hello-world-pico > "$WORK_ROOT/results/pico-output.txt"
)

# Artifact boundary: dispose of the sandbox.
rm -rf "$WORK_ROOT/sandbox"

printf 'sandcastle-run: done. sandbox destroyed; durable artifacts under %s/results/\n' "$WORK_ROOT"
