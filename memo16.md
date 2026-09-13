# Memo 16: Final course-artifact migration and verification against OELS

## Status

Implemented as an additive extension of the memo14 adapter and the
memo15/CI gate committed in `scripts/oels_ci_validate.py`. No academy
content is edited on disk; no absolute sibling path, credential, hosted
service, or new runtime dependency is introduced; existing runtime
validators, Quarto publishing, and CI diagnostics are preserved and, where
extended, only strengthened.

## Purpose

Close the "silently skipped" gap surfaced by memo13's inventory and the
memo14/memo15/CI-gate waves for every structured artifact in scope:
`courses/` (nine directories), `labs/` (top-level), `exercises/`,
`templates/{course,lab,lesson,quiz}/`, and the previously-unscanned
`templates/examples/`. Every in-scope structured file is now classified
into one of the five buckets the CI validator already emits — adapter-
validated, OELS-recognized native, intentionally non-OE,
excluded/generated, or tracked compatibility gap — with no silent skips.

## Changes (files touched)

Tracked (five files, additive; no delete, no rename):

- `work/oels_metadata_adapter.py` — extend `classify_metadata_path` to
  return `Exercise` for `metadata.yaml` under `exercises/`; add
  `EXERCISE_METADATA_FIELDS_RESERVED = {"id"}` to the reserved-fields
  map. The dot-to-dash `metadata.name` projection and `metadata.id`
  preservation are unchanged; every other top-level field flows into
  `spec` unchanged (memo14 contract).
- `definitions/exercise.yaml` — new. `apiVersion:
  open-engineering.io/v1alpha1`, `kind: Definition`,
  `spec.target.kind: Exercise`. Schema declares only the fields the
  current on-disk exercise uses (`title`, `level`, `duration`,
  `prerequisites`, `teaches`, `produces`, `referenced_by`).
  `spec.additionalProperties: true` matches the Course/Lab pattern so
  future field growth does not immediately trip `UnknownProperty`.
- `definitions/README.md` — add the `exercise.yaml` row and update the
  scanned-file count from 25 to 26.
- `scripts/oels_ci_validate.py` — add `shared:exercises` and
  `shared:templates/examples` scope passes; recognise
  `metadata.yaml` under `exercises/` as an adapter candidate. Docstring
  updated to enumerate the new passes. Failure modes, category
  accounting, `--fail-on-gap`, and the malformed-fixture assertion are
  unchanged.
- `work/oels-contract/fixtures/README.md` — add the `valid-exercise.yaml`
  row.
- `work/oels-contract/fixtures/valid-exercise.yaml` — new fixture that
  mirrors the adapter's projection of an exercise `metadata.yaml`.
  Deterministically produces zero diagnostics against
  `definitions/exercise.yaml`.
- `.gitignore` — one additional unignore entry for the new fixture
  (`!/work/oels-contract/fixtures/valid-exercise.yaml`). All other
  `/work/*` ignore rules are unchanged.

Locally exercised only (untracked developer verifier; memo14 pattern):

- `work/verify_oels_metadata.py` — add `exercises/` to `METADATA_ROOTS`
  and `valid-exercise` to the fixture list. Not part of the CI gate
  and not committed (memo14 ships the CI-required subset only).

No file was edited under `courses/**`, `labs/**`, `exercises/**` metadata
content, `templates/**` metadata content, `.github/**`, `_quarto.yml`,
per-course `_quarto.yml`, root `metadata.yaml`, `bin/`, `docs/`, or any
generated output. No `open-engineering.io/` YAML header was added to any
authored file. No absolute sibling path or credential appears in any
committed file.

## Final classification matrix (all in-scope structured artifacts)

Bucket totals from `scripts/oels_ci_validate.py` (local run, developer
workspace):

```
totals: adapter=26 native-oe=0 non-oe=60 excluded=172 gap=1
oels-ci-validate: OK
```

Per-scope breakdown (14 scope reports; every file counted exactly once):

| Scope                       | adapter | native-oe | non-oe | excluded | gap |
| --------------------------- | ------- | --------- | ------ | -------- | --- |
| course:crossplane           | 1       | 0         | 1      | 14       | 0   |
| course:durable-picos-celld  | 1       | 0         | 1      | 1        | 0   |
| course:engineering-stories  | 1       | 0         | 1      | 49       | 0   |
| course:kubernetes           | 1       | 0         | 1      | 3        | 0   |
| course:make-the-lamp-nod    | 1       | 0         | 7      | 24       | 1   |
| course:manifold             | 1       | 0         | 1      | 0        | 0   |
| course:pico                 | 1       | 0         | 1      | 48       | 0   |
| course:rust-python-pyo3     | 1       | 0         | 1      | 1        | 0   |
| course:sandcastle           | 1       | 0         | 1      | 32       | 0   |
| shared:labs                 | 12      | 0         | 41     | 0        | 0   |
| shared:exercises            | 1       | 0         | 0      | 0        | 0   |
| shared:templates/course     | 1       | 0         | 1      | 0        | 0   |
| shared:templates/lab        | 1       | 0         | 0      | 0        | 0   |
| shared:templates/lesson     | 1       | 0         | 0      | 0        | 0   |
| shared:templates/quiz       | 1       | 0         | 0      | 0        | 0   |
| shared:templates/examples   | 0       | 0         | 3      | 0        | 0   |

