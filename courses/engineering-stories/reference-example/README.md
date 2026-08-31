# The Crossplane Restaurant — Reference Implementation

This is the canonical reference implementation for the **Engineering Stories**
course. It is a complete worked example of turning real Crossplane
architecture into a short, educational **audio drama** (a *hoorspel*).

Read it top-to-bottom as a **reverse engineering** walkthrough: start from the
finished audio story, then work backwards through screenplay → scenes →
characters → metaphor → technical model. Then rebuild the process in the
**forward** direction for your own project.

## Why Crossplane?

Crossplane is a good first subject because its architecture already maps almost
one-to-one onto a restaurant:

| Crossplane | Restaurant |
| --- | --- |
| XRD (CompositeResourceDefinition) | Menu |
| XR (Composite Resource) | Order |
| Composition | Recipe |
| Managed Resources | Prepared components |
| Provider | Kitchen capability |
| Reconciliation | Cooking until the dish is perfect |
| Claim (XRC) | Customer's request placed by a server |

The metaphor is *near-isomorphic*, which keeps the mapping honest and prevents
the story from teaching a misleading model.

## The architectural principle

Each artifact sits at a distinct stage in the pipeline:

```
WHAT IS TRUE?         Technical Model   →  this folder's concept + the real docs
HOW TO EXPLAIN?       Metaphor          →  metaphor.md
HOW TO EXPERIENCE?    Story             →  characters.md + scenes.md
HOW TO REPRESENT?     Screenplay        →  screenplay.md
HOW TO RENDER?        Audio Producer    →  production.md
HOW TO EVALUATE?      Audio Artifact    →  evaluation.md
```

Every stage is inspectable, so errors trace back to their origin:
a technical error belongs in the model, a misleading analogy in the metaphor,
confusing dialogue in the story, a bad pronunciation in rendering.

## Files in this example

- [`concept.md`](concept.md) — the technical truth, captured before any metaphor
- [`metaphor.md`](metaphor.md) — the documented mapping between system and story
- [`characters.md`](characters.md) — characters as responsibilities, not decoration
- [`scenes.md`](scenes.md) — the scene plan with purpose and learning outcome
- [`screenplay.md`](screenplay.md) — the audio-first, scene-oriented screenplay
- [`production.md`](production.md) — the AI audio production workflow
- [`evaluation.md`](evaluation.md) — the five-dimension evaluation of the result

## How to read it as a course learner

1. **Experience** — listen to the final audio artifact (or read `screenplay.md`).
2. **Deconstruct** — notice how characters map to responsibilities and how sound
   maps to events. Ask: *how did an architecture model become this story?*
3. **Construct** — perform the same five-stage transformation on your own project.
4. **Reflect** — evaluate your own result with the same rubric used here.
