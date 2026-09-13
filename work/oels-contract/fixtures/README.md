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
| `malformed.yaml`              | —       | `MalformedResource`                                                                                    |
| `unresolved-reference.yaml`   | *(kind not covered by any Definition)* | `UnknownDefinition`                                                                    |
| `unsupported-shape.yaml`      | Course  | `MalformedIdentifier`, `UnknownProperty`, `MissingRequiredProperty`, `IncorrectType`, `InvalidEnumValue` |

The fixtures are deliberately small so a change to the shared Course / Lab /
Lesson / Quiz / Exercise Definitions immediately surfaces here without having
to touch real course content.
