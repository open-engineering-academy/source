# Constructive-realization formal schema (Phase 8 reference)

This directory holds the **formal** reference encoding of the
constructive-realization vocabulary, as proposed by the combined memo3.
It is an **additive, opt-in** layer: it does not change the Phase 1–7
`metadata.yaml` contract, and no artifact validates against these files
unless it explicitly opts in via a `checkable_profile`.

| File | Purpose |
| ---- | ------- |
| `ontology.ttl` | OWL-style schema (Turtle): the classes (`Definition`, `Realization`, `Element`, `Constraint`, `Validation`, `Dependency`, `Feedback`) and the relations that define constructive realization. |
| `quality-gate.schema.ttl` | SHACL shapes (Turtle): the operational quality gate — what a record must contain for a realized Element to count as conformant. |
| `hello-pico-instances.ttl` | Concrete `Hello, Pico!` instance data (Turtle): the Definition, Realization, Element, and Validations for the Hello Pico path, mirroring the Phase 4 `hello-pico-v1` checkable profile in formal form. |

## Relationship to the phases

- Phases 1–7 use natural-language Constraints and `metadata.yaml` fields and
  deliberately keep formal OWL/SHACL out of scope (see each phase's "Out of
  scope" section).
- Phase 8 introduces these files as a reference so course authors who want a
  formal encoding have one source of truth in-repo. The formal schema
  **re-states** the same shape rules the Phase 1–7 fields already express; it
  never replaces them.

## How to use

- Reference these files from a course or template page when you need to show
  the formal class/property vocabulary or the quality gate.
- Do not require learners to author Turtle in Phase 1–6 material; the formal
  encoding is a reference, not a learner authoring format.

See the Phase 8 section of [`../README.qmd`](../README.qmd) and
[`../../courses/pico/constructive-realization.qmd`](../../courses/pico/constructive-realization.qmd).
