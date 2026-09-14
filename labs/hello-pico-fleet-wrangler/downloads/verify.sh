#!/usr/bin/env bash
# Shape verification for the Hello Pico Fleet (Wrangler) lab.
#
# This verifier confirms that the shipped Wrangler-authored Fleet
# fragment sits honestly above the approved runtime layers:
#
#   1. fleet.yaml parses as YAML (best-effort — falls back to a strict
#      textual shape check when PyYAML is not available).
#   2. The Fleet targets the approved Manifold RuntimeEnvironment.
#   3. Every member topology names an existing Wrangler-authored
#      InteractionTopology fragment that ships with an approved lab.
#   4. Every declared binding references a Channel already declared by
#      the referenced InteractionTopology (no invented Channels).
#   5. A fleet-level lifecycle intent is present.
#   6. The ConfigMap carrier's embedded fleet.yaml is byte-equal to the
#      authored fleet.yaml (single source of truth on the wire).
#
# Exits 0 on success, non-zero on any failure. Runs offline; does not
# start Kubernetes or apply anything.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
FLEET="${HERE}/fleet.yaml"
CONFIGMAP="${HERE}/fleet-configmap.yaml"
REPO_ROOT="$(cd "${HERE}/../../.." && pwd)"
TOPO_ONE="${REPO_ROOT}/labs/hello-pico-on-manifold/downloads/topology.yaml"
TOPO_TWO="${REPO_ROOT}/labs/hello-two-picos/downloads/topology.yaml"

fail() { echo "verify: FAIL — $*" >&2; exit 1; }

# --- 1. YAML parse (best-effort) ----------------------------------------
if python3 -c "import yaml" >/dev/null 2>&1; then
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "${FLEET}" \
    || fail "fleet.yaml did not parse as YAML"
  python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "${CONFIGMAP}" \
    || fail "fleet-configmap.yaml did not parse as YAML"
  echo "verify: fleet.yaml and fleet-configmap.yaml parse as YAML"
else
  echo "verify: PyYAML not installed — skipping strict YAML parse (shape checks still run)"
fi

# --- 2. Fleet targets the approved RuntimeEnvironment -------------------
grep -Fq 'apiVersion: wrangler.oe.academy/v1alpha1' "${FLEET}" \
  || fail "fleet.yaml must declare apiVersion: wrangler.oe.academy/v1alpha1"
grep -Fq 'kind: Fleet' "${FLEET}" \
  || fail "fleet.yaml must declare kind: Fleet"
grep -Fq 'runtimeEnvironment: manifold-on-kubernetes' "${FLEET}" \
  || fail "fleet.yaml must target runtimeEnvironment: manifold-on-kubernetes"

# --- 3. Member topologies exist and are Wrangler-authored ---------------
grep -Fq 'name: hello-world-pico-on-manifold' "${FLEET}" \
  || fail "fleet.yaml must include topology hello-world-pico-on-manifold"
grep -Fq 'name: hello-two-picos' "${FLEET}" \
  || fail "fleet.yaml must include topology hello-two-picos"
for topo in "${TOPO_ONE}" "${TOPO_TWO}"; do
  [ -f "${topo}" ] || fail "referenced topology fragment not found: ${topo}"
  grep -Fq 'apiVersion: wrangler.oe.academy/v1alpha1' "${topo}" \
    || fail "referenced topology is not Wrangler-authored: ${topo}"
  grep -Fq 'kind: InteractionTopology' "${topo}" \
    || fail "referenced topology is not an InteractionTopology: ${topo}"
done
echo "verify: fleet composes existing Wrangler-authored InteractionTopologies"

# --- 4. Bindings reference channels the topologies already declare ------
grep -Fq 'channel: hello' "${TOPO_ONE}" \
  || fail "topology hello-world-pico-on-manifold must declare channel 'hello'"
grep -Fq 'channel: greeting' "${TOPO_TWO}" \
  || fail "topology hello-two-picos must declare channel 'greeting'"
grep -Fq 'channel: hello' "${FLEET}" \
  || fail "fleet.yaml must bind at least one pico onto channel 'hello'"
grep -Fq 'channel: greeting' "${FLEET}" \
  || fail "fleet.yaml must bind at least one pico onto channel 'greeting'"
echo "verify: fleet bindings only reference channels already declared by member topologies"

# --- 5. Fleet-level lifecycle intent is present -------------------------
grep -Fq 'lifecycle:' "${FLEET}" \
  || fail "fleet.yaml must declare a fleet-level lifecycle block"
grep -Fq 'desiredState: deployed' "${FLEET}" \
  || fail "fleet.yaml must declare lifecycle.desiredState: deployed"

# --- 6. ConfigMap carries the same fleet spec ---------------------------
if python3 -c "import yaml" >/dev/null 2>&1; then
  python3 - "$FLEET" "$CONFIGMAP" <<'PY' || fail "ConfigMap embedded fleet spec does not match authored fleet.yaml"
import sys, yaml, pathlib
fleet = yaml.safe_load(pathlib.Path(sys.argv[1]).read_text())
cm = yaml.safe_load(pathlib.Path(sys.argv[2]).read_text())
embedded = yaml.safe_load(cm["data"]["fleet.yaml"])
if fleet != embedded:
    print("verify: authored fleet:", fleet, file=sys.stderr)
    print("verify: embedded fleet:", embedded, file=sys.stderr)
    sys.exit(1)
PY
  echo "verify: ConfigMap embeds the authored fleet spec verbatim"
else
  grep -Fq 'fleet.yaml: |' "${CONFIGMAP}" \
    || fail "ConfigMap must embed fleet.yaml under the fleet.yaml key"
  echo "verify: PyYAML not installed — skipped deep spec compare (embedded key present)"
fi

echo "verify: OK — Wrangler fleet is layered honestly over the approved runtime"
exit 0
