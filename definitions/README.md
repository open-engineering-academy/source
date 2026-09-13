# OE artifact Definitions

This directory is the workspace-root `definitions/` folder discovered by the
Open Engineering Language Server (OELS), following the parser and loader
contract described in `templates/README.qmd` § "OELS authoring integration".

Two authoring paths flow through this directory:

1. **Adapter-projected academy metadata** (Course, Lab, Lesson, Quiz,
   Exercise). Current academy `metadata.yaml` files are flat (no
   `apiVersion`/`kind` header, dotted `id` values), so those Definitions are
   applied to the projection the metadata adapter (`work/verify_oels_metadata.py`
   and `scripts/oels_ci_validate.py`) produces, not to the flat file itself.
2. **Native OE resources** (Pico today). These are authored OE-shaped on
   disk under `courses/<slug>/picos/` and validated directly by OELS
   without an adapter. Native Pico resources carry only `metadata.name`
   (a native DNS-1123 identifier) — they have no academy `id` sibling.

## Files

| File            | Target `apiVersion`               | Target `kind` | Applies to                                                     |
| --------------- | --------------------------------- | ------------- | -------------------------------------------------------------- |
| `course.yaml`   | `open-engineering.io/v1alpha1`    | `Course`      | Every `courses/<slug>/metadata.yaml` after adapter projection. |
| `lab.yaml`      | `open-engineering.io/v1alpha1`    | `Lab`         | Every top-level `labs/<slug>/metadata.yaml` and course-scoped `courses/<slug>/labs/<lab-slug>/metadata.yaml` after adapter projection. |
| `lesson.yaml`   | `open-engineering.io/v1alpha1`    | `Lesson`      | Applies to any future `metadata.yaml` copied from `templates/lesson/`; today only the template placeholder exists. |
| `quiz.yaml`     | `open-engineering.io/v1alpha1`    | `Quiz`        | Applies to any future `metadata.yaml` copied from `templates/quiz/`; today only the template placeholder exists. |
| `exercise.yaml` | `open-engineering.io/v1alpha1`    | `Exercise`    | Every top-level `exercises/<slug>/metadata.yaml` after adapter projection (see memo16.md). |
| `pico.yaml`     | `open-engineering.io/v1alpha1`    | `Pico`        | Every native OE Pico resource on disk (today: `courses/make-the-lamp-nod/picos/pixstars-head-pitch.yaml`). Closes memo13 gap #4; see memo17.md. |

## Scope discipline

- The adapter-facing Definitions (Course, Lab, Lesson, Quiz, Exercise) declare
  only the fields the current 26 adapter-scanned academy `metadata.yaml` files
  actually use (verified against the on-disk set).
- `spec.additionalProperties: true` is set intentionally so evolving academy
  vocabulary does not trigger false `UnknownProperty` diagnostics before the
  wider migration task lands. The Pico Definition follows the same rule for
  `spec` and, additionally, uses `additionalProperties: true` on `state`,
  `implementation`, and `events` so nullable/optional runtime fields evolve
  without a Definition change.
- No `open-engineering.io/` file in `courses/`, `labs/`, or `templates/` is
  reshaped by adding these Definitions — the adapter is the only translation
  layer for the academy path, and the native Pico YAML on disk is unchanged.
  See `memo14.md` for the classification matrix and adapter contract, and
  `memo17.md` for the Pico Definition addition and the resolved gap.

## Academy `id` vs OELS `metadata.name`

The distinction is intentional and preserved by both authoring paths:

- **Academy metadata** (Course/Lab/Lesson/Quiz/Exercise) keeps the historical
  dotted `id` (e.g. `oe.course.pico`, `oe.lab.hello-pico`) and the memo14
  adapter projects a DNS-1123 sibling `metadata.name` (dots replaced with
  dashes) for OELS. Both fields are required by the Course/Lab/Exercise
  Definitions so cross-artifact references keep resolving off the academy `id`
  graph.
- **Native OE resources** (Pico) do not have an academy `id` sibling. They
  are authored OE-shaped with a DNS-1123 `metadata.name` from the outset;
  `pico.yaml` therefore only requires `metadata.name`.