Notes:

- `adapter=26` = 8 course-root `metadata.yaml` + 1 nested
  `courses/engineering-stories/labs/audio-drama-lab/metadata.yaml` +
  12 top-level `labs/*/metadata.yaml` + 1 `exercises/pico-first-rule/`
  metadata + 4 template placeholders. The +1 vs the memo14 count of 25
  is the newly-swept exercise metadata.
- `non-oe=60` classes match memo13: Crossplane, Kubernetes/RBAC/Job/CM,
  Home Assistant configuration, rule/topology data, JSON payloads,
  JSON Schema, checkable-profile package + reports (3 files under
  `templates/examples/hello-pico-v1/`), and per-course `_quarto.yml`.
  All silently ignored by OELS by design.
- `excluded=172` is the developer workspace count and includes
  `_freeze/`, `_site/`, `.quarto/`, `.github/`, `node_modules/`, and
  dotfile-scoped files pruned by OELS-equivalent discovery. On a clean
  checkout this drops to `excluded=2` (matches the CI-gate baseline).
- `gap=1` is the previously-tracked memo13 gap #4
  (`courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`; `Pico`
  kind without a matching Definition). Not introduced by this task;
  see "Remaining gaps" below.

## Explicit disposition of every non-adapter structured file class

| Class (memo13)                            | Disposition                     | Rationale |
| ----------------------------------------- | ------------------------------- | --------- |
| Academy metadata (Course/Lab/Lesson/Quiz) | adapter-validated               | memo14 adapter projects flat metadata → OE resource; validated against `definitions/{course,lab,lesson,quiz}.yaml`. |
| Academy metadata (Exercise) — this memo   | adapter-validated               | New; adapter classifies path under `exercises/` and projects; validated against `definitions/exercise.yaml`. |
| Repository-root `metadata.yaml`           | intentionally non-OE (excluded from adapter) | Externally governed by `metadata-controller`; memo14 explicit out-of-scope. Not scanned by any adapter-facing pass. |
| Pico resource (`pixstars-head-pitch.yaml`) | tracked compatibility gap       | Native OE-shaped; recognised by OELS; no matching Definition on disk (memo13 gap #4). Surfaced under `gap` bucket. |
| Rule / topology / message-envelope YAML   | intentionally non-OE            | No `apiVersion` header; treated as documentation data by OELS. |
| Crossplane / Kubernetes / HA config       | intentionally non-OE            | Non-OE `apiVersion` namespaces; deliberately outside OELS remit. |
| JSON payload samples + JSON Schema        | intentionally non-OE            | No OE `apiVersion` at root; used only by lab `verify.sh` runtime checks. |
| Checkable-profile package + reports (3)   | intentionally non-OE            | Documentation-shape; explicitly scanned now under `shared:templates/examples` so classification is recorded, not skipped. |
| Constructive-realization `*.ttl` (3)      | out-of-scope (unsupported extension) | OELS extension set is `.yaml/.yml/.json` (memo13 gap #6). Not counted; documented here for auditability. |
| Site / build / CI config                  | intentionally non-OE / excluded | Per-course `_quarto.yml` counted as non-OE inside course scope. Root `_quarto.yml`, root `metadata.yaml`, and `.github/workflows/*.yml` sit outside every course/shared scope and are covered by the OELS pruning rules; documented here for auditability. |

## Verification evidence (this session)

All commands run from the repository root; container runs use the
established Quarto image `ghcr.io/quarto-dev/quarto:latest` (memo10
render evidence).

- `python3 scripts/oels_ci_validate.py`
  → exit `0`; totals `adapter=26 native-oe=0 non-oe=60 excluded=172
  gap=1`; `oels-ci-validate: OK`. 16 scope reports emitted (nine
  courses + shared labs + shared exercises + four templates + shared
  templates/examples).
- `python3 scripts/oels_ci_validate.py --fail-on-gap`
  → exit `1`; single failure surfaces the documented Pico gap:
  `[course:make-the-lamp-nod] gap-as-failure:
  courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml:
  [UnknownDefinition] no Definition for
  apiVersion='open-engineering.io/v1alpha1' kind='Pico' (documented
  gap; see memo13 gap #4)`. Confirms strict mode still catches the
  gap after adding the Exercise kind.
- `python3 work/verify_oels_metadata.py`
  → exit `0`; `academy metadata files checked: 26`; `definitions
  loaded: 5`; four template placeholder notes present; `OK: all
  academy metadata files project and validate cleanly; all fixtures
  met their expected diagnostics.` (developer verifier; matches the
  memo14 contract with the exercise added).
- `python3 work/verify-links.py`
  → `SUMMARY: checked=171 errors=1`. The one error
  (`labs/hello-world-pico-sandcastle/index.qmd -> screenshots/`) is
  pre-existing on `HEAD` and unrelated to this task's changes; the
  file was not modified here. Recorded under "Remaining gaps".
- Quarto root render (container):
  `docker run --rm --platform=linux/amd64 -v "$PWD":/work -w /work
  --entrypoint quarto ghcr.io/quarto-dev/quarto:latest render`
  → `Output created: docs/index.html`, 57/57 files rendered.
  Two `WARN: Unable to resolve link target: memo10.md` warnings are
  pre-existing (memo10 was rotated into `archive/` in an earlier wave)
  and are not introduced or altered by this task.
- Per-course Quarto renders (container, all nine):
  `docker run … render courses/<slug>` for `pico`, `crossplane`,
  `kubernetes`, `sandcastle`, `manifold`, `rust-python-pyo3`,
  `durable-picos-celld`, `make-the-lamp-nod`, `engineering-stories`
  → each finishes with `Output created: _site/index.html`, exit `0`.
- Tree cleanliness: `git status --short` shows only the six intended
  tracked-file modifications/additions plus the pre-existing untracked
  `work/oels-contract/fixtures/lsp/` directory (memo15). `git diff
  HEAD -- courses/** labs/** templates/** exercises/** .github/**
  _quarto.yml metadata.yaml` → empty (no unrelated file touched).

## Remaining gaps (owner / follow-up)

1. **Pico kind without matching Definition** (memo13 gap #4).
   File: `courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`.
   Surfaced in every default CI run as `gap`; promoted to a hard
   failure with `--fail-on-gap`. Owner: whoever adopts memo13's
   recommended Priority 1 (author a `Pico` Definition covering
   `spec.{type,capabilities,implementation,state,events}`). No
   in-flight change here; the classification is stable and the
   diagnostic contract remains asserted.
2. **Cross-document reference resolution** against real academy `id`
   graphs (memo14 gap). Only the `unresolved-reference.yaml` fixture
   exercises the code path today. Owner: a future OELS release that
   ships cross-document resolution or a dedicated academy pass; the
   memo14 adapter mirror does not need to change first.
3. **Pinned OELS stdio server not invoked from CI** (memo15/CI-gate
   task, still open). Full workspace-root initialisation exceeds the
   30 s handshake budget on the pinned SHA `6016c77`. Owner: the OELS
   repository once configurable resource-walk pruning lands upstream;
   the academy CI can then add a matrixed per-course LSP check
   alongside the current in-repo adapter path without disruption.
4. **`.ttl` constructive-realization vocabulary**
   (`templates/constructive-realization/{ontology,hello-pico-instances,
   quality-gate.schema}.ttl`) is outside the OELS extension set
   (memo13 gap #6). Owner: only reopens if Phase 8 TTL is promoted
   from opt-in reference to enforced contract; no action here.
5. **Pre-existing broken link** in
   `labs/hello-world-pico-sandcastle/index.qmd` → `screenshots/`
   (target directory not yet present). Not introduced by this task;
   flagged by `work/verify-links.py` on `HEAD` before and after these
   changes. Owner: whoever picks up the Sandcastle screenshots
   follow-up in a separate task; out of scope here per the task's
   "do not modify unrelated files" rule.

## What is deliberately not changed

- No academy `metadata.yaml` under `courses/`, `labs/`, `exercises/`,
  or `templates/` is edited. Every academy `id`, `prerequisites`,
  `references_labs`, `references_exercises`, `referenced_by`,
  `realizes`, `depends_on`, and slug value is preserved verbatim on
  disk. Cross-course and cross-artifact links remain functional.
- No `apiVersion`/`kind` header is added to any authored file. The
  Exercise projection stays in memory in the adapter, matching the
  memo14 contract for Course/Lab/Lesson/Quiz.
- No CI workflow (`.github/workflows/build-and-publish.yml`), Quarto
  configuration (root or per-course `_quarto.yml`), dependency
  manifest, or generated output under `_site/`/`_freeze/`/`.quarto/`
  is touched. The OELS validation step ordering, Quarto renders,
  publish behavior, and failure surface all remain as approved.
- No absolute sibling OELS path, credential, hosted service, or new
  runtime dependency is introduced. The adapter/validator/fixture
  additions are pure Python + PyYAML (already CI-installed by the
  memo15/CI-gate wave).
- Existing runtime validators (`labs/*/downloads/verify.sh`, per-course
  CI workflows in `courses/{durable-picos-celld,rust-python-pyo3}/
  .github/workflows/ci.yml`, `bin/pico`, and `work/verify-links.py`)
  are unchanged and continue to run under their existing owners.
- The CI gate's default behavior, failure surface, and `--fail-on-gap`
  strict mode are all preserved. Every additional file the sweep now
  covers is either adapter-validated (Exercise) or classified as
  intentionally non-OE (`templates/examples/*.yaml`); no CI diagnostic
  is weakened.
