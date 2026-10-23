#!/usr/bin/env bash
# Automatable verification for the outer-delivery-loop lab.
#
# Runs the full outer loop end-to-end against a real GitHub repository
# the learner controls and (optionally) a real Crossplane cluster:
#
#   Stage 0  hand-off has already produced work/.../xr.yaml
#   Stage 1  push a feature branch and open a real GitHub PR
#   Stage 2  merge the PR (source of truth moves on the env repo)
#   Stage 3  reconcile the merged XR onto the cluster (GitOps)
#   Stage 4  Crossplane composes the XR into the Kubernetes Job
#
# By default the script runs stages 1–2 (the fully hosted GitHub loop)
# and skips stages 3–4 unless a cluster is reachable. Pass --with-cluster
# to force stages 3–4 and fail if they cannot run.
#
# Prerequisites (honest):
#   - `gh` CLI authenticated, `git` on PATH.
#   - OE_ENV_REPO=owner/repo, learner-owned (private is recommended).
#   - Stages 3–4: cluster from labs/hello-pico-on-kubernetes and either
#     `flux` CLI or a plain `kubectl` pointed at that cluster.
#
# Exits 0 on success, non-zero on any failure.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
HANDOFF_LAB="$REPO_ROOT/labs/handoff-sandcastle-to-kubernetes"
K8S_LAB="$REPO_ROOT/labs/hello-pico-on-kubernetes"
WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/outer-delivery-loop}"
STATE_DIR="$WORK_ROOT/state"

: "${OE_ENV_REPO:?set OE_ENV_REPO=owner/repo before running verify.sh}"

MODE="auto"
for arg in "$@"; do
  case "$arg" in
    --with-cluster) MODE=with-cluster ;;
    --skip-cluster) MODE=skip-cluster ;;
    *) echo "verify: unknown flag $arg" >&2; exit 2 ;;
  esac
done

echo "verify: step 0 — ensure the hand-off lab has produced its XR"
if [ ! -f "$REPO_ROOT/work/handoff-sandcastle-to-kubernetes/build/xr.yaml" ]; then
  echo "verify: XR missing; running the hand-off lab first (which will run the Sandcastle lab if needed)"
  bash "$HANDOFF_LAB/downloads/verify.sh"
fi

echo "verify: step 1 — push feature branch to $OE_ENV_REPO (real GitHub)"
bash "$SCRIPT_DIR/push-branch.sh"

echo "verify: step 2 — open a real GitHub pull request"
bash "$SCRIPT_DIR/open-pr.sh"

echo "verify: step 3 — merge the pull request (source of truth moves forward)"
bash "$SCRIPT_DIR/merge-pr.sh"

echo "verify: assertion 1 — GitHub reports the PR as merged"
PR_NUMBER="$(cat "$STATE_DIR/pr-number.txt")"
MERGED="$(gh pr view "$PR_NUMBER" --repo "$OE_ENV_REPO" --json merged --jq .merged)"
if [ "$MERGED" != "true" ]; then
  echo "verify: FAIL — PR #$PR_NUMBER not merged" >&2
  exit 1
fi

echo "verify: assertion 2 — merged commit is on the default branch"
BASE="$(cat "$STATE_DIR/base.txt")"
MERGE_SHA="$(cat "$STATE_DIR/merge-sha.txt")"
REMOTE_HEAD="$(gh api "repos/$OE_ENV_REPO/branches/$BASE" --jq .commit.sha)"
if [ "$MERGE_SHA" != "$REMOTE_HEAD" ]; then
  # A subsequent commit on default is fine; require the merge sha to be an ancestor.
  if ! gh api "repos/$OE_ENV_REPO/compare/${MERGE_SHA}...${REMOTE_HEAD}" --jq .status \
       | grep -qE '^(identical|ahead)$'; then
    echo "verify: FAIL — merge sha $MERGE_SHA is not on $BASE" >&2
    exit 1
  fi
fi

echo "verify: assertion 3 — merged XR content on GitHub matches the hand-off XR"
python3 - "$OE_ENV_REPO" "$BASE" "$REPO_ROOT/work/handoff-sandcastle-to-kubernetes/build/xr.yaml" <<'PY'
import base64, json, re, subprocess, sys
repo, base, local = sys.argv[1], sys.argv[2], sys.argv[3]
raw = subprocess.check_output(["gh","api",f"repos/{repo}/contents/envs/dev/xr.yaml?ref={base}"])
remote = base64.b64decode(json.loads(raw)["content"]).decode()
def fields(text):
    out = {}
    for line in text.splitlines():
        m = re.match(r"^\s*(apiVersion|kind|name|value)\s*:\s*(.+?)\s*$", line)
        if m:
            k, v = m.group(1), m.group(2)
            if len(v) >= 2 and v[0] == v[-1] and v[0] in ("'", '"'):
                v = v[1:-1]
            out.setdefault(k, v)
    return out
lf, rf = fields(open(local).read()), fields(remote)
for k in ("apiVersion", "kind", "name", "value"):
    if lf.get(k) != rf.get(k):
        sys.stderr.write(f"verify: FAIL — {k}: local={lf.get(k)!r} remote={rf.get(k)!r}\n")
        sys.exit(1)
PY

if [ "$MODE" = "skip-cluster" ]; then
  echo "verify: OK — outer loop stages 1–2 complete on $OE_ENV_REPO PR #$PR_NUMBER (cluster stages skipped)"
  exit 0
fi

if [ "$MODE" = "auto" ] && ! kubectl cluster-info >/dev/null 2>&1; then
  echo "verify: OK — outer loop stages 1–2 complete on $OE_ENV_REPO PR #$PR_NUMBER"
  echo "verify: NOTE — no cluster reachable; skipped stages 3–4 (pass --with-cluster to require them)"
  exit 0
fi

echo "verify: step 4 — GitOps sync (stage 3)"
bash "$SCRIPT_DIR/gitops-sync.sh"

echo "verify: step 5 — Crossplane reconciliation (stage 4) via hello-pico-on-kubernetes/verify.sh"
bash "$K8S_LAB/downloads/verify.sh"

echo "verify: OK — outer loop stages 1–4 complete on $OE_ENV_REPO PR #$PR_NUMBER (merge sha $MERGE_SHA)"
