#!/usr/bin/env bash
# Automatable verification for the Hello Two Picos lab.
# Exits 0 on success, non-zero on any failure.
#
# Prerequisites: `kubectl` is on PATH and points at the minikube cluster
# where the lab was deployed (see labs/hello-two-picos/objectives.qmd).
# The consumer Pico Pod, the greeting Channel Service, and the topology
# ConfigMap have already been applied and the consumer is Ready.
#
# The script:
#   1. waits for the consumer Pico Pod to be Ready (idempotent),
#   2. applies the producer Pico Pod (single-shot publisher),
#   3. waits for the producer Pod to Succeed after it sends one event,
#   4. waits for the consumer Pod to Succeed after it consumes that event,
#   5. confirms the consumer's logs contain exactly one Observation line
#      carrying the expected greeting value from the producer.
set -euo pipefail

NAMESPACE="${NAMESPACE:-manifold}"
CONSUMER_POD="${CONSUMER_POD:-hello-consumer-pico}"
PRODUCER_POD="${PRODUCER_POD:-hello-producer-pico}"
PRODUCER_MANIFEST="${PRODUCER_MANIFEST:-05-producer-pico.yaml}"
EXPECTED_FROM="${EXPECTED_FROM:-hello-producer-pico}"
EXPECTED_VALUE="${EXPECTED_VALUE:-Hello, Pico!}"

if [ ! -f "${PRODUCER_MANIFEST}" ]; then
  echo "verify: FAIL — producer manifest '${PRODUCER_MANIFEST}' not found in $(pwd)" >&2
  exit 1
fi

echo "verify: waiting for consumer Pico Pod ${CONSUMER_POD} to be Ready"
kubectl -n "${NAMESPACE}" wait --for=condition=Ready --timeout=60s \
  "pod/${CONSUMER_POD}"

echo "verify: applying producer Pico Pod ${PRODUCER_POD}"
kubectl -n "${NAMESPACE}" apply -f "${PRODUCER_MANIFEST}"

echo "verify: waiting for producer Pico Pod ${PRODUCER_POD} to Succeed"
kubectl -n "${NAMESPACE}" wait --for=jsonpath='{.status.phase}=Succeeded' \
  --timeout=60s "pod/${PRODUCER_POD}"

echo "verify: waiting for consumer Pico Pod ${CONSUMER_POD} to Succeed"
kubectl -n "${NAMESPACE}" wait --for=jsonpath='{.status.phase}=Succeeded' \
  --timeout=60s "pod/${CONSUMER_POD}"

echo "verify: reading consumer Pico Pod logs"
CONSUMER_LOGS="$(kubectl -n "${NAMESPACE}" logs "pod/${CONSUMER_POD}")"
printf '%s\n' "${CONSUMER_LOGS}"

echo "verify: reading producer Pico Pod logs"
PRODUCER_LOGS="$(kubectl -n "${NAMESPACE}" logs "pod/${PRODUCER_POD}")"
printf '%s\n' "${PRODUCER_LOGS}"

EXPECTED_OBSERVATION="pico[hello-consumer-pico] observation: greeting from ${EXPECTED_FROM}: ${EXPECTED_VALUE}"
EXPECTED_SENT="pico[hello-producer-pico] sent: hello.greeting to hello-consumer-pico via channel 'greeting'"

if ! printf '%s' "${PRODUCER_LOGS}" | grep -Fqx -- "${EXPECTED_SENT}"; then
  echo "verify: FAIL — expected producer 'sent' line not found:" >&2
  echo "verify: FAIL — expected: ${EXPECTED_SENT}" >&2
  exit 1
fi

if ! printf '%s' "${CONSUMER_LOGS}" | grep -Fqx -- "${EXPECTED_OBSERVATION}"; then
  echo "verify: FAIL — expected consumer Observation line not found:" >&2
  echo "verify: FAIL — expected: ${EXPECTED_OBSERVATION}" >&2
  exit 1
fi

echo "verify: OK — producer emitted one hello.greeting event and consumer produced one Observation '${EXPECTED_OBSERVATION}'"
exit 0
