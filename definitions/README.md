# OE artifact Definitions

This directory is the workspace-root `definitions/` folder discovered by the
Open Engineering Language Server (OELS), following the parser and loader
contract described in `templates/README.qmd` § "OELS authoring integration".

Each Definition here describes the **OE shape** of an academy artifact class
(Course, Lab, Lesson, Quiz, Exercise). Because current academy `metadata.yaml`
files are flat (they carry no `apiVersion`/`kind` header and use dotted `id`
values), these Definitions are **not applied directly** by opening a course
`metadata.yaml` in an OELS editor session — they describe the projected
target that the metadata adapter (`work/verify_oels_metadata.py`) produces.

## Files

| File            | Target `apiVersion`               | Target `kind` | Applies to                                                     |
| --------------- | --------------------------------- | ------------- | -------------------------------------------------------------- |
| `course.yaml`   | `open-engineering.io/v1alpha1`    | `Course`      | Every `courses/<slug>/metadata.yaml` after adapter projection. |
| `lab.yaml`      | `open-engineering.io/v1alpha1`    | `Lab`         | Every top-level `labs/<slug>/metadata.yaml` and course-scoped `courses/<slug>/labs/<lab-slug>/metadata.yaml` after adapter projection. |
| `lesson.yaml`   | `open-engineering.io/v1alpha1`    | `Lesson`      | Applies to any future `metadata.yaml` copied from `templates/lesson/`; today only the template placeholder exists. |
| `quiz.yaml`     | `open-engineering.io/v1alpha1`    | `Quiz`        | Applies to any future `metadata.yaml` copied from `templates/quiz/`; today only the template placeholder exists. |
| `exercise.yaml` | `open-engineering.io/v1alpha1`    | `Exercise`    | Every top-level `exercises/<slug>/metadata.yaml` after adapter projection (see memo16.md). |

## Scope discipline

- The Definitions here declare only the fields the current 26 adapter-scanned
  academy `metadata.yaml` files actually use (verified against the on-disk set).
- `spec.additionalProperties: true` is set intentionally so evolving academy
  vocabulary does not trigger false `UnknownProperty` diagnostics before the
  wider migration task lands.
- No `open-engineering.io/` file in `courses/`, `labs/`, or `templates/` is
  reshaped by adding these Definitions — the adapter is the only translation
  layer. See `memo14.md` for the classification matrix and adapter contract.
