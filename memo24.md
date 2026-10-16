# Memo 24: Capsule-first verification record

## Status

Verification record. Produces only `memo24.md` at the repo root; no
course, lab, Definition, template, `bin/pico`, CI workflow, or
publishing-pipeline file is changed. Companion to Memo 23 §9 steps 2–3:
inspects the canonical Open Engineering model the capsule-first course
refactor would depend on and records the facts that Memo 25 (inventory
and reclassification) and Memo 26 (capsule contract proposal) must
cite rather than assume.

## Target repositories (inspected, not modified)

All read-only via `gh api` on 2026-10-16 from the authenticated session;
no `git push`, no fork, no issue, no PR anywhere.

- `open-engineering-capsules/source` (private; definitions org for
  capsules, symbol `Cl`)
- `open-engineering-capsule/source` (private; implementation org,
  symbol `Cp`)
- `open-engineering-picos/source` (private; symbol `Pc`)
- `open-engineering-conventions/pico-conventions` (private; one repo
  inside the 31-repo conventions org, which also contains 28 other
  `*-conventions` repos plus `.github` and `source`)
- This repository (Open Engineering Academy source): `definitions/`,
  `bin/pico`, `labs/hello-pico/`, `courses/pico/`.

## Purpose

Memo 23 proposes refactoring the Pico course around a capsule
contract (§3, §9, §11), teaches Modules 2–4 on top of that contract
(§4), and explicitly forbids inventing a course-specific capsule
format (§3.2, §9 step 2). It therefore has one upstream prerequisite:
the canonical capsule contract must exist, or be published, before
capsule-contract-bearing course content can be authored.

