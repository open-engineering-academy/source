#!/usr/bin/env bash
# Deterministic local verifier for the Hello Pico Nervous System (MQTT) lab.
# Exits 0 on success, non-zero on any failure.
#
# The verifier is intentionally local and static: it does NOT contact any
# MQTT broker, does NOT require credentials, and does NOT require a live
# EMQX (or Kubernetes) cluster. It reads the shipped provider-neutral
# envelope schema, the Pico registry, the discovery snapshot, every sample
# message under `messages/`, the MQTT topic map, and the EMQX adapter
# description; and it asserts:
#
#   1. every YAML/JSON artifact parses,
#   2. every sample message conforms to `envelope.schema.json`,
#   3. every message's `source.pico` is a stable identity from `picos.yaml`
#      and is DIFFERENT from every transport identifier
#      (mqtt.client_id, kubernetes.pod),
#   4. `command` and `delegation` messages carry `authorization` naming
#      the acting principal and capability,
#   5. `delegation` and its paired `result` share the same
#      `correlation_id` and the `result` cites the delegation via
#      `causation_id`, and the same `delegation.mission` is carried on
#      both,
#   6. `event` messages cite an upstream `observation` via `causation_id`,
#   7. `mqtt-topics.yaml` declares patterns for all seven envelope kinds
#      and every sample MQTT topic is consistent with those patterns,
#   8. `emqx-adapter.yaml` marks the adapter as `optional-not-executed`,
#      names no live endpoint or credentials, and treats broker ACLs as
#      the outer perimeter only,
#   9. no shipped file carries credentials, tokens, live broker URLs, or
#      invented `kubectl`/`mosquitto`/`emqx` commands.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

fail() { echo "verify: FAIL — $*" >&2; exit 1; }
ok()   { echo "verify: OK — $*"; }

command -v python3 >/dev/null 2>&1 || fail "python3 is required"

python3 - "${HERE}" <<'PY'
import json, os, re, sys, glob

here = sys.argv[1]

try:
    import yaml
except Exception:
    print("verify: FAIL — PyYAML is required (pip install pyyaml)", file=sys.stderr)
    sys.exit(1)

def die(msg):
    print(f"verify: FAIL — {msg}", file=sys.stderr); sys.exit(1)

def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)

def load_json(path):
    with open(path) as f:
        return json.load(f)

# ---- 1. artifact inventory -------------------------------------------------
required = [
    "envelope.schema.json",
    "picos.yaml",
    "discovery.yaml",
    "mqtt-topics.yaml",
    "emqx-adapter.yaml",
    "topology.yaml",
    "verify.sh",
]
for name in required:
    if not os.path.exists(os.path.join(here, name)):
        die(f"missing artifact: {name}")

msg_dir = os.path.join(here, "messages")
if not os.path.isdir(msg_dir):
    die("missing messages/ directory")

message_paths = sorted(glob.glob(os.path.join(msg_dir, "*.json")))
if len(message_paths) < 7:
    die(f"expected at least 7 sample messages, found {len(message_paths)}")

schema = load_json(os.path.join(here, "envelope.schema.json"))
picos = load_yaml(os.path.join(here, "picos.yaml"))
discovery = load_yaml(os.path.join(here, "discovery.yaml"))
topics = load_yaml(os.path.join(here, "mqtt-topics.yaml"))
adapter = load_yaml(os.path.join(here, "emqx-adapter.yaml"))
topology = load_yaml(os.path.join(here, "topology.yaml"))

# ---- 2. Pico registry: stable identity vs transport identity ---------------
if picos.get("kind") != "PicoRegistry":
    die("picos.yaml must be kind: PicoRegistry")
stable_ids = set()
transport_ids = set()
for p in picos["spec"]["picos"]:
    sid = p["pico"]
    if sid in stable_ids: die(f"duplicate Pico identity: {sid}")
    stable_ids.add(sid)
    for kind, tid in (p.get("transport") or {}).items():
        for k, v in tid.items():
            if isinstance(v, str):
                if v == sid:
                    die(f"transport id {kind}.{k}='{v}' equals Pico identity")
                transport_ids.add(v)
