# Evaluation — Is the Story Both True and Clear?

A finished audio artifact that entertains but teaches the wrong architecture must
**not** pass just because it is enjoyable. Technical accuracy carries the most
weight. This file evaluates the Crossplane restaurant against the same
five-dimension rubric learners use in the course lab.

## The rubric

| Dimension | Question | This example's assessment |
| --- | --- | --- |
| **Technical accuracy** | Does the story correctly represent the engineering concept? | Strong. Scene 03–05 match XRC→XR→Composition→MR→Provider exactly; the developer never speaks to providers. |
| **Metaphor quality** | Does the metaphor improve understanding without serious misconceptions? | Strong. Near-isomorphic mapping; the menu/order/recipe/kitchen leaves no serious misconception. |
| **Narrative clarity** | Can the listener follow without visual assistance? | Strong. Scene-oriented, with a character per responsibility and a clear dramatic arc. |
| **Audio communication** | Do voice, narration, and sound communicate actions and context effectively? | Strong. Semantic sound design marks each event; distinct voices per role. |
| **Learning outcome** | Can the listener explain the underlying model afterward? | Strong. The takeaway narration in Scene 07 restates the composite request → platform composes/realizes/reconciles chain. |

## Scoring guidance

Score each dimension (e.g. 1–5) and compute a weighted total, with **technical
accuracy weighted highest** (e.g. 40%). Use this to decide whether an artifact
"passes" and where it needs revision.

## Where errors come from — and how to fix them

Trace any defect back to its origin stage, because each stage is inspectable:

| Symptom | Likely origin | Fix where? |
| --- | --- | --- |
| Wrong architecture conveyed | The model was wrong or misunderstood | `concept.md` / the real docs |
| Misleading comparison | The metaphor mis-fits the model | `metaphor.md` |
| Confusing dialogue | The story didn't carry the relationship | `scenes.md` / `screenplay.md` |
| Wrong pronunciation / bad pacing | The renderer | `production.md` |

## Definition of done for this reference example

- [x] The course-level method applies to any provider (Wondercraft is documented
      as the validated implementation, not a dependency).
- [x] Technical truth is modeled first (`concept.md` precedes metaphor).
- [x] Metaphor mappings are documented (`metaphor.md`).
- [x] Audio-first screenplay conventions are documented (`screenplay.md`).
- [x] Narration, dialogue, ambience, sound effects, and scene transitions are all
      covered.
- [x] Scene-oriented storytelling is used (`scenes.md` + `screenplay.md`).
- [x] A production workflow is documented (`production.md`).
- [x] The artifacts are structured so a future Composer could generate a first
      screenplay draft from the model.