This memo records what Memo 23 §9 step 2 ("Verify the canonical
model") actually finds today, and what §9 step 3 ("Establish the
minimum path") actually points at. Everything below was re-inspected
during this task; nothing is quoted from memory.

## 1. Repositories inspected

Each row records the exact `gh api` endpoint read, the latest commit
observed, the repository's `pushed_at` timestamp, and the files
present at the inspected revision. All four private repositories are
visible via authenticated `gh api` but return HTTP 404 to anonymous
clients, so only the public **org** URLs appear in the References
section (the References-link URL check passes on 200s only).

| Repo | `gh api` endpoint read | Latest commit (date) | `pushed_at` | Contents at HEAD |
|---|---|---|---|---|
| `open-engineering-capsules/source` | `repos/open-engineering-capsules/source` + `/contents/` + `/commits?per_page=5` | `a13854a1` — `chore: sync source/metadata.yaml (#2)` (2026-08-24T14:20:32Z) | 2026-08-24T14:20:35Z | `README.md` (16 B: literally `# source\nSource`), `metadata.yaml` (794 B, controller-generated). Three commits total; prior two are the first `metadata.yaml` sync (2026-08-24T08:07:50Z) and `Initial commit` (2026-08-06T06:38:00Z). Repo size: 3 KB. |
| `open-engineering-capsule/source` | `repos/open-engineering-capsule/source` + `/contents/` + `/commits?per_page=5` | `0777cbcf` — `chore: sync source/metadata.yaml (#2)` (2026-08-24T14:20:33Z) | 2026-08-24T14:20:35Z | `README.md` (16 B, same string), `metadata.yaml` (711 B, controller-generated). Three commits total; identical history shape to `open-engineering-capsules/source`. Repo size: 3 KB. |
| `open-engineering-picos/source` | `repos/open-engineering-picos/source` + `/contents/` | `cb346b4a` — `Update title format in memo7.md` (2026-10-07T22:30:47Z) | 2026-10-07T22:30:47Z | `README.md` (16 B), `metadata.yaml` (672 B), `memo1.md` (6.3 KB), `memo2.md` (4.0 KB), `memo3.md` (20 KB), `memo4.md` (22.6 KB), `memo5.md` (25.5 KB), `memo6.md` (16.6 KB), `memo7.md` (11.4 KB). Repo size: 98 KB. |
| `open-engineering-conventions/pico-conventions` | `repos/open-engineering-conventions/pico-conventions` + `/contents/` | `554915f5` — `Create memo3.md` (2026-08-05T07:17:44Z) | 2026-08-05T07:17:44Z | `README.md` (36 B: `# pico-conventions\nPico Conventions`), `memo1.md` (3.3 KB), `memo2.md` (4.1 KB), `memo3.md` (4.0 KB). **No `metadata.yaml`** (`/contents/metadata.yaml` → 404). No `specification/`, `schemas/`, `examples/`, or `diagrams/` directory. Repo size: 10 KB. |
| `open-engineering-conventions` (whole org) | `orgs/open-engineering-conventions/repos?per_page=100&type=all` | n/a | n/a | 31 repositories: `.github` (public) + 30 private, of which 29 are `*-conventions` (`agentic-software-engineering`, `api`, `architecture`, `course`, `curriculum`, `documentation`, `event`, `exercise`, `github`, `lab`, `lesson`, `logging`, `markdown`, `metadata`, `model`, `mqtt`, `naming`, `networking`, `pico`, `qr-code`, `quiz`, `repository`, `rule`, `security`, `story`, `telemetry`, `texture`, `versioning`, `visual-identity`) and one is `source`. **No `capsule-conventions` repo exists.** GitHub code search `capsule org:open-engineering-conventions` returns `{"total_count":0}`; the same search `capsule org:open-engineering-picos` also returns `{"total_count":0}`. |
| This repository (Academy source) | local `view`/`cat` from the workspace tree | commit on current branch `memo10-publish` | n/a | `definitions/pico.yaml` (92 lines), `bin/pico` (369 lines), `courses/pico/glossary.qmd` (295 lines), `courses/pico/constructive-realization.qmd` (213 lines), `labs/hello-pico/{index,objectives,walkthrough,solution,metadata}` (60 + 78 + 93 + 69 lines + metadata). 12 lab directories under `labs/`. Workspace-wide `grep -rn capsule` across tracked `*.yaml`, `*.yml`, `*.qmd`, `*.md`, `*.py` (excluding `docs/` and `archive/`) returns only `memo23.md`; one hit inside `archive/memo1.md` uses `capsules/` as a hypothetical course folder name. |

## 2. What the canonical model defines today

### 2.1 `open-engineering-capsules` and `open-engineering-capsule` orgs — no content

Both `*/source` repos contain exactly two files each. Their
`metadata.yaml` is a generated placeholder with `lifecycle: proposed`:

- `open-engineering-capsules/source/metadata.yaml` declares
  `name: Open Engineering Capsules`, `symbol: Cl`,
  `description: Open Engineering Capsules define the architecture,
  interfaces, lifecycle, conventions, and composition model for
  reusable engineering capabilities within the Open Engineering
  ecosystem.`, `lifecycle: proposed`,
  `relationships.governed-by: [Ec]`,
  `semantic.id: io.open-engineering.capsules/organization`.
- `open-engineering-capsule/source/metadata.yaml` declares
  `name: Open Engineering Capsule`, `symbol: Cp`,
  `description: Open Engineering Capsule is the implementation
  organization for the Open Engineering Capsule architecture.`,
  `lifecycle: proposed`.

Neither repo contains a schema, a convention file, a worked example,
a diagram, a Composer definition, a lifecycle doc, or a dependency
model. The companion `.github` repo in each org exists (`public_repos: 1`
on each org besides `source`) but contains no capsule content either.
In short: both the definitions-org and the implementation-org for
capsules exist as named GitHub orgs, but there is **no capsule
contract and no capsule implementation to point a course at**.

### 2.2 `open-engineering-conventions/pico-conventions` — three memos, no committed schema

The repo contains three memos only. Observed verbatim:

- **memo1 (`memo1.md`, 3.3 KB).** Proposes a repository layout
  (`specification/`, `schemas/`, `examples/`, `diagrams/`) and a
  "Version 0.1 Specification" minimal Pico:
  ```yaml
  kind: Pico
  id: pico:ravi
  state: {}
  handlers: {}
  subscriptions: []
  channels: []
  metadata: {}
  ```
  It names the required concepts (Identity, State, Inbox, Handlers,
  Subscriptions, Channels), a minimal event shape, a deterministic
  event-processing contract, and a four-stage roadmap (Minimal →
  Networked → Persistent → Distributed Pico). No `pico.schema.json`
  is committed. The word "capsule" does not appear.
- **memo2 (`memo2.md`, 4.1 KB).** Proposes a wider directory layout
  (`conventions/`, `schemas/`, `examples/`, `assets/`), ten core
  conventions (Identity, Lifecycle, Events, Channels, State,
  Capabilities, Composition, Security, Hosting, Interoperability),
  and a worked `lamp-pico` example using
  `apiVersion: pico.open-engineering.io/v1alpha1`, `kind: Pico`,
  `metadata.name`, `spec.{runtime, capabilities}`, `subscriptions`,
  `state`. No schema is committed. The word "capsule" does not
  appear.
- **memo3 (`memo3.md`, 4.0 KB).** Discusses the separation between
  conventions, rules, rulesets, and the Pico runtime. Proposes
  distinct `open-engineering-rules` and `open-engineering-rule(s)`
  roles. The word "capsule" does not appear.

The repository has no `metadata.yaml` entry in the conventions
metadata graph (`/contents/metadata.yaml` → 404), so it is not
currently published through the Ecosystem metadata controller the
way `*/source` repos are.

### 2.3 `open-engineering-picos/source` — memo-only

`memo1`–`memo7` cover rule-loading (`memo1`), related architecture
(`memo2`–`memo6`), and external agent integration (`memo7`). Memo 7,
"Cue as an External Agent and Operator for Picos", lists the Pico
anatomy verbatim:

> Python / Face · Rust+PyO3 / Muscles · Celld / Memory · Composio /
> Hands · EMQX / Nervous System · OE Rules / Rules · A2A / Discovery
> · Open Engineering Operations / Operations.

The word "capsule" appears **nowhere** across `memo1`–`memo7` (code
search `capsule org:open-engineering-picos` → 0 hits). There is no
Composer specification, no composition-format definition, and no
capsule schema in the repo.

### 2.4 This repository (Academy source)

- **`definitions/pico.yaml`** (`apiVersion: open-engineering.io/v1alpha1`,
  `kind: Definition`, `metadata.name: pico`,
  `spec.target.kind: Pico`). The target Pico schema requires
  `apiVersion`, `kind`, `metadata.name`, and `spec.{type,
  capabilities, implementation, state, events}`. `metadata` has no
  academy `id` sibling; `spec.additionalProperties: true`. The
  Definition's docstring makes its scope explicit: it is fitted to
  the on-disk native Pico resource
  `courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml` and
  closes memo13 gap #4 (memo17 context). It is **not** a capsule
  contract: it has no `inputs`/`outputs`/`contract` fields, no
  dependency declaration, no lifecycle enum, and no composition
  rules.
- **`bin/pico`** (reference CLI, Python 3 stdlib only, 369 lines).
  Subcommands: `pico parse <rule.yaml> --out <parsed.json>`,
  `pico compose <parsed.json> --out <artifact>`,
  `pico runtime {inspect,emit,observe}` (shells to `kubectl` against
  Manifold-deployed topologies for two known labs:
  `hello-pico-on-manifold`, `hello-two-picos`). The `compose`
  implementation is literal: it reads a parsed Rule, requires
  `kind: greeting`, and writes an executable shell script that
  `printf`s the Rule's `value`. In the Academy's vocabulary (see
  `courses/pico/glossary.qmd` lines 8–9) the **Composer** is "a
  component that takes parsed Rules and produces a Pico output
  artifact" — it is a Rules→artifact code generator, not a
  capability composer.
- **Course vocabulary.** `courses/pico/glossary.qmd` defines
  Composer, Parser, Rule, Pico, Element, Definition, Realization,
  Constraint, Validation (the five-term "constructive realization"
  vocabulary), plus Hands/Capability/HandsProvider/ActionRequest/
  Policy/Evidence and the Nervous System vocabulary (Pico Agent
  Transport, Message Envelope, Observation/Event/Command/Delegation,
  etc.). It does **not** define "capsule". `constructive-realization.qmd`
  teaches `Rules → Parser → Composer → Pico` as the Realization
  pipeline and introduces Hands and the Nervous System as governed
  extensions of that same pipeline. "Capsule" does not appear.
- **Wrangler.** Named only in `bin/pico` runtime helpers and in
  `labs/hello-pico-fleet-wrangler/index.qmd`, which describes
  Wrangler as "the declarative topology/fleet authoring layer
  that sits above the runtime — it does not host Picos, it does
  not own the ontology, and it does not replace Kubernetes,
  Manifold, the Python CLI, or the Home Assistant control surface".
  Wrangler composes existing Manifold `InteractionTopology`
  resources into a `Fleet` fragment. It is not a Pico runtime and
  it is not a capability-composition surface.

## 3. Smallest supported path today — `labs/hello-pico`

End-to-end dependency-free lab, 30–45 minutes, Python 3 stdlib only
(no Kubernetes, no broker, no database, no AI library, no bot
platform). Observed on disk:

Prerequisites (`labs/hello-pico/objectives.qmd`):

- bash or zsh
- a text editor
- Python 3.8+ on `PATH`
- a local clone of this repository, which ships `bin/pico`
- one-time setup: `export PATH="$PWD/bin:$PATH"` so `command -v pico`
  resolves to `./bin/pico` and not `/usr/bin/pico` (Alpine/nano).

Commands (`labs/hello-pico/walkthrough.qmd` and `solution.qmd`):

```bash
mkdir -p work/hello-pico && cd work/hello-pico

cat > rules/hello.yaml <<'YAML'
id: rule.hello
kind: greeting
value: "Hello, Pico!"
YAML

pico parse   rules/hello.yaml --out build/parsed.json
pico compose build/parsed.json --out build/hello-world-pico
./build/hello-world-pico
# → Hello, Pico!
```

Produced artifact: `build/hello-world-pico` — matches the `produces:
- hello-world-pico` entry in `labs/hello-pico/metadata.yaml` and in
the referenced pico-course metadata. `rules/hello.yaml` must contain
exactly the three keys `id`, `kind`, `value` (`bin/pico` lines 56
and 82–86 reject any other key).

`labs/hello-pico/metadata.yaml` declares the lab as
`constructive_role: realization`, `realizes: [oe.course.pico]`,
`realization_pattern: rules-parser-composer-pipeline`,
`validated_by: [walkthrough Step 3/4/5, solution verification]`,
`lifecycle_state: operational`.

## 4. Gaps between Memo 23 assumptions and reality

Each row is grounded in §1–§3 above, not in interpretation.

| Memo 23 assumption | Observed reality (file / endpoint) | Consequence |
|---|---|---|
| A canonical capsule contract exists (Modules 2–4 use "the canonical capsule definition format"; §3.2 forbids inventing a course-specific one) | `open-engineering-capsules/source` = `README.md` + generated placeholder `metadata.yaml`; no schema, no conventions. `open-engineering-conventions/pico-conventions` has three memos (proposals) and no committed `pico.schema.json` or capsule schema. GitHub code search `capsule org:open-engineering-conventions` → 0. | No upstream capsule contract to teach against. Modules 2–4 cannot be authored without one. |
| Capsule implementations exist | `open-engineering-capsule/source` = `README.md` + generated placeholder `metadata.yaml`; no implementation. | No reference implementation for Module 3's "implement one capsule" exercise. |
| "Composer" composes capability capsules (§3, §4.4, §4.5) | Academy Composer (`bin/pico compose`, glossary) is defined as a **Rules → artifact** code generator that currently handles only `kind: greeting`. There is no Composer that resolves capabilities, binds interfaces, or checks compatibility across capsule contracts. | Module 4's "Dependency resolution, interface binding, version compatibility, and validation" cannot be demonstrated using the existing Composer. |
| One canonical Pico shape | Two incompatible shapes exist. `definitions/pico.yaml` (local) requires `spec.{type, capabilities, implementation, state, events}` on OE-shaped Pico YAML. `open-engineering-conventions/pico-conventions/memo1.md` proposes `kind: Pico, id, state, handlers, subscriptions, channels, metadata` (no `apiVersion`, no `spec` block, no `type`, no `implementation`). `memo2.md` proposes a third variant (`spec.{runtime, capabilities}`, top-level `subscriptions`/`state`). Neither upstream shape is committed as a schema. | Memo 23's "canonical" is ambiguous; the Academy's Pico Definition does not match either proposed shape in `pico-conventions`. |
| "Wrangler" is a Pico runtime (§4.5) | `labs/hello-pico-fleet-wrangler/index.qmd` scopes Wrangler as declarative topology/fleet authoring over Manifold `InteractionTopology`s; it explicitly "does not host Picos" and "does not replace Kubernetes, Manifold, the Python CLI". | Module 5's "the intended Open Engineering runtime and Wrangler fit into the current architecture" needs restating; Wrangler is authoring, not runtime. |
| Course material already uses "capsule" vocabulary | Repository-wide `grep -rn capsule` across tracked `*.yaml`, `*.yml`, `*.qmd`, `*.md`, `*.py` (excluding `docs/` and `archive/`) returns only `memo23.md`. In `archive/memo1.md` `capsules/` appears once as a hypothetical course folder name. The pico course glossary does not define "capsule". | No existing lesson, lab, Definition, or template already carries the Memo 23 vocabulary; the refactor starts from zero on that front. |

## 5. Decision requested

Before authoring any Memo 23 Module 2–6 content and before the first
end-to-end capsule lab:

1. Publish a minimal capsule contract (schema + lifecycle + one
   worked example) in `open-engineering-capsules/source`,
   reconciling the two differing Pico shapes in
   `open-engineering-conventions/pico-conventions/memo1.md` and the
   local `definitions/pico.yaml` so that one canonical shape is
   named upstream.
2. Treat Memo 25 (inventory and reclassification of the current
   `courses/pico` material) and Memo 26 (the contract proposal
   itself) as the only Academy-side work that can proceed without
   that contract. Both are already queued as separate task notes
   under this spec's "Wave 1" / "Wave 2".
3. Confirm whether `bin/pico compose` should remain a Rules→artifact
   generator and a *second* composer concept be introduced for
   capability composition, or whether the current `compose` command
   is to be reinterpreted/extended. Either direction belongs in
   `open-engineering-capsules/source`, not in a course-specific
   schema (per Memo 23 §3.2).

This memo does not take that decision; it records the facts the
decision needs.

## References

Only URLs that returned HTTP 200 to anonymous `curl` on 2026-10-16
are listed here. The private repositories inspected above are
accessible to the author via authenticated `gh api` only, so they
appear in §1 as `gh api` endpoints with the commit SHA and
`pushed_at` observed, not as clickable URLs here.

- Open Engineering Capsules organization: https://github.com/open-engineering-capsules
- Open Engineering Capsule organization: https://github.com/open-engineering-capsule
- Open Engineering Picos organization: https://github.com/open-engineering-picos
- Open Engineering Conventions organization: https://github.com/open-engineering-conventions
- Local files cited: `definitions/pico.yaml`,
  `bin/pico`,
  `labs/hello-pico/index.qmd`,
  `labs/hello-pico/objectives.qmd`,
  `labs/hello-pico/walkthrough.qmd`,
  `labs/hello-pico/solution.qmd`,
  `labs/hello-pico/metadata.yaml`,
  `labs/hello-pico-fleet-wrangler/index.qmd`,
  `courses/pico/glossary.qmd`,
  `courses/pico/constructive-realization.qmd`,
  `memo23.md`.
