# Memo 13: Inventory of course artifacts for OELS adoption

## Status

Proposed (inventory + adoption matrix only; no migration performed).

## Target Repository

Open Engineering Academy

## Purpose

Catalog every structured artifact under `courses/`, `templates/`,
`labs/`, and adjacent tooling in this repository, classify each by
semantic role, record its current validator (if any), and compare it
against the discovery, parsing, and validation contracts of the Open
Engineering Language Server (OELS).

The output is an adoption matrix and a prioritized list of migration
gaps. No course content is migrated, no CI or editor integration is
added, and no absolute filesystem path to the sibling OELS repository
is written into any executable academy configuration.

## Sources consulted

- Academy conventions in `templates/README.qmd` (metadata schema,
  Phase 1–8 constructive-realization vocabulary).
- Every `metadata.yaml` under `courses/*/` and `courses/*/labs/*/`.
- Every `_quarto.yml` under `courses/*/` plus the root `_quarto.yml`.
- Every `*.yaml` / `*.yml` / `*.json` / `*.ttl` under
  `templates/`, `labs/*/downloads/`, and course-owned artifact
  directories (`courses/make-the-lamp-nod/{picos,rules,definitions,compositions,home-assistant}/`).
- OELS packages in the sibling `open-engineering-language-server`
  repository (`open-engineering-language-server/source`) — specifically
  `packages/core`, `packages/definitions`, `packages/workspace-model`,
  `packages/language-services`, and `packages/lsp`. This memo refers
  to that repository by name only; no absolute path is embedded in
  academy configuration.

## OELS contracts referenced by this inventory

The behavior below is what OELS actually enforces today, taken from
its `discovery.ts`, `loader.ts`, `parser.ts`, and `validation.ts`.

- **Definition discovery.** Scans `<workspace-root>/definitions/`
  (top-level only) for `*.yaml` / `*.yml` / `*.json`. A missing
  directory is not an error.
- **Resource discovery.** Walks the workspace root recursively;
  skips `node_modules`, `.git`, `dist`, `build`, dotfiles, and the
  `definitions/` directory. Only `*.yaml` / `*.yml` / `*.json`
  files are considered.
- **OE resource recognition.** A document is only treated as an OE
  resource when its root is a mapping, its `apiVersion` begins with
  `open-engineering.io/`, and it declares a non-empty `kind`. Every
  other well-formed document is silently ignored (co-existence with
  unrelated YAML/JSON is by design).
- **Definition shape.** `apiVersion` must start with
  `open-engineering.io/`, `kind` must equal `Definition`,
  `metadata.name` is required, and `spec.target.{apiVersion,kind}`
  is required. `spec.schema` is optional and is projected as the
  root type used by validation.
- **Identifier shape.** `metadata.name` on an OE resource must
  match the DNS-1123 shape `[a-z0-9]([-a-z0-9]*[a-z0-9])?`; dots
  and other punctuation trigger a `MalformedIdentifier` diagnostic.
- **Schema-driven validation.** Walks a recognized resource against
  its Definition's schema and emits `UnknownProperty`,
  `MissingRequiredProperty`, `IncorrectType`, `InvalidEnumValue`,
  and reference-shape diagnostics.

## Artifact inventory by scope

Counts below are current on-disk files that match the categories.

| Scope                                      | metadata.yaml | Other structured | Notes                                                             |
| ------------------------------------------ | ------------- | ---------------- | ----------------------------------------------------------------- |
| `courses/pico/`                            | 1             | `_quarto.yml`    | Course metadata + Quarto site config.                             |
| `courses/crossplane/`                      | 1             | `_quarto.yml`    | Declares `checkable_profile: hello-pico-v1`.                      |
| `courses/sandcastle/`                      | 1             | `_quarto.yml`    | Course metadata + Quarto site config.                             |
| `courses/kubernetes/`                      | 1             | `_quarto.yml`    | Setup-only course metadata.                                       |
| `courses/manifold/`                        | 1             | `_quarto.yml`    | Course metadata + Quarto site config.                             |
| `courses/durable-picos-celld/`             | 1             | `_quarto.yml`, `.github/workflows/ci.yml` | Course metadata + site + course-local CI. |
| `courses/make-the-lamp-nod/`               | 1             | `_quarto.yml`, 6 domain YAMLs (picos/, rules/, definitions/, compositions/, home-assistant/) | See "Course-embedded artifacts" below. |
| `courses/rust-python-pyo3/`                | 1             | `_quarto.yml`, `.github/workflows/ci.yml` | Course metadata + site + course-local CI. |
| `courses/engineering-stories/`             | 0 root, 1 lab (`labs/audio-drama-lab/`) | `_quarto.yml` | Only structured file below the course root is one lab metadata.  |
| `templates/course/`                        | 1 (placeholder) | `_quarto.yml`  | Starter Course descriptor and Quarto site skeleton.               |
| `templates/lab/`                           | 1 (placeholder) | —              | Starter Lab descriptor; commented `learning`/`visualization` blocks. |
| `templates/lesson/`                        | 1 (placeholder) | —              | Starter Lesson descriptor.                                        |
| `templates/quiz/`                          | 1 (placeholder) | —              | Starter Quiz descriptor.                                          |
| `templates/examples/hello-pico-v1/`        | 0             | `package.yaml`, `reports/index.yaml`, `reports/oe-course-crossplane.yaml` | Checkable-profile exemplar + one validation report + report index. |
| `templates/constructive-realization/`      | 0             | `ontology.ttl`, `hello-pico-instances.ttl`, `quality-gate.schema.ttl` | RDF/OWL/SHACL-style reference schemas (Phase 8, opt-in). |
| `labs/` (top-level, 12 labs)               | 12            | ~30 `.yaml`/`.json` under `downloads/` + `verify.sh` in 11 labs | See "Lab artifacts" below. |


