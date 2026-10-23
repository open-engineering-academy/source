#!/usr/bin/env bash
# Sandcastle driver: provisions the isolated workspace, runs the
# engineering agent under a PATH allowlist, hands the branch back to
# the target repository, captures durable evidence, and disposes of
# the workspace.
#
# Usage: sandcastle-run.sh <blueprint.yaml> <work-root>
set -euo pipefail

BLUEPRINT="${1:?blueprint path required}"
WORK_ROOT="${2:?work-root path required}"

if [ ! -f "$BLUEPRINT" ]; then
  printf 'sandcastle-run: blueprint not found: %s\n' "$BLUEPRINT" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

if [ ! -x "$REPO_ROOT/bin/pico" ]; then
  printf 'sandcastle-run: reference pico CLI not found at %s/bin/pico\n' "$REPO_ROOT" >&2
  exit 2
fi

BLUEPRINT_FIELDS="$(python3 - "$BLUEPRINT" <<'PY'
import sys
path = sys.argv[1]
data = {}
def _clean(v):
    v = v.strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
        v = v[1:-1]
    return v
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
            v = _clean(v)
            if v == "":
                stack.append(k)
                continue
            data[".".join(stack + [k])] = v
print(data.get("kind", ""))
print(data.get("target.branch", ""))
print(data.get("workspace.sandbox_provider", ""))
PY
)"

KIND="$(printf '%s\n' "$BLUEPRINT_FIELDS" | sed -n '1p')"
BRANCH="$(printf '%s\n' "$BLUEPRINT_FIELDS" | sed -n '2p')"
PROVIDER="$(printf '%s\n' "$BLUEPRINT_FIELDS" | sed -n '3p')"

if [ "$KIND" != "SandcastleBlueprint" ]; then
  printf 'sandcastle-run: blueprint kind is %q, expected "SandcastleBlueprint"\n' "$KIND" >&2
  exit 2
fi
if [ -z "$BRANCH" ]; then
  printf 'sandcastle-run: blueprint is missing target.branch\n' >&2
  exit 2
fi

printf 'sandcastle-run: blueprint=%s branch=%s provider=%s\n' "$BLUEPRINT" "$BRANCH" "$PROVIDER"

rm -rf "$WORK_ROOT"
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
  printf 'hello-world-pico target repo\n' > README.md
  git config user.email "seed@sandcastle.local"
  git config user.name "Seed"
  git add README.md
  git commit -q -m "seed target repo"
  git push -q "$WORK_ROOT/target-repo" main
)
rm -rf "$SEED_DIR"

# The sandbox workspace is a fresh clone of the target repo.
git clone -q "$WORK_ROOT/target-repo" "$WORK_ROOT/sandbox"

# Run the agent under the constrained PATH.
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
printf 'branch=%s\ncommit=%s\n' "$BRANCH" "$COMMIT" > "$WORK_ROOT/results/branch-info.txt"

# Recompose from a *fresh* clone of the target repo to prove the
# branch is a durable artifact independent of the sandbox.
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
