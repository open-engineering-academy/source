#!/usr/bin/env bash
# outer-delivery-loop: reconcile the merged XR from the environment
# repository onto a Kubernetes cluster.
#
# Stage 3 of the outer delivery loop. Two supported modes:
#
#   MODE=flux (default when `flux` CLI is installed)
#     Uses Flux to declare the env repo as a GitSource and the XR
#     directory as a Kustomization. Flux then polls the merged branch
#     and applies the XR on every change — a real GitOps reconciler,
#     independent of the hand-off or Sandcastle.
#
#   MODE=kubectl (fallback)
#     Clones the merged branch fresh and applies the XR via `kubectl`.
#     This is what Flux would do internally in one loop iteration. It
#     preserves the outer-loop rule that the merged branch is the only
#     input, but skips the continuous reconciliation that Flux adds.
#
# Prerequisites (honest):
#   - A running Crossplane cluster from labs/hello-pico-on-kubernetes
#     (steps 1–4 complete: Crossplane, provider, XRD, Composition).
#   - `kubectl` on PATH and pointed at that cluster.
#   - MODE=flux: `flux` CLI installed and bootstrapped/connected. If
#     `flux` is missing, the script falls back to MODE=kubectl and
#     logs why so the honest gap is visible.
#
# Inputs (env vars):
#   OE_ENV_REPO   optional, read from state/repo.txt
#   BASE          optional, merged branch name (default: default branch)
#   XR_DST        optional, path in env repo (default envs/dev/xr.yaml)
#   MODE          optional, flux|kubectl
#   FLUX_NAMESPACE optional, default flux-system
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
WORK_ROOT="${WORK_ROOT:-$REPO_ROOT/work/outer-delivery-loop}"
STATE_DIR="$WORK_ROOT/state"
SYNC_DIR="$WORK_ROOT/sync"

if ! command -v kubectl >/dev/null; then
  echo "gitops-sync: kubectl required on PATH (see labs/hello-pico-on-kubernetes)" >&2
  exit 2
fi
if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "gitops-sync: no reachable cluster; run labs/hello-pico-on-kubernetes steps 1-4 first" >&2
  exit 2
fi

OE_ENV_REPO="${OE_ENV_REPO:-$(cat "$STATE_DIR/repo.txt" 2>/dev/null || true)}"
BASE="${BASE:-$(cat "$STATE_DIR/base.txt" 2>/dev/null || true)}"
XR_DST="${XR_DST:-envs/dev/xr.yaml}"
: "${OE_ENV_REPO:?set OE_ENV_REPO or run push-branch.sh first}"

if [ -z "${MODE:-}" ]; then
  if command -v flux >/dev/null; then MODE=flux; else MODE=kubectl; fi
fi

REMOTE_URL="https://github.com/${OE_ENV_REPO}.git"
FLUX_NAMESPACE="${FLUX_NAMESPACE:-flux-system}"
SOURCE_NAME="oe-env-hello-world-pico"
KUSTOMIZATION_NAME="oe-env-hello-world-pico"

mkdir -p "$SYNC_DIR"

case "$MODE" in
  flux)
    if ! command -v flux >/dev/null; then
      echo "gitops-sync: MODE=flux but flux CLI missing; install from https://fluxcd.io" >&2
      exit 2
    fi
    if ! flux check --pre >/dev/null 2>&1 && ! kubectl get ns "$FLUX_NAMESPACE" >/dev/null 2>&1; then
      echo "gitops-sync: Flux is not installed on the cluster; run \`flux install\` first" >&2
      exit 2
    fi
    if ! kubectl get ns "$FLUX_NAMESPACE" >/dev/null 2>&1; then
      kubectl create namespace "$FLUX_NAMESPACE" >/dev/null
    fi
    flux create source git "$SOURCE_NAME" \
      --url="$REMOTE_URL" \
      --branch="${BASE:-main}" \
      --interval=30s \
      --namespace="$FLUX_NAMESPACE" \
      --export > "$SYNC_DIR/source.yaml"
    flux create kustomization "$KUSTOMIZATION_NAME" \
      --source="GitRepository/$SOURCE_NAME" \
      --path="./$(dirname "$XR_DST")" \
      --prune=true \
      --interval=1m \
      --namespace="$FLUX_NAMESPACE" \
      --export > "$SYNC_DIR/kustomization.yaml"
    kubectl apply -f "$SYNC_DIR/source.yaml"
    kubectl apply -f "$SYNC_DIR/kustomization.yaml"
    # Nudge a reconcile so the learner does not have to wait a poll cycle.
    flux reconcile source git      "$SOURCE_NAME"        --namespace "$FLUX_NAMESPACE" || true
    flux reconcile kustomization   "$KUSTOMIZATION_NAME" --namespace "$FLUX_NAMESPACE" || true
    printf 'gitops-sync: Flux source + kustomization applied; polling %s@%s every 30s\n' \
      "$REMOTE_URL" "${BASE:-main}"
    ;;
  kubectl)
    CLONE="$SYNC_DIR/env-repo"
    rm -rf "$CLONE"
    if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
      gh repo clone "$OE_ENV_REPO" "$CLONE" -- --branch "${BASE:-main}" --depth 1 >/dev/null
    else
      git clone --quiet --branch "${BASE:-main}" --depth 1 "$REMOTE_URL" "$CLONE"
    fi
    if [ ! -f "$CLONE/$XR_DST" ]; then
      echo "gitops-sync: $XR_DST not present on merged $BASE; did merge-pr.sh succeed?" >&2
      exit 3
    fi
    kubectl apply -f "$CLONE/$XR_DST"
    printf 'gitops-sync: applied %s from %s@%s (kubectl mode — no continuous reconcile)\n' \
      "$XR_DST" "$OE_ENV_REPO" "${BASE:-main}"
    ;;
  *)
    echo "gitops-sync: unknown MODE=$MODE (expected flux|kubectl)" >&2
    exit 2
    ;;
esac

printf 'gitops-sync: next: run labs/hello-pico-on-kubernetes/downloads/verify.sh to confirm the composed Job runs\n'
