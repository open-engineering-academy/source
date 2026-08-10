# Hello Pico v1 — machine-readable example package

This directory holds **one narrow, opt-in, machine-readable example** of the
`hello-pico-v1` checkable profile defined in the Phase 4 section of
`templates/README.qmd`.

It is deliberately bounded:

- It lives under `templates/` (excluded from the Quarto render) so it does not
  ship as a learner page and does not touch the published academy site.
- It does **not** retrofit any existing `courses/…/metadata.yaml` or
  `labs/…/metadata.yaml`. The taught Hello Pico path is unchanged.
- It expresses the full constructive chain (Definition → Realization → Element,
  with Constraints, Dependencies, Validations, and Feedback) for the single
  Hello Pico example, and nothing else.

## Contents

- `package.yaml` — the machine-readable records:
  - `package.definition` — the Kubernetes-Job-form Hello Pico Definition,
    with `constraints` and `feedback`.
  - `package.realization` — the Crossplane-driven Realization, with
    `depends_on` (the four Hello Pico labs), `realization_pattern`,
    `composition_pattern`, `conformance_status`, `lifecycle_state`,
    `validated_by`, `validation_results` (each linking to a Constraint via
    `validates_constraint`), and `evidence`.
  - `package.element` — the observed Kubernetes Job Element, with
    `produced_by` pointing at the Realization and its own `validation_results`.
- `validate.py` — a stdlib+PyYAML validator that checks syntax, required
  profile fields, and internal cross-references (see below).
- `README.md` — this file.

## Mapping to the taught Hello Pico path

The example does not invent new material; it references artefacts already
shipped in the academy:

| Profile role   | Taught surface                                                  |
| -------------- | --------------------------------------------------------------- |
| Definition     | `courses/pico/metadata.yaml`, `courses/crossplane/metadata.yaml` |
| Constraints    | `constraints:` on the two course `metadata.yaml` files          |
| Realization    | `labs/hello-pico-on-kubernetes/metadata.yaml`                   |
| Dependencies   | the four Hello Pico labs referenced under `depends_on`          |
| Validations    | `labs/hello-pico-on-kubernetes/walkthrough.qmd` steps 7–9        |
| Evidence       | `labs/hello-pico-on-kubernetes/downloads/verify.sh`             |
| Element        | the composed Kubernetes Job whose logs equal `Hello, Pico!`     |
| Feedback       | mirrors `courses/crossplane/metadata.yaml`'s `feedback:` entry  |

`package.taught_surfaces` lists the concrete on-disk paths the validator
resolves.

## Validating the package

The validator runs entirely on `package.yaml` (no rendering, no CI wiring):

```bash
python3 templates/examples/hello-pico-v1/validate.py
```

It confirms:

1. `package.yaml` parses as YAML.
2. Each record carries the fields the `hello-pico-v1` profile requires
   (per the Phase 4 section of `templates/README.qmd`).
3. Cross-references line up:
   - `realization.realizes` ↔ `definition.id`
   - `element.realizes` ↔ `definition.id` (single-item)
   - `element.produced_by` ↔ `realization.id`
   - every `validation_results[].check` is listed under `validated_by`
   - every `validates_constraint` text appears verbatim in
     `definition.constraints`
4. Every path listed under `taught_surfaces` exists on disk.

## What this package deliberately does *not* do

- No repo-wide metadata migration or additional checkable profiles.
- No graph database, triple store, or SHACL/OWL enforcement runtime.
- No changes to the published academy site, its render list, or its navbar.
- No new learner-facing course pages (those already exist:
  `courses/sandcastle/hello-pico-realization-chain.qmd` and
  `courses/sandcastle/hello-pico-checkable-profile.qmd`).

Read the accompanying learner references before extending the package:

- `courses/sandcastle/hello-pico-checkable-profile.qmd` — how the profile
  maps onto the taught path.
- `templates/README.qmd` — the Phase 1–4 authoring contract.

## Phase 5: profile validator and report path

Phase 5 adds a second, sibling script that runs the opt-in profile
check described in the Phase 5 section of `templates/README.qmd`
against **real repository metadata** — not against this example
package. It exists here so all `hello-pico-v1` tooling lives in one
narrow, author-run place under render-excluded `templates/`.

```bash
# Print one YAML validation report per opted-in claimant to stdout.
python3 templates/examples/hello-pico-v1/validate_profile.py

# Also write each report to templates/examples/hello-pico-v1/reports/<slug>.yaml.
python3 templates/examples/hello-pico-v1/validate_profile.py --write
```

The validator:

1. Discovers every `metadata.yaml` under `courses/` and `labs/` that
   declares `checkable_profile: hello-pico-v1`.
2. Applies the Phase 4 shape rules for the claimant's
   `constructive_role` (Definition / Realization / Element).
3. Emits one report per claimant using the Phase 5 report shape
   (`profile`, `subject`, `subject_role`, `checked_at`, `overall`,
   `findings[]`, `evidence_reviewed[]`).

Today the only opted-in claimants are the Definition on
`courses/crossplane/metadata.yaml` and the Realization on
`labs/hello-pico-on-kubernetes/metadata.yaml` (see the
[hello-pico-v1 adoption task](../../../courses/sandcastle/hello-pico-profile-validation.qmd)),
so a passing run produces exactly two `overall: conformant` reports.
The pre-recorded passing artifacts live under
`templates/examples/hello-pico-v1/reports/` for reference.

The validator is deliberately narrow: it reads only `metadata.yaml`,
never runs `verify.sh` or `kubectl`, never mutates any file, and its
verdict is informational only. It is **not** wired into CI, `pre-commit`,
or Quarto rendering.

## Phase 6: report index and history

Phase 6 adds two small on-disk artifacts alongside the per-claimant
reports produced by `validate_profile.py`, matching the Phase 6 section
of `templates/README.qmd`:

- `reports/index.yaml` — the aggregate catalog of the per-claimant
  reports currently on disk for `hello-pico-v1`. It carries `profile`,
  `generated_at`, and one `entries[]` mapping per claimant with
  `subject`, `subject_role`, `report`, `overall`, `checked_at`, and
  `history`. Today it lists the two opted-in claimants — the Definition
  on `courses/crossplane/metadata.yaml` and the Realization on
  `labs/hello-pico-on-kubernetes/metadata.yaml` — both with
  `overall: conformant` and an empty `history`.
- `reports/history/` — the exemplar location for retained prior
  reports on this profile. The directory is currently empty because no
  snapshots have been retained yet; keeping it in place fixes the
  `history/` layout (rather than the ISO-date-suffix alternative) as the
  convention this example package uses.

The index is authored by hand and kept in sync with the per-claimant
reports; Phase 6 does not add tooling to generate or diff it. To retain
an outgoing report, copy it into `reports/history/` with an ISO-date
suffix (for example, `reports/history/oe-course-crossplane.2026-08-01.yaml`)
before regenerating the current file with
`python3 templates/examples/hello-pico-v1/validate_profile.py --write`,
then add the snapshot to that entry's `history:` list in
`reports/index.yaml`.