### Course-embedded artifacts (`courses/make-the-lamp-nod/`)

- `picos/pixstars-head-pitch.yaml` — declares
  `apiVersion: open-engineering.io/v1alpha1`, `kind: Pico`,
  `metadata.name: pixstars-head-pitch`. Only file in this repository
  that already matches the OELS OE-resource shape.
- `rules/nod.yaml`, `rules/nod-gesture.yaml` — top-level `rules:`
  and `nod:` mappings; no `apiVersion` / `kind`.
- `definitions/actuator-xrd.yaml`, `definitions/actuator-claim.yaml`,
  `compositions/actuator.yaml` — Crossplane resources
  (`apiextensions.crossplane.io/v1`), not OE-namespaced.
- `home-assistant/configuration.yaml` — Home Assistant control-surface
  snippet, not OE-namespaced.

### Lab artifacts (`labs/*/`)

- 12 lab `metadata.yaml` files: `hello-pico`, `hello-pico-on-kubernetes`,
  `hello-pico-on-manifold`, `hello-two-picos`, `hello-pico-home-assistant`,
  `hello-pico-fleet-wrangler`, `hello-world-pico-sandcastle`,
  `handoff-sandcastle-to-kubernetes`, `compose-sandcastle-request`,
  `outer-delivery-loop`, `hello-pico-hands-kubernetes`,
  `hello-pico-nervous-system-mqtt`. Same schema shape as course
  metadata (documented in `templates/README.qmd` Phases 1–4).
- `labs/*/downloads/*.yaml` — Kubernetes manifests
  (`v1`, `apps/v1`, `rbac.authorization.k8s.io/v1`, `batch/v1`,
  `apiextensions.crossplane.io/v2`, `pkg.crossplane.io/v1`,
  `pkg.crossplane.io/v1beta1`) plus lab-specific data files
  (`topology.yaml`, `mqtt-topics.yaml`, `emqx-adapter.yaml`,
  `fleet.yaml`, `fleet-configmap.yaml`, `blueprint.yaml`,
  `expected-task.yaml`, `expected-xr.yaml`, `picos.yaml`,
  `discovery.yaml`, `configuration.yaml`).
- `labs/*/downloads/*.json` — sample payloads (`event.json`,
  `messages/{01-presence,02-discovery,03-observation,04-event,
  05-command,06-delegation,07-result}.json`) plus one JSON Schema
  (`labs/hello-pico-nervous-system-mqtt/downloads/envelope.schema.json`).
- `labs/*/downloads/verify.sh` — 11 shell verifiers (all labs except
  `hello-pico`), executed via the `walkthrough.qmd` / `solution.qmd`
  step recorded in each lab's `validated_by`.

## Semantic classification of every structured file

