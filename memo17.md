# Memo 17: Close the Pico Definition gap

## Status

Implemented as a small additive extension of the memo14/memo15/memo16 OELS
adoption trail. Adds one Definition, two contract fixtures, and their
`.gitignore`/README entries. No academy content, learner prose, runtime
verifier, CI architecture, publish workflow, dependency, credential, or
absolute developer path is changed.

## Purpose

Close **memo13 gap #4** (recorded verbatim in memo16 § "Remaining gaps"):
the on-disk native OE resource
`courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml` (`apiVersion:
open-engineering.io/v1alpha1`, `kind: Pico`) had no matching Definition, so
OELS-equivalent validation reported `UnknownDefinition` for it and the CI
gate surfaced it as `gap=1` (promoted to hard failure by `--fail-on-gap`).

## Changes (files touched)

Tracked (five files, additive; no delete, no rename):

- `definitions/pico.yaml` — new. `apiVersion: open-engineering.io/v1alpha1`,
  `kind: Definition`, `spec.target.kind: Pico`. Schema mirrors the fields the
  on-disk PixStars Pico uses: `spec.{type, capabilities, implementation,
  state, events}`. `metadata` requires only `name` (native Pico has no
  academy `id` sibling). `spec.additionalProperties: true`, and
  `implementation`/`state`/`events` are `additionalProperties: true` so the
  Pico's nullable/optional runtime state (`temperature: null`,
  `voltage: null`, …) and nested event topology validate without a
  Definition change every time a runtime field evolves.
- `work/oels-contract/fixtures/valid-pico.yaml` — new fixture that mirrors
  the projected shape of the on-disk Pico. Deterministically yields **zero**
  diagnostics against `definitions/pico.yaml` (verified below).
- `work/oels-contract/fixtures/invalid-pico.yaml` — new fixture that
  deterministically yields the diagnostic set `{MalformedIdentifier,
  MissingRequiredProperty, IncorrectType, UnknownProperty}` (dotted+upper
  `metadata.name`, missing `state`+`events`, `capabilities` as string not
  array, extraneous root-level key). Adds Pico-specific coverage of every
  applicable OELS diagnostic code without weakening the existing
  Course-focused `unsupported-shape.yaml` (which still asserts the wider
  set including `InvalidEnumValue`).
- `work/oels-contract/fixtures/README.md` — add rows for `valid-pico.yaml`
  and `invalid-pico.yaml`; add a short paragraph noting the Pico fixtures
  are the first pair for a **native OE** kind (no academy `id` sibling).
- `definitions/README.md` — add the `pico.yaml` row and a new "Academy `id`
  vs OELS `metadata.name`" section preserving the memo13 distinction:
  adapter-projected artifacts keep the dotted academy `id` **and** get a
  DNS-1123 `metadata.name`; native Pico resources are OE-shaped from the
  outset and only carry `metadata.name`.
- `.gitignore` — two additional unignore entries for the new fixtures
  (`!/work/oels-contract/fixtures/valid-pico.yaml`,
  `!/work/oels-contract/fixtures/invalid-pico.yaml`). All other `/work/*`
  rules are unchanged.

Locally exercised only (untracked developer verifier; memo14/memo16 pattern):

- `work/verify_oels_metadata.py` — add `valid-pico` and `invalid-pico` to
  the fixture list with their expected diagnostic sets. Not part of the CI
  gate and not committed.

No file was edited under `courses/**` (including the native Pico YAML
itself), `labs/**`, `exercises/**`, `templates/**`, `.github/**`,
`_quarto.yml`, per-course `_quarto.yml`, root `metadata.yaml`, `bin/`,
`docs/`, `scripts/`, or any generated output. No `open-engineering.io/`
header was added to any authored file. No absolute sibling OELS path,
credential, hosted service, or new runtime dependency is introduced.

## Verification evidence (this session)

All commands run from the repository root; container runs use the
established Quarto image `ghcr.io/quarto-dev/quarto:latest` (memo10/memo16
render evidence path).

- `python3 scripts/oels_ci_validate.py`
  → exit `0`; totals `adapter=26 native-oe=1 non-oe=60 excluded=213
  gap=0`; `oels-ci-validate: OK`. The Pico moved from `gap=1 native-oe=0`
  to `gap=0 native-oe=1` under `course:make-the-lamp-nod`; all other
  scope counts match the memo16 baseline (developer `excluded` varies
  with local scratch/build state; CI-clean-checkout baseline unaffected).
