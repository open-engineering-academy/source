# Memo 14: OELS migration for course metadata and template artifact contracts

## Status

Implemented as an OELS-equivalent adapter and validator (Python), not as a
change to the OELS repository or to the academy's own CI/editor wiring.

## Purpose

Execute the migration plan for the 25 academy `metadata.yaml` files inventoried
in `memo13.md` so that:

1. Every course, lab, lesson, and quiz metadata file has a recorded OELS
   classification and a machine-checked migration result.
2. Intended Open Engineering metadata is validated with the same diagnostic
   codes the Open Engineering Language Server (OELS) surfaces to editor
   clients.
3. Non-OE metadata is not falsely presented as OELS-native.
4. Identifiers, references, prerequisites, dependencies, and cross-course /
   cross-lab links keep their existing meaning on disk.
5. No absolute sibling path, credential, generated output, editor-specific
   fork, or CI change is introduced.

## Approach

Academy `metadata.yaml` files are flat and academy-shaped (`id`, `slug`,
`title`, `level`, `duration`, `teaches`, `produces`, `references_labs`, …).
OELS only recognises documents whose root is a mapping, whose `apiVersion`
starts with `open-engineering.io/`, and whose `kind` is a non-empty string
(see `memo13.md`). The migration therefore projects the flat academy
metadata into the OE resource envelope in memory, without editing any
authored `metadata.yaml` on disk:

- `apiVersion` → `open-engineering.io/v1alpha1`
- `kind` → `Course` | `Lab` | `Lesson` | `Quiz` (from path)
- `metadata.name` → academy `id` with `.` replaced by `-` (DNS-1123 shape)
- `metadata.id` → academy `id` verbatim (cross-course links unchanged)
- `metadata.slug` → academy `slug` (courses only)
- `spec` → everything else, verbatim

Four Definitions are added under `definitions/` (top-level, per OELS
discovery rules): `course.yaml`, `lab.yaml`, `lesson.yaml`, `quiz.yaml`.
Each targets `apiVersion: open-engineering.io/v1alpha1` and its respective
`kind`. `spec.additionalProperties` is `true` on all four so course-owned
extensions (e.g. `checkable_profile`, `runtime_substrate`) stay valid
without further schema churn; `metadata.additionalProperties` is `false`
so drift in identifier fields surfaces immediately.

## Classification matrix (25 files)

| Class (from memo13) | Files | OELS-recognised-as | Migration result |
| --- | --- | --- | --- |
| Course metadata | 8 course-root `courses/*/metadata.yaml` (all courses except `engineering-stories`) | Ignored by OELS as-authored (no `apiVersion`). Projected via adapter to `kind: Course` and validated against `definitions/course.yaml`. | Pass. |
| Lab metadata | 12 `labs/*/metadata.yaml` + 1 nested `courses/engineering-stories/labs/audio-drama-lab/metadata.yaml` | Ignored by OELS as-authored. Projected via adapter to `kind: Lab` and validated against `definitions/lab.yaml`. | Pass. |
| Template metadata (placeholders) | `templates/{course,lab,lesson,quiz}/metadata.yaml` (4) | Ignored by OELS as-authored; even after projection the `id` contains `<slug>`, which is not a DNS-1123 identifier. | Expected `MalformedIdentifier` recorded and asserted; no other diagnostics. |
| Repository-root `metadata.yaml` | `metadata.yaml` (root) | Ignored (governed by external `metadata-controller`; not an academy artefact). | Explicitly out of scope; not projected. |

Total: 8 + 12 + 1 + 4 = 25 checked. Root `metadata.yaml` is intentionally
excluded (see `memo13.md`, "Repository-organization metadata"). No lesson
or quiz metadata exists outside `templates/`, so those Definitions apply
today only to the templates and to the fixtures.

## Adapter and validator

Everything ships under `work/`; no runtime dependency is added to the
academy itself.

- `work/oels_metadata_adapter.py` — path-based `Course/Lab/Lesson/Quiz`
  classification and the flat-metadata → OE-shape projection.
- `work/oels_metadata_diagnostics.py` — shared `Diagnostic` dataclass with
  OELS-equivalent `code`/`message`/`path`.
- `work/oels_metadata_validator.py` — Definition loader, registry, and
  resource-level checks: `MalformedResource`, `MalformedIdentifier`,
  `UnknownDefinition`.
- `work/oels_metadata_validator_walk.py` — schema walker emitting
  `MissingRequiredProperty`, `UnknownProperty`, `IncorrectType`,
  `InvalidEnumValue`.
- `work/verify_oels_metadata.py` — discovery + driver + fixture runner.

## Fixtures (contract tests)

Under `work/oels-contract/fixtures/`. Each is an already-projected OE
document; the driver asserts each produces exactly the documented set of
OELS diagnostic codes.

| Fixture | Expected diagnostic codes |
| --- | --- |
| `valid-course.yaml` | (none) |
| `valid-lab.yaml` | (none) |
| `valid-lesson.yaml` | (none) |
| `valid-quiz.yaml` | (none) |
| `malformed.yaml` | `MalformedResource` |
| `unresolved-reference.yaml` | `UnknownDefinition` |
| `unsupported-shape.yaml` | `MalformedIdentifier`, `MissingRequiredProperty`, `IncorrectType`, `InvalidEnumValue`, `UnknownProperty` |

## Verification commands

Run from the repository root:

```
python3 work/verify_oels_metadata.py
```

Expected output (last three lines):

```
academy metadata files checked: 25
definitions loaded: 4
OK: all academy metadata files project and validate cleanly; all fixtures met their expected diagnostics.
```

The driver also prints the four expected template-placeholder notes.

## What is deliberately not changed

- No authored `metadata.yaml` file is edited on disk. Identifiers,
  references, prerequisites, cross-course and cross-lab links, and slugs
  are all preserved verbatim.
- No absolute sibling path to the OELS repository is embedded anywhere in
  the academy repository. The adapter and validator are Python and
  implement OELS's documented diagnostic contract locally.
- No CI workflow, editor configuration, dependency manifest, or generated
  output under `_site/`, `_freeze/`, or `.quarto/` is touched.
- No lesson or quiz metadata is invented outside the templates; the
  `Lesson` and `Quiz` Definitions describe the shape used by
  `templates/{lesson,quiz}/metadata.yaml` and by the fixtures only.

## Remaining gaps (for follow-up memos)

- Cross-document reference resolution (unresolved-reference diagnostics
  against real academy `id` graphs) is not implemented; only the fixture
  path is asserted.
- Adopting the adapter inside OELS itself, or as an OELS pre-parse hook,
  is out of scope; that decision belongs to the OELS repository.
- The four template placeholder metadata files still contain `<slug>`
  tokens by design. If the academy later chooses to make templates
  copy-paste-valid, updating the placeholders is a separate task.
