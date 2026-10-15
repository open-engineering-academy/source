#!/usr/bin/env bash
# Shape verification for the Hello Pico on Home Assistant lab.
#
# This verifier confirms that the shipped Home Assistant integration
# path is layered honestly over the approved runtime path:
#
#   1. `configuration.yaml` parses as YAML (best-effort — falls back to
#      a strict textual shape check when PyYAML is not available).
#   2. The command_line sensor invokes the shipped helper script.
#   3. The helper script delegates to `pico runtime inspect` for the
#      approved lab and extracts a single phase word.
#   4. The shell_command argv is byte-equal to a `pico runtime emit`
#      invocation against the same Wrangler-declared Channel.
#   5. `event.json` is byte-identical to the approved
#      `hello-pico-on-manifold` lab's `event.json` (single source of
#      truth for the one event on the wire).
#
# Exits 0 on success, non-zero on any failure. Runs offline; does not
# start Kubernetes or Home Assistant.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${HERE}/configuration.yaml"
HELPER="${HERE}/hello-pico-ha-phase.sh"
EVENT="${HERE}/event.json"
REPO_ROOT="$(cd "${HERE}/../../.." && pwd)"
REFERENCE_EVENT="${REPO_ROOT}/labs/hello-pico-on-manifold/downloads/event.json"

fail() { echo "verify: FAIL — $*" >&2; exit 1; }

# --- 1. YAML parse (best-effort) ----------------------------------------
if python3 -c "import yaml" >/dev/null 2>&1; then
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "${CONFIG}" \
    || fail "configuration.yaml did not parse as YAML"
  echo "verify: configuration.yaml parses as YAML"
else
  echo "verify: PyYAML not installed — skipping strict YAML parse (shape checks still run)"
fi

# --- 2. Sensor references the shipped helper ----------------------------
grep -Fq 'command: "/config/hello-pico/hello-pico-ha-phase.sh"' "${CONFIG}" \
  || fail "command_line sensor must invoke /config/hello-pico/hello-pico-ha-phase.sh"
grep -Fq 'name: hello_pico_engine_phase' "${CONFIG}" \
  || fail "expected sensor name 'hello_pico_engine_phase'"

# --- 3. Helper delegates to the approved CLI ----------------------------
grep -Fq 'pico runtime inspect --lab "${LAB}" --namespace "${NAMESPACE}"' "${HELPER}" \
  || fail "helper must delegate to 'pico runtime inspect' with LAB/NAMESPACE"
grep -Fq 'LAB="${LAB:-hello-pico-on-manifold}"' "${HELPER}" \
  || fail "helper must default LAB to hello-pico-on-manifold"
grep -Fq 'NAMESPACE="${NAMESPACE:-manifold}"' "${HELPER}" \
  || fail "helper must default NAMESPACE to manifold"

# --- 4. Shell_command argv matches the approved CLI ---------------------
EXPECTED_EMIT="pico runtime emit --lab hello-pico-on-manifold --channel hello --value 'Hello, Pico!'"
grep -Fq "hello_pico_send_greeting: \"${EXPECTED_EMIT}\"" "${CONFIG}" \
  || fail "shell_command 'hello_pico_send_greeting' argv does not match approved CLI: ${EXPECTED_EMIT}"

# --- 5. UI trigger is present and bound to the shell_command ------------
grep -Fq 'input_button:' "${CONFIG}" \
  || fail "input_button must be declared in configuration.yaml"
grep -Fq 'hello_pico_send_greeting:' "${CONFIG}" \
  || fail "expected input_button 'hello_pico_send_greeting'"
grep -Fq 'entity_id: input_button.hello_pico_send_greeting' "${CONFIG}" \
  || fail "automation must trigger on input_button.hello_pico_send_greeting"
grep -Fq 'service: shell_command.hello_pico_send_greeting' "${CONFIG}" \
  || fail "automation must call shell_command.hello_pico_send_greeting"

# --- 6. event.json is byte-identical to the approved lab's payload ------
if [ ! -f "${REFERENCE_EVENT}" ]; then
  fail "reference event.json not found: ${REFERENCE_EVENT}"
fi
if ! diff -q "${EVENT}" "${REFERENCE_EVENT}" >/dev/null; then
  fail "event.json is not byte-identical to ${REFERENCE_EVENT}"
fi
echo "verify: event.json matches labs/hello-pico-on-manifold/downloads/event.json byte-for-byte"

# --- 7. No architectural bypass in the shipped files --------------------
# Strip full-line comments before checking so the guard rail only inspects
# executable content, not doc lines that legitimately mention `kubectl`.
for f in "${CONFIG}" "${HELPER}"; do
  if sed -e 's/^[[:space:]]*#.*$//' -e 's/[[:space:]]#.*$//' "${f}" \
       | grep -Eq '(^|[^[:alnum:]_-])(kubectl|helm)($|[^[:alnum:]_-])'; then
    fail "shipped file executes kubectl/helm directly (must go through pico runtime): ${f}"
  fi
done
echo "verify: shipped files do not bypass the pico runtime CLI (no direct kubectl/helm calls)"

echo "verify: OK — Home Assistant integration path is layered over the approved runtime"
exit 0