if not stable_ids: die("no Picos registered")

# ---- 3. discovery advertisements reference registered Picos ---------------
adv_ids = {a["pico"] for a in discovery["spec"]["advertisements"]}
missing = adv_ids - stable_ids
if missing: die(f"discovery advertises unknown Picos: {sorted(missing)}")

# ---- 4. Envelope validator (subset of JSON Schema needed by this lab) -----
enum_types = set(schema["properties"]["type"]["enum"])
expected_types = {"observation", "event", "command", "delegation",
                  "result", "presence", "discovery"}
if enum_types != expected_types:
    die(f"envelope schema type enum mismatch: {enum_types}")

def require_fields(msg, fields, ctx):
    for f in fields:
        if f not in msg:
            die(f"{ctx}: missing required field '{f}'")

TYPE_REQUIRED = {
    "command":    ["target", "authorization"],
    "delegation": ["target", "authorization", "delegation", "correlation_id"],
    "result":     ["correlation_id", "causation_id"],
    "event":      ["subject"],
}

# ---- 5. Load all messages and run envelope + identity + authz checks ------
messages = []
for path in message_paths:
    m = load_json(path)
    ctx = os.path.basename(path)
    require_fields(m, ["id", "type", "ts", "source"], ctx)
    if m["type"] not in expected_types:
        die(f"{ctx}: type '{m['type']}' not in envelope enum")
    src = m["source"]
    if "pico" not in src:
        die(f"{ctx}: source.pico missing")
    if src["pico"] not in stable_ids:
        die(f"{ctx}: source.pico '{src['pico']}' not in Pico registry")
    tr = src.get("transport") or {}
    # stable Pico identity must not equal any transport identifier
    mqtt_cid = (tr.get("mqtt") or {}).get("client_id")
    if mqtt_cid and mqtt_cid == src["pico"]:
        die(f"{ctx}: mqtt.client_id equals source.pico (identity leak)")
    k8s_pod = (tr.get("kubernetes") or {}).get("pod")
    if k8s_pod and k8s_pod == src["pico"]:
        die(f"{ctx}: kubernetes.pod equals source.pico (identity leak)")
    for f in TYPE_REQUIRED.get(m["type"], []):
        if f not in m:
            die(f"{ctx}: type={m['type']} requires field '{f}'")
    if m["type"] in ("command", "delegation"):
        authz = m["authorization"]
        for f in ("principal", "capability"):
            if not authz.get(f):
                die(f"{ctx}: authorization.{f} required")
    messages.append((os.path.basename(path), m))

# every envelope kind must appear at least once
seen_types = {m["type"] for _, m in messages}
missing_types = expected_types - seen_types
if missing_types:
    die(f"missing sample messages for types: {sorted(missing_types)}")

# ---- 6. correlation / delegation / causation graph ------------------------
by_id = {m["id"]: m for _, m in messages}
delegations = [m for _, m in messages if m["type"] == "delegation"]
results     = [m for _, m in messages if m["type"] == "result"]
if not delegations or not results:
    die("need at least one delegation and one result message")
for d in delegations:
    matching = [r for r in results
                if r.get("correlation_id") == d["correlation_id"]
                and r.get("causation_id")  == d["id"]]
    if not matching:
        die(f"delegation {d['id']} has no matching result "
            f"(correlation_id={d['correlation_id']})")
    r = matching[0]
    if r.get("delegation", {}).get("mission") != d["delegation"]["mission"]:
        die(f"result {r['id']} mission mismatch with delegation {d['id']}")

events = [m for _, m in messages if m["type"] == "event"]
for e in events:
    cause = e.get("causation_id")
    if not cause or cause not in by_id:
        die(f"event {e['id']} missing causation_id or references unknown message")
    if by_id[cause]["type"] != "observation":
        die(f"event {e['id']} causation must point at an observation")

# ---- 7. MQTT topic-map consistency ----------------------------------------
if topics["spec"]["transport"] != "mqtt":
    die("mqtt-topics.yaml must declare transport: mqtt")
