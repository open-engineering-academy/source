#!/usr/bin/env bash
# Automatable verification for the Hello Pico on Kubernetes lab.
# Exits 0 on success, non-zero on any failure.
#
# Prerequisites: `kubectl` is on PATH and points at the cluster where the
# lab was deployed (see labs/hello-pico-on-kubernetes/objectives.qmd).
#
# The script waits for the composed Kubernetes Job to complete and then
# confirms its logs contain the greeting from the Composite Resource.
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
XR_NAME="${XR_NAME:-hello}"
JOB_NAME="${JOB_NAME:-hello-world-pico}"
EXPECTED="${EXPECTED:-Hello, Pico!}"

echo "verify: waiting for XR ${XR_NAME} to become Ready"
kubectl wait --for=condition=Ready --timeout=120s \
  "xhelloworldpico/${XR_NAME}"

echo "verify: waiting for Job ${JOB_NAME} to complete in namespace ${NAMESPACE}"
kubectl wait --for=condition=Complete --timeout=120s \
  -n "${NAMESPACE}" "job/${JOB_NAME}"

echo "verify: checking Job logs contain the greeting"
LOGS="$(kubectl logs -n "${NAMESPACE}" "job/${JOB_NAME}")"
printf '%s\n' "${LOGS}"

if printf '%s' "${LOGS}" | grep -Fqx -- "${EXPECTED}"; then
  echo "verify: OK — greeting '${EXPECTED}' printed by composed Job"
  exit 0
fi

echo "verify: FAIL — expected '${EXPECTED}' in Job logs" >&2
exit 1