| Class                                    | Example files                                                                                          | Count | OELS recognizes as… |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----- | ------------------- |
| Academy course/lab/lesson/quiz metadata  | `courses/*/metadata.yaml`, `courses/engineering-stories/labs/audio-drama-lab/metadata.yaml`, `labs/*/metadata.yaml`, `templates/{course,lab,lesson,quiz}/metadata.yaml` | 22    | Ignored (no `apiVersion`).           |
| Repository-organization metadata         | `metadata.yaml` (repo root)                                                                            | 1     | Ignored (no `apiVersion`; governed by external `metadata-controller`). |
| OE-namespaced resource (Pico kind)       | `courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`                                             | 1     | Recognized OE resource (no matching Definition on disk today). |
| Academy rule/topology data (no header)   | `courses/make-the-lamp-nod/rules/*.yaml`, `labs/*/downloads/{topology,mqtt-topics,emqx-adapter,fleet,fleet-configmap,picos,discovery,expected-task,expected-xr,blueprint}.yaml` | ~14  | Ignored (no `apiVersion`).           |
| Crossplane resource                      | `courses/make-the-lamp-nod/{definitions,compositions}/*.yaml`, `labs/hello-pico-on-kubernetes/downloads/{01-provider,02-rbac,03-xrd,04-composition,05-xr}.yaml`, `labs/handoff-sandcastle-to-kubernetes/downloads/expected-xr.yaml` | ~12  | Ignored (non-OE `apiVersion`).       |
| Kubernetes / RBAC / Job / ConfigMap      | `labs/hello-pico-hands-kubernetes/downloads/*.yaml`, `labs/hello-two-picos/downloads/*.yaml`, `labs/hello-pico-on-manifold/downloads/01-namespace.yaml`, `labs/hello-pico-nervous-system-mqtt/downloads/*.yaml` | ~15  | Ignored (non-OE `apiVersion`).       |
| Home Assistant / third-party config      | `courses/make-the-lamp-nod/home-assistant/configuration.yaml`, `labs/hello-pico-home-assistant/downloads/configuration.yaml` | 2   | Ignored (no `apiVersion`).            |
| Sample JSON payload                      | `labs/*/downloads/event.json`, `labs/hello-pico-nervous-system-mqtt/downloads/messages/*.json`         | ~9    | Ignored (no `apiVersion`).           |
| JSON Schema                              | `labs/hello-pico-nervous-system-mqtt/downloads/envelope.schema.json`                                   | 1     | Ignored (no `apiVersion` at the OE root; used by lab `verify.sh`). |
| Checkable-profile example + report(s)    | `templates/examples/hello-pico-v1/package.yaml`, `templates/examples/hello-pico-v1/reports/index.yaml`, `templates/examples/hello-pico-v1/reports/oe-course-crossplane.yaml` | 3   | Ignored (documentation-shape, no `apiVersion`). |
| Constructive-realization ontology (TTL)  | `templates/constructive-realization/{ontology,hello-pico-instances,quality-gate.schema}.ttl`           | 3     | Out of scope (`.ttl` not in OELS default extension set). |
| Site / build / CI config                 | Root `_quarto.yml`, `courses/*/_quarto.yml`, `courses/{durable-picos-celld,rust-python-pyo3}/.github/workflows/ci.yml`, root `.github/workflows/build-and-publish.yml` | 12  | Ignored (non-OE data).               |

## Current validators

- `work/verify-links.py` — relative-link resolver for a hard-coded
  `TOUCHED` list; independent of any semantic contract.
- Per-lab `labs/*/downloads/verify.sh` (11 files) — shape and
  runtime checks recorded in each lab's `validated_by`; independent
  of any schema.
- `courses/{durable-picos-celld,rust-python-pyo3}/.github/workflows/ci.yml`
  and root `.github/workflows/build-and-publish.yml` — build/render
  gates, not schema validators.
- `templates/README.qmd` describes a Phase 5 "profile-check" workflow
  and a Phase 6 report-index shape for `checkable_profile: hello-pico-v1`;
  one static profile-check report exists at
  `templates/examples/hello-pico-v1/reports/oe-course-crossplane.yaml`.
  No tool in this repository executes the profile check.

## OELS compatibility matrix

| Artifact class                          | Adapter needed?              | Fields to reshape                                          | Definition needed on `<root>/definitions/`? |
| --------------------------------------- | ---------------------------- | ---------------------------------------------------------- | -------------------------------------------- |
| Course/lab/lesson/quiz `metadata.yaml`  | Yes                          | Wrap in `apiVersion`+`kind` header; supply `metadata.name` that matches DNS-1123 (current `id` values use dots). | Yes — one Definition per academy artifact kind (Course, Lab, Lesson, Quiz). |
| Root `metadata.yaml`                    | Out of scope — externally governed | —                                                          | No.                                           |
| `Pico` resource (`pixstars-head-pitch`) | No shape change              | Already OE-shaped and DNS-1123 clean                       | Yes — add a `Pico` Definition covering `spec.{type,capabilities,implementation,...}`. |
| Rule / topology / message-envelope YAML | Yes                          | Add `apiVersion`+`kind` header; give `metadata.name`       | Yes — Definitions for `Rule`, `InteractionTopology`, `TransportMap`, etc. |
| Checkable-profile package + reports     | Yes if adopted               | Wrap `package.yaml` and report shapes as OE resources      | Yes — Definitions for the profile package and validation report. |
| Crossplane, Kubernetes, HA config       | No — deliberately non-OE     | None                                                       | No — remain silently ignored, per parser design. |
| JSON payload samples                    | No                           | None                                                       | No.                                           |
| Constructive-realization TTL            | Out of scope for OELS today  | None                                                       | No — `.ttl` is outside OELS extension set.    |
| Site / build / CI config                | No                           | None                                                       | No.                                           |

