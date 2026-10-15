#!/usr/bin/env bash
# Automatable verification for the Hello Pico Hands (Kubernetes) lab.
# Exits 0 on success, non-zero on any failure.
#
# The verifier has two paths:
#
#   1. Static checks (always run) — parse every shipped YAML/JSON,
#      confirm the Hands contract and rules are well-formed, confirm the
#      RBAC boundary is narrow and namespaced, and confirm the Pico
#      engine Pod does not use hostPath / privileged / added capabilities
#      and does not carry Composio (or other external) credentials.
#
#   2. Live minikube path (runs when `kubectl` is on PATH and a cluster
#      is reachable) — applies the manifests, waits for the Pico engine
#      Pod to Succeed, and asserts:
#        - the state ConfigMap now carries data.greeted = the event value,
#        - the events ConfigMap carries the pico.hand.requested,
#          pico.hand.authorized, pico.hand.succeeded lifecycle,
#        - the Pod logs contain a single normalized `evidence:` JSON line.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
NS="${NAMESPACE:-hands}"
POD="${POD:-hello-hands-pico}"
STATE_CM="${STATE_CM:-pico-hello-hands-state}"
EVENTS_CM="${EVENTS_CM:-pico-hello-hands-events}"
EXPECTED_VALUE="${EXPECTED_VALUE:-Hello, Pico!}"

fail() { echo "verify: FAIL — $*" >&2; exit 1; }
ok()   { echo "verify: OK — $*"; }

# --- Static checks (always run) -------------------------------------------

echo "verify: static — YAML/JSON parse and Hands-contract shape"
command -v python3 >/dev/null 2>&1 || fail "python3 is required for static checks"

python3 - "${HERE}" <<'PY'
import json, os, sys, re
here = sys.argv[1]
try:
    import yaml
