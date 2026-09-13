# OELS metadata contract fixtures

Fixtures for `work/verify_oels_metadata.py`. Each fixture is an already-
projected OE-shape document (that is, the adapter has already wrapped it in
`apiVersion`/`kind`/`metadata`/`spec`), so the validator runs against it
directly. The driver script asserts each fixture produces exactly the set of
OELS diagnostic codes documented below.

| Fixture                       | Kind    | Expected diagnostic codes                                                                              |
| ----------------------------- | ------- | ------------------------------------------------------------------------------------------------------ |
| `valid-course.yaml`           | Course  | *(none)*                                                                                               |
| `valid-lab.yaml`              | Lab     | *(none)*                                                                                               |
| `valid-lesson.yaml`           | Lesson  | *(none)*                                                                                               |
| `valid-quiz.yaml`             | Quiz    | *(none)*                                                                                               |
| `valid-exercise.yaml`         | Exercise | *(none)*                                                                                              |
| `valid-pico.yaml`             | Pico    | *(none)*                                                                                               |
| `malformed.yaml`              | —       | `MalformedResource`                                                                                    |
| `unresolved-reference.yaml`   | *(kind not covered by any Definition)* | `UnknownDefinition`                                                                    |
| `unsupported-shape.yaml`      | Course  | `MalformedIdentifier`, `UnknownProperty`, `MissingRequiredProperty`, `IncorrectType`, `InvalidEnumValue` |
| `invalid-pico.yaml`           | Pico    | `MalformedIdentifier`, `MissingRequiredProperty`, `IncorrectType`, `UnknownProperty`                   |

The fixtures are deliberately small so a change to the shared Course / Lab /
Lesson / Quiz / Exercise / Pico Definitions immediately surfaces here without
having to touch real course content.

The two Pico fixtures are the first pair for a **native OE** kind (authored
OE-shaped on disk, not projected by the memo14 adapter). They therefore only
carry `metadata.name` — there is no academy `id` sibling — which is what the
Pico Definition also enforces. See `definitions/README.md` for the wider
distinction between academy identifiers and OELS `metadata.name`.