- `python3 scripts/oels_ci_validate.py --fail-on-gap`
  → exit `0`; strict mode now passes with the Pico gap resolved and no
  other gap remaining.
- Direct Pico diagnostic inspection against the on-disk resource
  (`validate_resource` over `courses/make-the-lamp-nod/picos/pixstars-head-
  pitch.yaml` with the six-Definition registry) → `<none>` (empty
  diagnostic list). Confirms the Pico Definition's structural coverage of
  `type`, `capabilities`, `implementation`, nullable `state` values, and
  the nested `events.{subscribesTo,emits}` shape.
- `python3 work/verify_oels_metadata.py`
  → exit `0`; `academy metadata files checked: 26`; `definitions loaded: 6`;
  four template placeholder notes present; `OK: all academy metadata files
  project and validate cleanly; all fixtures met their expected
  diagnostics.` (developer verifier; `valid-pico` yields `set()` and
  `invalid-pico` yields `{MalformedIdentifier, MissingRequiredProperty,
  IncorrectType, UnknownProperty}` exactly).
- Workflow YAML parse:
  `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-and-publish.yml'))"`
  → OK. Unchanged.
- Quarto root render (container, memo16 command):
  → `Output created: docs/index.html`, 57/57 files rendered. The two
  `WARN: Unable to resolve link target: memo10.md` warnings are pre-
  existing (memo10 was rotated into `archive/` in an earlier wave) and
  are not introduced or altered by this task.
- Per-course Quarto renders (container, all nine):
  `docker run … render courses/<slug>` for `crossplane`,
  `durable-picos-celld`, `engineering-stories`, `kubernetes`,
  `make-the-lamp-nod`, `manifold`, `pico`, `rust-python-pyo3`, `sandcastle`
  → each finishes with `Output created: _site/index.html`, exit `0`.
- `python3 work/verify-links.py` → `SUMMARY: checked=171 errors=1`. The
  single error (`labs/hello-world-pico-sandcastle/index.qmd -> screenshots/`)
  is pre-existing on `HEAD` and unrelated to this task's changes
  (identical to memo16 § 5); no `.qmd` file was modified here.
- Tree cleanliness: `git status --short` shows only the intended tracked
  changes (three modified: `.gitignore`, `definitions/README.md`,
  `work/oels-contract/fixtures/README.md`; three added:
  `definitions/pico.yaml`, `work/oels-contract/fixtures/valid-pico.yaml`,
  `work/oels-contract/fixtures/invalid-pico.yaml`) plus the pre-existing
  untracked `work/oels-contract/fixtures/lsp/` directory (memo15/memo16).

## Residual issues

- Pre-existing broken link in `labs/hello-world-pico-sandcastle/index.qmd`
  → `screenshots/` (target directory not yet present). Flagged by
  `work/verify-links.py` on `HEAD` before and after these changes; owner
  remains whoever picks up the Sandcastle screenshots follow-up in a
  separate task (memo16 § 5). Out of scope here.
- Memo16 remaining gaps 2 (cross-document reference resolution), 3
  (pinned OELS stdio server not invoked from CI) and 4 (`.ttl`
  constructive-realization vocabulary) are unchanged. Only memo13 gap #4
  (Pico) is closed by this task.

## What is deliberately not changed

- The native Pico YAML `courses/make-the-lamp-nod/picos/pixstars-head-
  pitch.yaml` is not edited: no field added, removed, renamed, or
  reordered. The Pico Definition is fitted to the on-disk resource, not
  the other way round.
- No academy `metadata.yaml`, learner `.qmd`, per-course or root
  `_quarto.yml`, `.github/workflows/*.yml`, `bin/pico`, per-course CI
  workflow, `labs/*/downloads/verify.sh`, or dependency manifest is
  touched. Publishing architecture and runtime verifiers are preserved.
- No new Definition kind is introduced beyond Pico. The Rule /
  InteractionTopology / TransportMap / profile-package Definitions
  recommended by memo13 Priority 3 remain out of scope; those artifacts
  stay classified as intentionally non-OE by the CI gate.
- The CI gate's default behaviour, failure surface, and `--fail-on-gap`
  strict mode are all preserved. The only bucket-count change is the
  one native Pico resource moving from `gap` to `native-oe`.
