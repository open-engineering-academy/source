#!/usr/bin/env bash
# outer-delivery-loop: open a real GitHub pull request against the
# environment repository's default branch, using the branch pushed by
# push-branch.sh.
#
# Stage 1 (review surface) of the outer delivery loop. The PR is the
# concrete review-and-verification surface — a real GitHub PR the
# learner can inspect, review, and gate with checks or branch
# protection rules on github.com.
#
# Prerequisites (honest):
#   - `gh` CLI authenticated with permission to open PRs on OE_ENV_REPO.
#   - push-branch.sh has run in this repo (state/branch.txt exists).
#
# Inputs (env vars):
#   OE_ENV_REPO   optional, read from state/repo.txt if unset
#   BRANCH        optional, read from state/branch.txt if unset
#   BASE          optional, read from state/base.txt if unset
#   PR_TITLE      optional
#   PR_BODY       optional
#
# Outputs:
#   work/outer-delivery-loop/state/pr-number.txt  PR number
#   work/outer-delivery-loop/state/pr-url.txt     PR URL
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/outer-delivery-loop}"
STATE_DIR="$WORK_ROOT/state"

if ! command -v gh >/dev/null; then echo "open-pr: gh CLI required on PATH" >&2; exit 2; fi
if ! gh auth status >/dev/null 2>&1; then echo "open-pr: gh CLI not authenticated" >&2; exit 2; fi

OE_ENV_REPO="${OE_ENV_REPO:-$(cat "$STATE_DIR/repo.txt" 2>/dev/null || true)}"
BRANCH="${BRANCH:-$(cat "$STATE_DIR/branch.txt" 2>/dev/null || true)}"
BASE="${BASE:-$(cat "$STATE_DIR/base.txt" 2>/dev/null || true)}"
: "${OE_ENV_REPO:?set OE_ENV_REPO or run push-branch.sh first}"
: "${BRANCH:?set BRANCH or run push-branch.sh first}"
: "${BASE:?set BASE or run push-branch.sh first}"

PR_TITLE="${PR_TITLE:-outer-loop: promote hello-world-pico XR from Sandcastle hand-off}"
PR_BODY="${PR_BODY:-This PR carries the Crossplane XR that the Sandcastle → Kubernetes hand-off lab produced.

- Source branch: \`$BRANCH\`
- Base: \`$BASE\`
- Stage: **1 · Review / PR** of the outer delivery loop
  (Sandcastle course · Part 3 · Lesson 02)

The XR under \`envs/dev/xr.yaml\` is the only interface the outer loop
has back to the Sandcastle. Reviewers and CI should verify the XR
directly on this branch; do not re-invoke the Sandcastle or the
hand-off.

Merging this PR moves the source of truth of the environment repo to
include the new XR — that is Stage 2 of the outer loop.}"

# If a PR from this head already exists (and is open), reuse it.
EXISTING="$(gh pr list --repo "$OE_ENV_REPO" --head "$BRANCH" --state open --json number,url --limit 1)"
if [ "$EXISTING" != "[]" ] && [ -n "$EXISTING" ]; then
  NUMBER="$(printf '%s' "$EXISTING" | python3 -c 'import json,sys;print(json.load(sys.stdin)[0]["number"])')"
  URL="$(printf    '%s' "$EXISTING" | python3 -c 'import json,sys;print(json.load(sys.stdin)[0]["url"])')"
  printf 'open-pr: reusing open PR #%s (%s)\n' "$NUMBER" "$URL"
else
  URL="$(gh pr create \
      --repo "$OE_ENV_REPO" \
      --base "$BASE" \
      --head "$BRANCH" \
      --title "$PR_TITLE" \
      --body  "$PR_BODY")"
  NUMBER="$(gh pr view "$URL" --json number --jq .number)"
  printf 'open-pr: opened PR #%s (%s)\n' "$NUMBER" "$URL"
fi

mkdir -p "$STATE_DIR"
printf '%s\n' "$NUMBER" > "$STATE_DIR/pr-number.txt"
printf '%s\n' "$URL"    > "$STATE_DIR/pr-url.txt"

printf 'open-pr: next: run merge-pr.sh to merge the PR and move source of truth forward\n'
