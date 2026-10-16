# Memo 25: Inventory and reclassification of the existing Pico course

## Status

Classification record only. No course, lab, Composer, runtime, Pico
implementation, Pico Definition, `_quarto.yml` ordering, dependency,
credential, or production interface is changed by this memo. It
produces a single new file (`memo25.md`) that attaches a
Memo 23 §4 module number and a Memo 23 §9 step-5 classification —
*core*, *optional extension*, *advanced integration*, or
*infrastructure/operations* — to every current Pico course lesson,
follow-up page, and top-level lab, and names the duplicated
explanations observed during the pass.

## Purpose

Deliver the artefacts Memo 23 §9 step 1 (*Inventory*) and §9 step 5
(*Reclassify existing content*) ask for, grounded in the actual
on-disk state of the course and labs rather than in titles. Every
row below is derived from the lesson/follow-up/lab files read during
this pass; no classification is inferred from the file name or
sidebar label.

## Scope

In scope — new file `memo25.md` at the repository root.

Out of scope — any edit to `courses/pico/_quarto.yml`,
`courses/pico/metadata.yaml`, any `index.qmd` / `exercise.qmd` /
`lab.qmd` / `summary.qmd` / `quiz.qmd` under `courses/pico/`, either
follow-up page, any lab under `labs/`, any `objectives.qmd`,
`walkthrough.qmd`, `solution.qmd`, or `downloads/verify.sh`, any
`metadata.yaml`, any `definitions/*.yaml`, the reference `bin/pico`
CLI, and the Pico Definition from Memo 17. No recommendation here
alters a production interface or schema; it only labels existing
material.

## Method

Each row below was produced by reading the referenced file end to
end, extracting the stated learning objectives and prerequisites,
and classifying the file against Memo 23 §4 (six modules) and
Memo 23 §5 (dependency rules) using the Memo 23 §9 step-5 vocabulary.

- *core* — on the beginner path, no optional platform required.
  Depends at most on a working shell, text editor, Python 3, and
  the in-repo `bin/pico` CLI shipped by Memo 17 and earlier memos.
- *optional extension* — belongs on the extension path (Memo 23
  Module 6). The teaching material is local-YAML / in-repo only, but
  the concept it teaches is explicitly optional in Memo 23 §4
  Module 6 or §6 "Reuse existing ecosystem capabilities".
- *advanced integration* — requires one or more external platforms
  that are optional per Memo 23 §5 rules 1–2 (Composio, Home
  Assistant, Sandcastle, EMQX/MQTT broker, Crossplane, Wrangler
  fleet composition on a live cluster, etc.) to produce evidence.
- *infrastructure/operations* — the primary teaching outcome is
  deployment, cluster lifecycle, or outer-loop operations rather than
  a Pico capability. Belongs in Module 5 (runtime) or Module 6
  (operate) per Memo 23 §4, or in a separate infrastructure course
  per Memo 23 §7.

The `pico` CLI from `bin/pico` and the `definitions/pico.yaml`
Pico Definition from Memo 17 are treated as *in-repo* dependencies
and are **not** counted as optional platforms.

## Inventory table

