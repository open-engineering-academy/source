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