except Exception:
    print("verify: FAIL — PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(1)

def load_all(path):
    with open(path) as f:
        return [d for d in yaml.safe_load_all(f) if d is not None]

def die(msg):
    print(f"verify: FAIL — {msg}", file=sys.stderr); sys.exit(1)

files = [
    "01-namespace.yaml", "02-hands-contract.yaml", "03-rbac.yaml",
    "04-state-configmap.yaml", "05-events-configmap.yaml",
    "06-pico-engine.yaml", "event.json",
]
for name in files:
    p = os.path.join(here, name)
    if not os.path.exists(p): die(f"missing download: {name}")

# event.json parses
json.load(open(os.path.join(here, "event.json")))

# Hands contract shape
contract = load_all(os.path.join(here, "02-hands-contract.yaml"))[0]
data = contract["data"]
hands = json.loads(data["hands.json"])
rules = json.loads(data["rules.json"])
identity = json.loads(data["identity.json"])
if hands["provider"] != "kubernetes": die("hands.provider must be 'kubernetes'")
caps = {c["name"] for c in hands["capabilities"]}
if "pico.state.set" not in caps: die("capability 'pico.state.set' not declared")
for c in hands["capabilities"]:
    if not c.get("reversible"): die(f"capability {c['name']} must be reversible")
    t = c.get("target", {})
    if t.get("namespace") != "hands": die("capability target namespace must be 'hands'")
    if t.get("resourceName") not in {"pico-hello-hands-state"}:
        die(f"capability {c['name']} target must be Pico-owned ConfigMap")
if not identity.get("actor", {}).get("pico"): die("identity missing actor.pico")

allow = [r for r in rules["rules"] if r["capability"] == "pico.state.set" and r["effect"] == "allow"]
if not allow: die("rules.json must allow pico.state.set")
if "hands" not in allow[0]["constraints"]["namespaces"]:
    die("allow rule must constrain to 'hands' namespace")

# RBAC boundary
rbac = load_all(os.path.join(here, "03-rbac.yaml"))
kinds = {d["kind"] for d in rbac}
if kinds != {"ServiceAccount", "Role", "RoleBinding"}:
    die(f"03-rbac.yaml must declare exactly SA/Role/RoleBinding, got {kinds}")
for d in rbac:
    if d["kind"] == "Role":
        if d["metadata"]["namespace"] != "hands": die("Role must be namespaced to 'hands'")
        for rule in d["rules"]:
            verbs = set(rule.get("verbs", []))
            forbidden = {"delete", "deletecollection", "create", "update", "*"}
            bad = verbs & forbidden
            if bad: die(f"Role grants forbidden verbs: {sorted(bad)}")
            if rule.get("resources") != ["configmaps"]:
                die("Role must only target configmaps")
            names = set(rule.get("resourceNames", []))
            if not names: die("Role must be constrained by resourceNames")
            if not names <= {"pico-hello-hands-state", "pico-hello-hands-events"}:
                die(f"Role resourceNames outside Pico-owned surface: {names}")
    if d["kind"] == "RoleBinding":
        if d["roleRef"]["kind"] != "Role":
            die("RoleBinding must reference a Role, not a ClusterRole")

# Pico engine Pod hardening + no Composio creds
pod = load_all(os.path.join(here, "06-pico-engine.yaml"))[0]
spec = pod["spec"]
if spec.get("hostNetwork") or spec.get("hostPID") or spec.get("hostIPC"):
    die("Pod must not use host namespaces")
for v in spec.get("volumes", []):
    if "hostPath" in v: die("Pod must not mount hostPath volumes")
for c in spec["containers"]:
    sc = c.get("securityContext", {})
    if sc.get("privileged"): die("container must not be privileged")
    if sc.get("allowPrivilegeEscalation", True): die("must set allowPrivilegeEscalation=false")
    caps_add = (sc.get("capabilities") or {}).get("add") or []
    if caps_add: die(f"container must not add capabilities: {caps_add}")
    body = "\n".join(c.get("command", []) or []) + "\n" + "\n".join(c.get("args", []) or [])
    for needle in ("COMPOSIO", "composio", "gmail", "slack.com", "githubtoken", "OPENAI_API_KEY"):
        if needle in body: die(f"credential/provider leak in engine script: {needle}")

print("verify: static — Hands contract, RBAC boundary, and Pod hardening OK")
PY

echo "verify: static — shell hardening of engine script"
grep -q "kubectl -n \"\${NS}\" patch configmap" "${HERE}/06-pico-engine.yaml" \
  || fail "engine script does not perform the expected narrow patch call"
grep -q "kubectl.*delete" "${HERE}/06-pico-engine.yaml" \
  && fail "engine script must not call kubectl delete"
ok "static checks passed"

# --- Live minikube path (optional) ----------------------------------------

if ! command -v kubectl >/dev/null 2>&1; then
  ok "static only (kubectl not on PATH); skipping live checks"; exit 0
fi
if ! kubectl version --request-timeout=2s >/dev/null 2>&1; then
  ok "static only (no reachable cluster); skipping live checks"; exit 0
fi

echo "verify: live — applying Hands contract, RBAC, state, events, and Pico engine"
kubectl apply -f "${HERE}/01-namespace.yaml" >/dev/null
kubectl apply -f "${HERE}/02-hands-contract.yaml" >/dev/null
kubectl apply -f "${HERE}/03-rbac.yaml" >/dev/null
kubectl apply -f "${HERE}/04-state-configmap.yaml" >/dev/null
kubectl apply -f "${HERE}/05-events-configmap.yaml" >/dev/null
kubectl apply -f "${HERE}/06-pico-engine.yaml" >/dev/null

echo "verify: live — waiting for ${POD} to Succeed"
kubectl -n "${NS}" wait --for=jsonpath='{.status.phase}=Succeeded' \
  --timeout=120s "pod/${POD}"

GREETED="$(kubectl -n "${NS}" get configmap "${STATE_CM}" \
  -o jsonpath='{.data.greeted}')"
[ "${GREETED}" = "${EXPECTED_VALUE}" ] \
  || fail "state ConfigMap data.greeted='${GREETED}' (expected '${EXPECTED_VALUE}')"

EVENTS="$(kubectl -n "${NS}" get configmap "${EVENTS_CM}" \
  -o jsonpath='{.data.events}')"
for e in pico.hand.requested pico.hand.authorized pico.hand.succeeded; do
  printf '%s' "${EVENTS}" | grep -Fq "$e" \
    || fail "events ConfigMap missing ${e} (got: ${EVENTS})"
done

LOGS="$(kubectl -n "${NS}" logs "pod/${POD}")"
printf '%s' "${LOGS}" | grep -Fq '"status":"succeeded"' \
  || fail "engine logs missing normalized evidence with status=succeeded"

ok "live — state=${GREETED}, lifecycle=[requested, authorized, succeeded]"
exit 0
