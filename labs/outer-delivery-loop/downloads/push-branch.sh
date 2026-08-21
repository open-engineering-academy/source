#!/usr/bin/env bash
# outer-delivery-loop: push the hand-off's Crossplane XR onto a real
# GitHub branch in the learner's environment repository.
#
# Stage 1 of the outer delivery loop: the durable branch produced by
# the Sandcastle (and materialised as an XR by the hand-off lab) is
# committed to a new feature branch on a real GitHub repository the
# learner controls. That branch is the outer loop's only input.
#
# Prerequisites (honest):
#   - `git` on PATH.
#   - `gh` CLI authenticated (`gh auth status` succeeds) with push
#     access to the environment repository.
#   - The hand-off lab has produced work/handoff-sandcastle-to-kubernetes/
#     build/xr.yaml (or set XR_SRC to a different XR file).
#   - The environment repository already exists on GitHub. Suggested
#     one-liner (private, learner-owned):
#       gh repo create "$OE_ENV_REPO" --private --add-readme
#
# Inputs (env vars):
#   OE_ENV_REPO   required, e.g. "octo/oe-env-hello-world-pico"
#   XR_SRC        optional, path to the XR file to commit
#   BRANCH        optional, remote feature branch name (auto-timestamped)
#   XR_DST        optional, in-repo path (default envs/dev/xr.yaml)
#
# Outputs:
#   work/outer-delivery-loop/env-repo/            local clone
#   work/outer-delivery-loop/state/branch.txt     branch name pushed
#   work/outer-delivery-loop/state/commit.txt     commit SHA pushed
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

: "${OE_ENV_REPO:?set OE_ENV_REPO=owner/repo (learner-controlled GitHub env repo)}"
XR_SRC="${XR_SRC:-$REPO_ROOT/work/handoff-sandcastle-to-kubernetes/build/xr.yaml}"
XR_DST="${XR_DST:-envs/dev/xr.yaml}"
BRANCH="${BRANCH:-sandcastle/hello-world-pico-$(date +%Y%m%d%H%M%S)}"

WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/outer-delivery-loop}"
CLONE_DIR="$WORK_ROOT/env-repo"
STATE_DIR="$WORK_ROOT/state"

if ! command -v git >/dev/null; then echo "push-branch: git required on PATH" >&2; exit 2; fi
if ! command -v gh  >/dev/null; then echo "push-branch: gh CLI required on PATH (see https://cli.github.com/)" >&2; exit 2; fi
if ! gh auth status >/dev/null 2>&1; then
  echo "push-branch: gh CLI is not authenticated; run \`gh auth login\` first" >&2
  exit 2
fi
if [ ! -f "$XR_SRC" ]; then
  echo "push-branch: XR file not found at $XR_SRC" >&2
  echo "push-branch: run labs/handoff-sandcastle-to-kubernetes/downloads/handoff.sh first, or set XR_SRC=..." >&2
  exit 2
fi
if ! gh repo view "$OE_ENV_REPO" >/dev/null 2>&1; then
  echo "push-branch: env repo $OE_ENV_REPO not reachable via gh" >&2
  echo "push-branch: create it once with: gh repo create \"$OE_ENV_REPO\" --private --add-readme" >&2
  exit 2
fi

mkdir -p "$STATE_DIR"

REMOTE_URL="$(gh repo view "$OE_ENV_REPO" --json url --jq .url).git"

if [ ! -d "$CLONE_DIR/.git" ]; then
  rm -rf "$CLONE_DIR"
  # Uses the gh auth token via the git credential helper gh installs.
  gh repo clone "$OE_ENV_REPO" "$CLONE_DIR" >/dev/null
fi

BASE_BRANCH="$(gh repo view "$OE_ENV_REPO" --json defaultBranchRef --jq .defaultBranchRef.name)"
(
  cd "$CLONE_DIR"
  git config user.email "outer-loop@sandcastle.local"
  git config user.name  "Sandcastle Outer Loop"
  git fetch --quiet origin "$BASE_BRANCH"
  git checkout --quiet "$BASE_BRANCH"
  git reset --hard --quiet "origin/$BASE_BRANCH"
  git checkout --quiet -B "$BRANCH"

  mkdir -p "$(dirname "$XR_DST")"
  # The branch carries the exact XR the hand-off lab produced. The outer
  # loop must not reach back into the Sandcastle to regenerate it.
  cp "$XR_SRC" "$XR_DST"
  git add "$XR_DST"

  if git diff --cached --quiet; then
    echo "push-branch: nothing to commit; $XR_DST already up-to-date on $BASE_BRANCH"
  else
    git commit --quiet -m "outer-loop: promote hello-world-pico XR from Sandcastle hand-off

Source: $(basename "$XR_SRC") (from labs/handoff-sandcastle-to-kubernetes)
Path:   $XR_DST
"
  fi

  git push --quiet --set-upstream origin "$BRANCH"
  git rev-parse HEAD > "$STATE_DIR/commit.txt"
)
printf '%s\n' "$BRANCH"       > "$STATE_DIR/branch.txt"
printf '%s\n' "$OE_ENV_REPO"  > "$STATE_DIR/repo.txt"
printf '%s\n' "$BASE_BRANCH"  > "$STATE_DIR/base.txt"

printf 'push-branch: pushed %s to %s (base %s) — remote: %s\n' \
  "$BRANCH" "$OE_ENV_REPO" "$BASE_BRANCH" "$REMOTE_URL"
printf 'push-branch: next: run open-pr.sh to open a real PR on GitHub\n'
