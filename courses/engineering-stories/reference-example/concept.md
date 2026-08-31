# Concept — What Is True?

The most important rule of this course: **understand the model first, and
transform it deliberately.** Fiction is allowed, but the *facts* underneath it
are not. So we begin, before any metaphor, with the technical truth.

This file captures the Crossplane concepts that the restaurant story must
represent. It deliberately contains **no restaurant imagery** — that comes
later, in `metaphor.md`.

## The plain-language model

A developer wants an application environment without hand-assembling cloud
resources one by one.

1. The platform exposes a set of **composite resource types** — higher-level
   "slots" that a developer can request. Each type is declared by an
   **XRD** (CompositeResourceDefinition).
2. The developer submits a **claim** (XRC) for one of those composite resources.
   This creates an **XR** (Composite Resource) — an instance of the type.
3. The XR is matched to a **Composition** — a template that says which concrete
   resources compose the composite one (e.g. networking, compute, storage).
4. The **Composition** generates **Managed Resources** (MRs) — the individual
   cloud objects that actually get created.
5. Those Managed Resources are realized by **Providers** — the capabilities
   that talk to a specific cloud or service. Providers create the real, external
   infrastructure.
6. **Reconciliation** continuously compares the desired state (from the
   Compositions and XRs) with the observed state (from providers), and
   converges them — building, fixing, and maintaining until reality matches the
   request, and keeping it matched afterwards.

## The entities and their responsibilities

| Entity | Abbreviation | Responsibility |
| --- | --- | --- |
| Developer | — | Expresses a need: "I want an application environment." |
| CompositeResourceDefinition | XRD | Declares the *type*: what can be requested. |
| Claim | XRC | The developer's request for a concrete composite resource. |
| Composite Resource | XR | The concrete instance, tied to a claim and a composition. |
| Composition | — | The *recipe/template*: which resources compose the composite. |
| Managed Resource | MR | One concrete cloud object governed by the platform. |
| Provider | — | The capability that realizes a managed resource in the real world. |
| Crossplane | — | The engine that composes, watches, and reconciles. |

## The relationships

```
Developer
    └─ submits → Claim (XRC)
                     └─ creates → Composite Resource (XR)
                                     └─ matched to → Composition (recipe)
                                                         └─ generates → Managed Resources (MR)
                                                                           └─ realized by → Provider
```

## Events and state transitions

To write *sound*, we also need events — moments that can make a sound:

- **Claim submitted** — a new XR is created.
- **Composition selected** — the recipe for that XR is chosen.
- **Managed resource created** — the composition generates concrete resources.
- **Provider operation** — capabilities build the real infrastructure.
- **Reconciliation pass** — the engine compares desired vs observed.
- **Successful reconciliation** — desired and observed states match.
- **Reconciliation failure** — observed state drifts or a resource cannot be built.

## Key facts the story must never contradict

- The developer asks for a *composite* environment, not the individual pieces.
- The XRD defines *what can be requested*; the Composition defines *how it is
  built*. Type and recipe are separate concerns.
- A Composition generates many Managed Resources ("composes" several into one).
- Providers are responsible for the *real* objects in the external cloud.
- Reconciliation is continuous — the platform keeps reality matched to the
  desired state over time, not just at creation.
- The developer does **not** talk directly to providers; everything happens
  through the composite abstraction.

Everything in the following files is an *explanation* of this model. If a
metaphor would contradict any line above, the metaphor must change — not the model.