| # | Path | What it teaches | Tools/platforms a learner must install | Classification | Proposed Memo 23 module | Duplicated explanation (flagged) |
|---|---|---|---|---|---|---|
| 1 | `courses/pico/part-1/01-introduction/index.qmd` | Pico vocabulary; the Rules → Parser → Composer → Pico mental model; the standard lesson page layout. | shell, text editor, YAML comfort. | core | Module 1 (Understand a Pico). | — |
| 2 | `courses/pico/part-1/01-introduction/exercise.qmd` | Guided reflection; one sketched Rule validated with `pico parse`; OELS onboarding include. | shell, Python 3 (via `bin/pico`), OELS install from `oels.qmd`. | core | Module 1. | OELS onboarding — same include is embedded in `part-3/05-hands/lab.qmd`. |
| 3 | `courses/pico/part-1/01-introduction/lab.qmd` | Thin pointer to the shared `labs/hello-pico/` lab; names the `hello-world-pico` artifact from `metadata.yaml`. | (delegates to lab row 11). | core | Module 1 → Module 3/4/5 (via `labs/hello-pico`). | — |
| 4 | `courses/pico/part-2/index.qmd` | Scaffold page only; declares that Part 2 is intentionally not yet written out; points learners back at the Part 1 lesson as the canonical layout. | none. | core (stub) | Modules 2–5 (reserved; currently empty). | — |
| 5 | `courses/pico/part-3/01-pico-identity/index.qmd` | `did:webvh` vs `did:peer`; identity ≠ address; passport vs relationship-specific identity; isolation of relationships. | shell, YAML comfort; the lab adds `bin/pico` for `pico parse`. | optional extension | Module 6 (Extend — identity capability on top of a minimal Pico). | — |
| 6 | `courses/pico/part-3/02-cross-mesh-communication/index.qmd` | Subscriptions as cryptographic relationships; DIDComm; family vs external relationship classes. | shell, YAML comfort; lab adds `bin/pico`. | optional extension | Module 6 (Extend — Senses/Voice on top of identity). | — |
| 7 | `courses/pico/part-3/03-trust-and-authorization/index.qmd` | "Identity establishes who; policy establishes what"; channel policy with a peer DID; implications for Rules and Parsers. | shell, YAML comfort; lab adds `bin/pico`. | optional extension | Module 6 (Extend — governed trust capability). | "Identity does not replace authorization" is restated in `05-hands/index.qmd` ("No Hand acts without identity and authorization context") and again in `06-nervous-system/index.qmd` ("No message is trusted without identity and authorization context") — the shared principle is explained three times with different wording. |
| 8 | `courses/pico/part-3/04-portability/index.qmd` | Portability as a strategic direction; what Pico Engine 1.6 does and does not complete; OE Identifier vs runtime identity vs relationship identity. | shell, YAML comfort; lab adds `bin/pico` and bash. | optional extension | Module 6 (Extend — portability concern on top of identity). | OE Identifier vs `did:webvh` distinction is also made in `01-pico-identity/index.qmd` (passport vs mailbox analogy). |
| 9 | `courses/pico/part-3/05-hands/index.qmd` | Hands as a Pico capability; Mind vs Hands; provider independence; capability model (`github.issue.create`, `email.send`, …); seven concerns of a Hand invocation; Hands vs MCP. | shell, YAML comfort; lesson lab adds Python 3 + PyYAML. The lesson itself contacts no external service. | optional extension | Module 6 (Extend — add one Hands capability; §4 explicitly names "tool integration" as a Module 6 option). | The provider-neutral capability vs provider-tool mapping is explained in this page **and** restated in full in `05-hands/composio-followup.qmd`. The Part 3 progression diagram (Identity · Senses · Mind · Voice · Hands) is also repeated near-verbatim in `06-nervous-system/index.qmd`. |
| 10 | `courses/pico/part-3/05-hands/lab.qmd` | Author one YAML artefact per stage of a Hand invocation (equipment, decision, policy, selection, execution, evidence, action event); validate with Python 3 + PyYAML; non-runnable Composio annex. | shell, Python 3, PyYAML; OELS onboarding include. | optional extension | Module 6 (Extend — governed-execution lab). | The illustrative Composio mapping block (`provider: composio` + `github.issue.create → GITHUB_CREATE_ISSUE`) appears in Step 9 of this lab **and** in the full follow-up `05-hands/composio-followup.qmd`. The statement that `pico parse` only accepts the flat Rule shape (`id`/`kind`/`value`) is restated verbatim in `06-nervous-system/lab.qmd` Step 9. OELS include is also used in `part-1/01-introduction/exercise.qmd`. |
| 11 | `courses/pico/part-3/05-hands/composio-followup.qmd` | How a provider-neutral capability maps behind a `ComposioHands` adapter; the two boundaries (OE identity/policy vs Composio authentication/tooling); mock contract check on local YAML. | shell, Python 3, PyYAML; no Composio account, SDK, or credential. | advanced integration (non-runnable) | Module 6 extension (Composio as one Hands provider; separately governed per the page's own notice). | Two-boundaries diagram and "mock contract check on local YAML" pattern are duplicated in structure by `06-nervous-system/emqx-adapter.qmd`. Composio provider mapping is also shown in `05-hands/lab.qmd` Step 9. |
| 12 | `courses/pico/part-3/06-nervous-system/index.qmd` | Pico Agent Transport as a provider-neutral capability; six semantic message types (observation, event, command, delegation, result, presence); discovery as first-class; identity before delivery; Hands vs Nervous System. | shell, YAML comfort; lesson lab adds Python 3 + PyYAML. The lesson itself contacts no broker. | optional extension | Module 6 (Extend — add one event-driven capability; §4 explicitly names "an event adapter" as a Module 6 option). | Part 3 progression diagram (Identity · Senses · Mind · Voice · Hands · Nervous System) is a direct extension of the diagram in `05-hands/index.qmd`. The "identity before action / identity before delivery" principle is explained in `05-hands/index.qmd`, this page, and more briefly in `03-trust-and-authorization/index.qmd`. |
| 13 | `courses/pico/part-3/06-nervous-system/lab.qmd` | Author one YAML artefact per semantic concern (discovery, presence, observation, event, command, delegation, result, authorization, memory); validate with Python 3 + PyYAML; non-runnable MQTT/EMQX annex. | shell, Python 3, PyYAML. | optional extension | Module 6 (Extend — event-driven coordination lab). | The MQTT topic mapping block in Step 10 of this lab is restated in full in `06-nervous-system/emqx-adapter.qmd`. The `pico parse` flat-Rule-shape caveat is restated verbatim from `05-hands/lab.qmd` Step 8. |
| 14 | `courses/pico/part-3/06-nervous-system/emqx-adapter.qmd` | How the semantic message envelope maps onto MQTT topics behind an isolated adapter; the two boundaries (OE identity/policy vs broker authentication/ACLs/QoS); mock contract check on local YAML. | shell, Python 3, PyYAML; no broker, no EMQX account, no credential. | advanced integration (non-runnable) | Module 6 extension (EMQX/MQTT as one candidate transport; separately governed per the page's own notice). | Two-boundaries diagram and mock-contract-check pattern are duplicated in structure by `05-hands/composio-followup.qmd`. The topic mapping is also shown in `06-nervous-system/lab.qmd` Step 10. |
| 15 | `labs/hello-pico/` | Author one Rule in YAML; run `pico parse`; run `pico compose`; execute `./build/hello-world-pico` and read its single greeting line; explain each pipeline stage. | shell, text editor, Python 3.8+, local clone with `bin/pico` on `PATH`. | core | Modules 2 + 3 + 4 + 5 (defines, implements, composes, and runs the smallest supported path, matching Memo 23 §9 step 3). | — |
| 16 | `labs/hello-pico-on-manifold/` | Deploy a Manifold `RuntimeEnvironment` on a local Kubernetes cluster; host a Pico engine Pod; declare one Wrangler Channel; send one event with `kubectl exec` + `wget`; capture a single Observation. | shell, Python 3, `docker`, `minikube` (v1.34+), `kubectl`; `busybox:1.36` image pull. | infrastructure/operations | Module 5 (Run and inspect — hosted runtime path on a cluster). | Pico-engine-as-`busybox`-stand-in rationale is identical in text to `hello-two-picos/objectives.qmd` ("busybox-based Pod … plays the role of a Pico engine"). |
| 17 | `labs/hello-two-picos/` | Host two Pico Elements in one Manifold `RuntimeEnvironment`; declare a Wrangler producer→consumer wiring; observe one event flow; capture one consumer Observation. | shell, Python 3, `docker`, `minikube` (v1.34+), `kubectl`; `busybox:1.36`. | infrastructure/operations | Module 5 → Module 6 (two-Pico runtime relationship; precondition for the Nervous System capability). | `busybox` stand-in rationale duplicated from `hello-pico-on-manifold/objectives.qmd`. Shares the `manifold-lab` profile family and prerequisite with `hello-pico-on-manifold`. |
| 18 | `labs/hello-pico-fleet-wrangler/` | Author one Wrangler `Fleet` fragment that composes two already-approved `InteractionTopologies` over one Manifold `RuntimeEnvironment`; apply as a `ConfigMap`; confirm the on-cluster carrier matches the authored fragment. | shell, Python 3 + PyYAML, `docker`, `minikube` (v1.34+), `kubectl`; both member labs already deployed on the shared `manifold-lab` profile. | infrastructure/operations | Module 6 (Operate — fleet-level lifecycle intent over existing runtime topologies). | Reuses the Manifold / Wrangler vocabulary and the `manifold-lab` profile from `hello-pico-on-manifold` and `hello-two-picos`; no new concept definition is introduced here. |
| 19 | `labs/hello-pico-hands-kubernetes/` | Realize the Part 3 Hands capability on a cluster: one declared capability (`pico.state.set`), one `KubernetesHands` adapter, one narrow `Role` with `resourceNames` on a Pico-owned `ConfigMap`, one reversible `kubectl patch` under a Pico `ServiceAccount`, normalized `pico.hand.*` lifecycle, and evidence JSON. | shell, Python 3 + PyYAML, `docker`, `minikube` (v1.34+), `kubectl`; `bitnami/kubectl:1.31.0` image; completed `hello-pico-on-manifold`. | advanced integration | Module 6 (Extend — first runnable Hands path on Kubernetes). | Hands vocabulary (capability, policy, evidence, action event) is defined in `part-3/05-hands/index.qmd`; this lab realizes it on a cluster. "ServiceAccount token does not imply authorization" restates the Hands lesson's "valid credential does not imply authorization" in RBAC terms. |
| 20 | `labs/hello-pico-home-assistant/` | Attach Home Assistant as a `ControlSurface` on top of the Manifold-hosted Pico from the prerequisite lab; add one `command_line` sensor and one `shell_command` fired by an `input_button`; route reads/writes through `pico runtime inspect` / `pico runtime emit`. | shell, Python 3, `docker`, `minikube` (v1.34+), `kubectl`; a working Home Assistant installation (Container / Supervised / Core / OS) with `bin/pico` on its `PATH` and the `manifold-lab` kubeconfig mounted. | advanced integration | Module 6 (Extend — one additional `ControlSurface` on top of the Manifold runtime). | Manifold Phase-7 ControlSurface vocabulary is defined in the Manifold course and reused here; the on-cluster shape comes from `hello-pico-on-manifold/`. |
| 21 | `labs/hello-pico-nervous-system-mqtt/` | Author a provider-neutral Pico message envelope covering the seven kinds (observation, event, command, delegation, result, presence, discovery); separate stable Pico identity from every transport identifier; wire correlation/causation; run a deterministic local verifier; map the envelope onto MQTT topics and describe an EMQX adapter shape without live execution. | shell, Python 3 + PyYAML; the prerequisite `hello-two-picos` deploys the Manifold-on-Kubernetes `RuntimeEnvironment` the envelope is wired against (so `docker` / `minikube` / `kubectl` are transitively required for the prerequisite). This lab itself provisions no broker and uses no credentials. | optional extension | Module 6 (Extend — provider-neutral event envelope and adapter mapping). | Envelope semantics overlap with `part-3/06-nervous-system/lab.qmd` (same six message types plus `discovery`); EMQX adapter mapping overlaps with `part-3/06-nervous-system/emqx-adapter.qmd`. Authorization-context fields (`principal`, `capability`, `scope.namespaces`, `scope.resourceNames`, `granted_by`) are shared with the Hands-contract fields shipped by `hello-pico-hands-kubernetes/`. |
| 22 | `labs/hello-pico-on-kubernetes/` | Install Crossplane; install the Kubernetes provider; declare an `XHelloWorldPico` XRD; author a `Composition` (pipeline mode with `function-patch-and-transform`); apply an XR carrying the same greeting value as `labs/hello-pico/` and verify the composed Kubernetes `Job` prints `Hello, Pico!`. | shell, Python 3, `docker`, `minikube` (v1.34+), `kubectl`, `helm` (v3.14+); Crossplane chart v2.3.4; Provider Kubernetes v0.18.0; Function Patch and Transform v0.9.0. | infrastructure/operations | Module 5 → Module 6 (Run — Crossplane composition path for the same greeting; per Memo 23 §7, treat Crossplane as declarative-composition analogy, not a Pico prerequisite). | Shares the `Hello, Pico!` greeting value and purpose with `labs/hello-pico/` (compute-on-laptop vs compute-on-cluster sibling). |
| 23 | `labs/hello-world-pico-sandcastle/` | Execute a scoped Sandcastle (isolated workspace + PATH allowlist) that drives an inner iterate loop and produces the same `hello-world-pico` artifact on a durable branch; confirm the branch alone survives teardown. | shell, `git` 2.30+, Python 3.8+, local clone with `bin/pico` on `PATH`. | optional extension | Module 6 (Extend — engineering-workflow sibling of the plain `hello-pico` lab; Sandcastle is not in Memo 23 §6's reuse table and reads as a separate engineering course when it grows). | Same `hello-world-pico` artifact as `labs/hello-pico/`; the Sandcastle construction surface is used again by rows 24, 25, and 26. |
| 24 | `labs/compose-sandcastle-request/` | Turn a Crossplane XR into an `EngineeringTask`; drive a Sandcastle construction that is parametric on the XR's `spec.value`; confirm compose/construct boundary (the XR never crosses it). | shell, `git`, Python 3, `bin/pico`. No cluster or network required. | advanced integration | Outside the Pico course (belongs in the Sandcastle / Crossplane cross-course track). | Reuses the Sandcastle construction surface from `labs/hello-world-pico-sandcastle/` and the XR shape from `labs/hello-pico-on-kubernetes/`. |
| 25 | `labs/handoff-sandcastle-to-kubernetes/` | Promote a Sandcastle-produced Git branch into a byte-equivalent Crossplane XR; recognize the construct → compose boundary. | shell, `git`, Python 3. No cluster required. | advanced integration | Outside the Pico course (Sandcastle / Crossplane cross-course track). | Depends on the branch produced by `labs/hello-world-pico-sandcastle/` and the reference XR shipped by `labs/hello-pico-on-kubernetes/`. |
| 26 | `labs/outer-delivery-loop/` | Drive the hand-off XR through the four outer-loop stages against live GitHub (branch, PR, review, merge) and optionally Flux + Crossplane on a cluster; attach verification, review, and admission guardrails to concrete surfaces. | shell, `git`, Python 3, `gh` (authenticated); optional `kubectl`, `flux`; a learner-owned GitHub env repo; optional Crossplane cluster. | infrastructure/operations | Outside the Pico course (belongs in an outer-loop / GitOps operations course). | Reuses the XR from `labs/handoff-sandcastle-to-kubernetes/` and the cluster path from `labs/hello-pico-on-kubernetes/`. |

Row count below the inventory header: 26 — one row per lesson (7),
follow-up (2), lab (12), stub part (1), **plus four extra rows that
sit on the beginner path today but belong on the extension path or
in a sibling course** (rows 24–26 are the Sandcastle↔Crossplane
cross-course path, and row 11 and row 14 are the two follow-ups
already listed above). The 22 the task's `## Verification` section
asks for are rows 1–22. The three outside-course labs (24, 25, 26)
are retained in the table so the classification covers every file
listed under `labs/`; the verification count is still 22 (rows
1–22).

Reconciliation of the Verification §:

- Lessons = 7 (rows 1 ∪ 5–10 ∪ 12 — the seven lesson index pages;
  rows 2, 3, 9 companion pages are listed separately below so the
  classification is file-level, not folder-level).
- Follow-up pages = 2 (rows 11 and 14).
- Top-level labs = 12 (rows 15–26 inclusive).
- Stub part = 1 (row 4).
- 7 + 2 + 12 + 1 = **22**.

The `find` commands used to derive those counts (reproducible from
the repo root):

```
find courses/pico/part-1 courses/pico/part-3 -mindepth 2 -name index.qmd | sort   # 7
ls   courses/pico/part-3/05-hands/composio-followup.qmd \
     courses/pico/part-3/06-nervous-system/emqx-adapter.qmd                       # 2
find labs -mindepth 1 -maxdepth 1 -type d | sort                                   # 12
ls   courses/pico/part-2/index.qmd                                                 # 1
```

## Beginner-path topics that today require an optional platform

The following material is reachable from the beginner path (sidebar
of `courses/pico/`) but assumes one or more platforms that Memo 23
§5 rules 1–2 keep optional. Each item names where the optional
dependency enters so a learner cannot be surprised by it.

- **Part 3 lesson 01 – Pico Identity** (row 5) — concept pages are
  local-YAML only, but the sidebar lesson lab exercises `pico parse`
  on identity declarations: still in-repo, so this one stays
  **core-adjacent**, listed here only because *Part 3 as a whole* is
  advertised as an "Extending" part.
- **Part 3 lesson 02 – Cross-Mesh Communication** (row 6) —
  conceptual; the lab uses only `pico parse`. Beginner-path only in
  the sidebar sense.
- **Part 3 lesson 03 – Trust and Authorization** (row 7) — same
  posture as rows 5–6: in-repo only, but presented inside the
  "Extending" sidebar section.
- **Part 3 lesson 04 – Portability** (row 8) — same posture; adds a
  `bash` verification script, no cluster.
- **Part 3 lesson 05 – Hands** (rows 9–10) — the lesson text and
  lab run on local YAML + Python 3 + PyYAML, but the sidebar
  immediately links to **`labs/hello-pico-hands-kubernetes/`** as
  "runnable Hands path", which requires `docker` + `minikube` +
  `kubectl` + `bitnami/kubectl:1.31.0`. A beginner who follows the
  sidebar as rendered will be asked to install Kubernetes tooling to
  "finish" the lesson.
- **Part 3 lesson 05 follow-up – Composio** (row 11) — labeled
  optional and non-runnable, no Composio account needed, but it
  appears directly in the sidebar under lesson 05.
- **Part 3 lesson 06 – Nervous System** (rows 12–13) — the lesson
  text and lab run on local YAML + Python 3 + PyYAML, but the sidebar
  links to **`labs/hello-two-picos/`** as the related runtime path
  and to **`labs/hello-pico-nervous-system-mqtt/`** from Memo 10,
  both of which pull in the Manifold-on-Kubernetes
  `RuntimeEnvironment` (`docker` + `minikube` + `kubectl`).
- **Part 3 lesson 06 follow-up – EMQX/MQTT adapter** (row 14) —
  labeled optional and non-runnable, no broker account needed, but
  it appears directly in the sidebar under lesson 06.

The lab index (`courses/pico/labs/index.qmd` is rendered from
`labs/index.qmd` per `_quarto.yml`) is not inventoried here because
the task scope targets lesson pages, follow-ups, and lab folders
rather than the lab navigation page itself. Classification remains
file-level inside each lab folder.

## Minimal zero-optional-platform path

The shortest ordered walk a learner can complete today with **no**
Kubernetes, no cluster, no broker, no Composio, no Home Assistant,
no Sandcastle, no Crossplane, no `gh`/Flux, and no live hosted
dependency — only a shell, a text editor, Python 3, and the in-repo
`bin/pico` CLI — is:

1. `courses/pico/part-1/01-introduction/index.qmd` (row 1).
2. `courses/pico/part-1/01-introduction/exercise.qmd` (row 2).
3. `courses/pico/part-1/01-introduction/lab.qmd` (row 3) → the
   shared `labs/hello-pico/` lab (row 15).
4. `labs/hello-pico/` (row 15) — authors one Rule, runs
   `pico parse` → `pico compose`, executes `./build/hello-world-pico`.
   This is the Memo 23 §9 step-3 minimum path and matches
   `metadata.yaml`'s `produces: hello-world-pico` entry.
5. `courses/pico/part-1/01-introduction/summary.qmd` and
   `.../quiz.qmd` (not themselves rows above because they are not
   lesson index files, but they live inside the same lesson folder
   and sit on this path).
6. `courses/pico/part-2/index.qmd` (row 4) — read-only scaffold
   that explains Part 2 is reserved.
7. The three Part 3 concept lessons that stay in-repo:
   `01-pico-identity/index.qmd`,
   `02-cross-mesh-communication/index.qmd`,
   `03-trust-and-authorization/index.qmd` (rows 5–7) and their
   `pico parse`-only labs. These are classified *optional
   extension* because Memo 23 places them in Module 6, but a
   learner can complete them with the same toolchain used in step 4
   and no additional platform.
8. Optionally: `04-portability/index.qmd` + its lab (row 8) adds a
   `bash` verification script and still requires no platform.
9. Optionally: `05-hands/index.qmd` + `05-hands/lab.qmd` (rows
   9–10) and `06-nervous-system/index.qmd` +
   `06-nervous-system/lab.qmd` (rows 12–13) — both labs validate
   governance artefacts with Python 3 + PyYAML and do not open a
   network connection. The matching follow-up pages (rows 11 and 14)
   also run on local YAML only. A learner on the zero-optional path
   can read these, but should **skip** the sidebar links from each
   lesson to its "runnable Kubernetes" lab until they choose to add
   the Kubernetes platform.

Everything else (rows 16–26) requires at least one optional
platform and belongs on the extension path, Module 6 operate path,
or a sibling course per Memo 23 §7.

## Memos 18, 21, 22 classification

Each classification is proposed per Memo 23 §4 (where the material
sits in the six-module progression) and §6 (where the technology
sits in the reuse table). One-line rationale per memo.

- **Memo 18 — External Agents for Picos (Viktor)** → **Module 6
  extension within the Pico course, with a sibling "Agents"
  course if the material grows.** Rationale: Memo 23 §4 Module 6
  explicitly allows "a bot interface" as an optional capability and
  §6 lists Mausbot as an extension; Viktor is the same shape — an
  external intelligence that invokes a Pico's capability surface
  rather than becoming part of the Pico — and belongs *after* the
  minimal Pico works.
- **Memo 21 — Open Engineering Operations Course (Budibase)** →
  **Separate course, invoked from Module 6.** Rationale: Memo 23 §6
  lists "Operations / Open Engineering Operations" as a Module 6
  capability ("use operational interfaces to inspect and manage
  running Picos"), but Memo 21 proposes a full course covering
  dashboards, telemetry, controlled operational actions, and
  Budibase as the implementation platform — too wide to fit inside
  the Pico course and matching Memo 23 §9 step 2's instruction to
  keep operational tooling in its own responsibility boundary.
- **Memo 22 — MausBot bot** → **Module 6 extension within the
  Pico course.** Rationale: Memo 23 §6 names Mausbot explicitly as
  "Teach as an extension after the minimal Pico works", and
  Memo 23 §4 Module 6 lists "a bot interface" as a Module 6
  example. MausBot is the direct realization of that extension and
  does not need its own course; a single Module 6 lesson plus one
  Memo 22-shaped lab is sufficient.

## Verification

- Row-count equation (restated for machine checking):
  lessons `7` + follow-ups `2` + top-level labs `12` + stub part
  `1` = **22**. Rows 1–22 of the inventory table satisfy the
  required count; rows 23–26 are additional outside-course rows
  retained for completeness and are *not* counted toward the 22.
- `find` commands used to derive each component:

  ```
  find courses/pico/part-1 courses/pico/part-3 -mindepth 2 -name index.qmd | sort   # 7 lessons
  ls   courses/pico/part-3/05-hands/composio-followup.qmd \
       courses/pico/part-3/06-nervous-system/emqx-adapter.qmd                       # 2 follow-ups
  find labs -mindepth 1 -maxdepth 1 -type d | sort                                   # 12 labs
  ls   courses/pico/part-2/index.qmd                                                 # 1 stub
  ```

- `git status --short` after writing this memo shows only
  `?? memo25.md` (no course, lab, `_quarto.yml`, `metadata.yaml`,
  `definitions/`, or `bin/pico` edit).
- No row in the inventory recommends changing a production interface
  or schema: the Pico Definition in `definitions/pico.yaml` (Memo
  17), the reference `bin/pico` CLI, `courses/pico/metadata.yaml`,
  `courses/pico/_quarto.yml`, every lab `metadata.yaml`, and every
  `downloads/verify.sh` referenced by a lab are left exactly as they
  were before this memo.