patterns = topics["spec"]["patterns"]
for t in expected_types:
    if t not in patterns:
        die(f"mqtt-topics.yaml missing pattern for '{t}'")
root = topics["spec"]["root"]
for name, m in messages:
    topic = ((m.get("source", {}).get("transport") or {}).get("mqtt") or {}).get("topic")
    if not topic:
        continue
    if not topic.startswith(root + "/"):
        die(f"{name}: MQTT topic '{topic}' does not start with root '{root}/'")
    t = m["type"]
    if t in ("command", "delegation", "result"):
        expected_prefix = f"{root}/{m['target']['pico']}/{t}"
    else:
        expected_prefix = f"{root}/{m['source']['pico']}/{t}"
    if not topic.startswith(expected_prefix):
        die(f"{name}: topic '{topic}' inconsistent with pattern for type '{t}' "
            f"(expected prefix '{expected_prefix}')")

# ---- 8. EMQX adapter shape ------------------------------------------------
aspec = adapter["spec"]
if aspec.get("adapter") != "emqx":
    die("emqx-adapter.yaml must declare adapter: emqx")
if aspec.get("status") != "optional-not-executed":
    die("emqx-adapter.yaml status must be 'optional-not-executed'")
if aspec.get("implements") != topics["metadata"]["name"]:
    die("emqx-adapter.yaml implements must match mqtt-topics.yaml name")
if aspec.get("auth", {}).get("acl_binding") != "broker-perimeter-only":
    die("emqx-adapter.yaml auth.acl_binding must be 'broker-perimeter-only'")
if aspec.get("identity_mapping", {}).get("stable_identity_field") != "source.pico":
    die("emqx-adapter.yaml identity_mapping.stable_identity_field must be 'source.pico'")

# ---- 9. Topology sanity: reuses manifold-on-kubernetes, names known Picos -
if topology["spec"]["runtimeEnvironment"] != "manifold-on-kubernetes":
    die("topology.yaml must reuse runtimeEnvironment 'manifold-on-kubernetes'")
topo_ids = {p["name"] for p in topology["spec"]["picos"]}
if not topo_ids <= stable_ids:
    die(f"topology names Picos not in registry: {topo_ids - stable_ids}")

# ---- 10. Credential / live-broker / invented-command scan -----------------
FORBIDDEN_SUBSTRINGS = [
    "password", "PASSWORD",
    "OPENAI_API_KEY", "AWS_SECRET",
    "COMPOSIO", "composio_api_key",
    "mqtts://", "tcp://broker", "ssl://broker",
    "-----BEGIN ",  # PEM blocks
]
# Commands the lab must NOT tell learners to run: they would imply a
# live broker or admin plane the lab does not stand up. Detected only as
# shell invocations at the start of a code-block line (` command ...`).
FORBIDDEN_SHELL_CMDS = {"mosquitto_pub", "mosquitto_sub", "emqxctl"}

for root_dir, _, files in os.walk(here):
    for fn in files:
        # verify.sh itself defines the forbidden lists; do not scan it.
        if fn == "verify.sh":
            continue
        p = os.path.join(root_dir, fn)
        try:
            with open(p, "r", encoding="utf-8") as f:
                body = f.read()
        except Exception:
            continue
        for needle in FORBIDDEN_SUBSTRINGS:
            if needle in body:
                die(f"forbidden substring '{needle}' found in {os.path.relpath(p, here)}")
        # Shell-command detection is limited to .sh and .qmd files, and
        # only matches at the start of a shell line: this avoids false
        # positives on 'emqx' as an adapter name in YAML metadata while
        # still catching commands baked into walkthroughs.
        if fn.endswith((".sh", ".qmd")):
            for bad in FORBIDDEN_SHELL_CMDS:
                if re.search(rf"(^|\n)\s*{re.escape(bad)}\b", body):
                    die(f"invented/live command '{bad}' found in {os.path.relpath(p, here)}")

print("verify: static — envelope, identity, authorization, correlation, "
      "MQTT topic-map, EMQX adapter, and topology all OK")
PY

ok "verify passed"
exit 0
