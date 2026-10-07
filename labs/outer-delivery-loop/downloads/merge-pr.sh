#!/usr/bin/env bash
# outer-delivery-loop: merge the PR opened by open-pr.sh, moving the
# environment's source of truth forward.
#
# Stage 2 of the outer delivery loop. Merge is not code the Sandcastle
# runs — it is a policy the environment repository enforces. On a
# learner-owned env repo, the merge can be immediate; on a real
# environment repo, branch-protection rules would require approvals
# and passing checks first.
#
# Prerequisites (honest):
#   - `gh` CLI authenticated with permission to merge on OE_ENV_REPO.
#   - open-pr.sh has run (state/pr-number.txt exists).
#   - For learner-owned solo repos, `--admin` bypasses branch protection.
#     On real environment repos with required approvals, omit --admin
#     and let the humans/CI drive the merge; this script will then wait
#     and only merge once GitHub reports the PR mergeable.
#
# Inputs (env vars):
#   OE_ENV_REPO   optional, read from state/repo.txt
#   PR_NUMBER     optional, read from state/pr-number.txt
#   MERGE_METHOD  optional, one of squash|merge|rebase (default squash)
#   MERGE_FLAGS   optional, extra flags to `gh pr merge` (e.g. --admin)
#
# Outputs:
#   work/outer-delivery-loop/state/merge-sha.txt   merge commit SHA
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/outer-delivery-loop}"
STATE_DIR="$WORK_ROOT/state"

if ! command -v gh >/dev/null; then echo "merge-pr: gh CLI required on PATH" >&2; exit 2; fi
if ! gh auth status >/dev/null 2>&1; then echo "merge-pr: gh CLI not authenticated" >&2; exit 2; fi

OE_ENV_REPO="${OE_ENV_REPO:-$(cat "$STATE_DIR/repo.txt" 2>/dev/null || true)}"
PR_NUMBER="${PR_NUMBER:-$(cat "$STATE_DIR/pr-number.txt" 2>/dev/null || true)}"
MERGE_METHOD="${MERGE_METHOD:-squash}"
MERGE_FLAGS="${MERGE_FLAGS:---admin --delete-branch}"

: "${OE_ENV_REPO:?set OE_ENV_REPO or run push-branch.sh first}"
: "${PR_NUMBER:?set PR_NUMBER or run open-pr.sh first}"

STATE="$(gh pr view "$PR_NUMBER" --repo "$OE_ENV_REPO" --json state,mergeable,merged --jq '"\(.state) \(.mergeable) \(.merged)"')"
# shellcheck disable=SC2034
read -r PR_STATE PR_MERGEABLE PR_MERGED <<<"$STATE"

if [ "$PR_MERGED" = "true" ]; then
  MERGE_SHA="$(gh pr view "$PR_NUMBER" --repo "$OE_ENV_REPO" --json mergeCommit --jq .mergeCommit.oid)"
  printf 'merge-pr: PR #%s already merged (sha %s)\n' "$PR_NUMBER" "$MERGE_SHA"
elif [ "$PR_STATE" != "OPEN" ]; then
  printf 'merge-pr: PR #%s is in state %s; refusing to merge\n' "$PR_NUMBER" "$PR_STATE" >&2
  exit 3
else
  # shellcheck disable=SC2086
  gh pr merge "$PR_NUMBER" --repo "$OE_ENV_REPO" "--$MERGE_METHOD" $MERGE_FLAGS
  MERGE_SHA="$(gh pr view "$PR_NUMBER" --repo "$OE_ENV_REPO" --json mergeCommit --jq .mergeCommit.oid)"
  printf 'merge-pr: merged PR #%s via %s (sha %s)\n' "$PR_NUMBER" "$MERGE_METHOD" "$MERGE_SHA"
fi

mkdir -p "$STATE_DIR"
printf '%s\n' "$MERGE_SHA" > "$STATE_DIR/merge-sha.txt"

printf 'merge-pr: next: run gitops-sync.sh to reconcile the merged XR onto a cluster\n'