## Migration gaps

1. No `<repository-root>/definitions/` directory exists, so
   `discoverDefinitions()` returns an empty list and no schema-driven
   validation is possible today.
2. Academy `metadata.yaml` uses a flat schema with no `apiVersion`,
   `kind`, or nested `spec`, so nothing in `courses/`, `labs/`, or
   `templates/{course,lab,lesson,quiz}/` is recognized as an OE
   resource by OELS.
3. Academy `id` values (`oe.course.pico`, `oe.lab.hello-pico`, …)
   use dots and would fail OELS's DNS-1123 `metadata.name` check
   verbatim. The academy `id` and OELS `metadata.name` need to be
   kept as two distinct fields, or a deterministic mapping (e.g.
   `id` → `metadata.name` by replacing `.` with `-`) is required.
4. The one already-OE-shaped resource
   (`courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`) has
   no matching `Pico` Definition, so OELS would report an
   "unknown Definition" diagnostic for it.
5. Rule, topology, message-envelope, and profile-package YAMLs
   describe OE concepts but ship without an `apiVersion`/`kind`
   header, so they are invisible to OELS.
6. `templates/constructive-realization/*.ttl` describes the
   constructive-realization vocabulary as OWL/SHACL. OELS's parser
   only handles YAML and JSON, so TTL adoption stays out of scope
   until a separate loader exists.
7. The `hello-pico-v1` "profile check" (Phase 5) and its report
   index (Phase 6) are documentation contracts today; no code in
   this repository runs the check, and OELS has no equivalent
   built-in.

## Recommended priority order (for a later, separate task)

1. **Add `definitions/` at the repository root.** Start with a
   `Pico` Definition covering the shape already used by
   `courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`.
   This is the smallest change that turns an existing academy
   artifact into an OELS-validated resource without editing course
   content.
2. **Author Course / Lab / Lesson / Quiz Definitions** that
   describe the current `metadata.yaml` field set, and adopt a
   two-field convention: keep the human-facing `id` unchanged and
   introduce a DNS-1123 `metadata.name` (either sibling field or
   projection). No existing `id` values change; nothing is
   renamed on disk yet.
3. **Add Definitions for Rule, InteractionTopology, TransportMap,
   and the profile-package/report shapes.** Only then propose
   adding `apiVersion`/`kind` headers to the corresponding YAMLs,
   one artifact class at a time, behind a review.
4. **Wire OELS into editors and CI** — explicitly out of scope for
   this inventory task. Any executable configuration MUST reference
   the sibling repository by name (published npm package or git
   remote), never by absolute local path.
5. **Consider a `.ttl` loader** only if the Phase 8 TTL vocabulary
   is promoted from opt-in reference to enforced contract; the
   current OELS extension set does not cover Turtle.

## Blockers surfaced by this inventory

- OELS is present in the sibling repository only; no npm-published
  version, git tag, or workspace-local pin exists in the academy.
  Any future OELS integration will need to pick a distribution
  mechanism before Priority 4 can start.
- The academy `id` scheme (`oe.<kind>.<slug>`) predates OELS's
  DNS-1123 identifier rule. Priority 2 above assumes that a
  parallel `metadata.name` is acceptable; if instead the academy
  decides to normalize `id` to DNS-1123, every cross-reference
  under `prerequisites`, `references_labs`, `referenced_by`,
  `realizes`, and `depends_on` would need to be rewritten in the
  same change.

## Out of scope for this memo

- Editing any course, lesson, lab, or exercise content.
- Adding `apiVersion` / `kind` headers to any existing file.
- Creating `<root>/definitions/` or any Definition file.
- Wiring OELS into `_quarto.yml`, GitHub Actions, or editor
  configuration.
- Hard-coding the sibling OELS repository's absolute local path
  into anything under `bin/`, `_quarto.yml`, `.github/`,
  `courses/`, `labs/`, or `templates/`.
