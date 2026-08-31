# Metaphor — How We Explain It

> *We never simplify technology by abandoning its engineering model. We
> understand the model first, transform it deliberately, and use story to make
> that understanding accessible.*

A metaphor must be an **attempt at an isomorphism**: for every important fact in
the model there should be a counterpart in the story, and — critically — the
story must **not** introduce serious misconceptions that would contradict the
model.

## The mapping

This is the contract between `concept.md` and every other file. Every character,
scene, and sound effect must honor this table.

| Crossplane (technical model) | Restaurant (metaphor) | Why it fits |
| --- | --- | --- |
| XRD (CompositeResourceDefinition) | Menu | Defines *what can be requested*. |
| Claim (XRC) | Order placed by a server | The developer's request for a specific dish. |
| Composite Resource (XR) | The order ticket | The concrete instance of the request. |
| Composition | Recipe | Says *which components make up the dish*. |
| Managed Resources (MR) | Prepared components | The individual parts of the dish. |
| Provider | Kitchen capability | How the real components actually get made. |
| Reconciliation | Chefs checking, re-checking, and perfecting the dish | Desired state continuously matched to reality. |
| Crossplane engine | The restaurant's staff / the kitchen process | The thing that composes and reconciles. |
| Developer | Customer | Requests the composite environment. |

## Conversational form

Dialogue turns technical relationships into conversation. Instead of narrating
*"the developer creates an XR,"* the characters speak:

> **Customer:** Hi Chef — I would like one application environment.
>
> **Chef:** Certainly. I'll use the recipe associated with that order.

The response exposes a new responsibility (the Chef consults the recipe) the
same way a Composition defines how an XR is built.

## Breaking the fourth wall

Occasionally a character may acknowledge the technical reality it represents.
This is an **optional** technique, used sparingly, to re-anchor the listener when
the metaphor risks becoming so entertaining they forget the mapping:

> **Chef:** Hello Developer—ahum, I mean *Customer*. What can I serve you today?

Use it only when a re-anchor is genuinely needed; overuse destroys immersion.

## Traits of a defensible metaphor

- **Complete enough** — covers the participating entities and their relationships.
- **Isomorphic** — adds no serious contradiction to the model.
- **Navigable** — a listener can map back from story to model.
- **Playful but honest** — entertaining in service of understanding, never at its cost.

If the metaphor and the model ever disagree, **the metaphor changes**.
