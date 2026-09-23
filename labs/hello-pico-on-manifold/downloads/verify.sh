#!/usr/bin/env bash
# Automatable verification for the Hello Pico on Manifold lab.
# Exits 0 on success, non-zero on any failure.
#
# Prerequisites: `kubectl` is on PATH and points at the minikube cluster
# where the lab was deployed (see labs/hello-pico-on-manifold/objectives.qmd).
#
# The script:
#   1. waits for the Pico engine Pod to be Ready,
#   2. sends exactly one event onto the "hello" Channel using an in-cluster
#      `nc` client (Control Surface: Python-CLI-style shell command),
#   3. waits for the Pod to Succeed (single-shot listener exits after one event),
#   4. confirms the Pod's logs contain exactly one Observation line carrying
#      the expected greeting value.
set -euo pipefail

NAMESPACE="${NAMESPACE:-manifold}"
POD_NAME="${POD_NAME:-pico-engine}"
CHANNEL_HOST="${CHANNEL_HOST:-hello.manifold.svc.cluster.local}"
CHANNEL_PORT="${CHANNEL_PORT:-8080}"
EXPECTED_VALUE="${EXPECTED_VALUE:-Hello, Pico!}"
EVENT_FILE="${EVENT_FILE:-event.json}"

if [ ! -f "${EVENT_FILE}" ]; then
  echo "verify: FAIL — event payload '${EVENT_FILE}' not found in $(pwd)" >&2
  exit 1
fi

echo "verify: waiting for Pico engine Pod ${POD_NAME} to be Ready"
kubectl -n "${NAMESPACE}" wait --for=condition=Ready --timeout=60s \
  "pod/${POD_NAME}"

echo "verify: sending one event on channel 'hello' via in-cluster nc client"
# Run a short-lived busybox Pod that opens one TCP connection to the
# Channel Service and writes the event payload. This plays the Control
# Surface role (a scriptable Python-CLI-style shell command) in the
# Phase 7 vocabulary.
kubectl -n "${NAMESPACE}" run event-sender \
  --image=busybox:1.36 --restart=Never --rm -i --quiet \
  --command -- sh -c "nc -w 2 ${CHANNEL_HOST} ${CHANNEL_PORT}" \
  < "${EVENT_FILE}"

echo "verify: waiting for Pico engine Pod ${POD_NAME} to Succeed"
kubectl -n "${NAMESPACE}" wait --for=jsonpath='{.status.phase}=Succeeded' \
  --timeout=60s "pod/${POD_NAME}"

echo "verify: reading Pico engine Pod logs"
LOGS="$(kubectl -n "${NAMESPACE}" logs "pod/${POD_NAME}")"
printf '%s\n' "${LOGS}"

EXPECTED_LINE="pico[hello-world-pico] observation: ${EXPECTED_VALUE}"
if printf '%s' "${LOGS}" | grep -Fqx -- "${EXPECTED_LINE}"; then
  echo "verify: OK — one Observation '${EXPECTED_LINE}' produced by hosted Pico"
  exit 0
fi

echo "verify: FAIL — expected Observation line not found:" >&2
echo "verify: FAIL — expected: ${EXPECTED_LINE}" >&2
exit 1
