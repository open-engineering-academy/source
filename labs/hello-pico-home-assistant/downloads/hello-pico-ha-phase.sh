#!/usr/bin/env bash
# Home Assistant command_line helper for the Hello Pico on Home Assistant
# lab. Prints just the Pico engine Pod phase (e.g. "Running", "Succeeded")
# by asking the approved Python CLI ControlSurface. This helper adds no
# runtime concept of its own: it wraps `pico runtime inspect` and
# extracts the phase from the CLI's declared-truth output.
#
# Exits 0 with a single-word phase on stdout on success; exits 0 with
# "unknown" on stdout on any failure so the HA sensor state stays
# well-defined instead of becoming `unavailable` on transient errors.

set -uo pipefail

NAMESPACE="${NAMESPACE:-manifold}"
LAB="${LAB:-hello-pico-on-manifold}"
POD_NAME="${POD_NAME:-pico-engine}"

phase="$(pico runtime inspect --lab "${LAB}" --namespace "${NAMESPACE}" 2>/dev/null \
  | awk -v pod="${POD_NAME}" '$1 == pod {print $2; exit}')"

if [ -z "${phase}" ]; then
  echo "unknown"
  exit 0
fi

echo "${phase}"
