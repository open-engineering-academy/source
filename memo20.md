Memo: Modelplane as an Advanced Crossplane Case Study

Status

Research memo for Open Engineering Academy

Purpose

Investigate whether Modelplane, or similar Crossplane-based AI control-plane projects, should be incorporated into the Open Engineering Academy (OEA) Crossplane learning path.

Conclusion

Modelplane is a strong candidate for an advanced OEA Crossplane lab and case study.

It demonstrates Crossplane at a significantly higher abstraction level than traditional infrastructure-provisioning examples. Rather than exposing individual infrastructure resources to users, Modelplane provides declarative APIs for AI inference workloads and uses Crossplane compositions and composition functions to reconcile those declarations into the infrastructure required to run them.

The recommended educational approach is:

Teach Crossplane first; use Modelplane to demonstrate what becomes possible when Crossplane is used to build a domain-specific control plane.

Modelplane should therefore be treated as a case study rather than as a foundational dependency of the Crossplane curriculum.

⸻

1. Modelplane

Modelplane is an open-source AI inference control plane built using Crossplane.

Its purpose is to provide a declarative interface for deploying and operating AI inference workloads across heterogeneous infrastructure, including GPU clusters, clouds, neoclouds and on-premises environments.

The important architectural idea is that the consumer does not need to describe the underlying infrastructure.

Instead, the consumer declares the desired AI capability.

Conceptually:

User
  │
  │ declarative intent
  ▼
ModelDeployment
  │
  ▼
Modelplane Control Plane
  │
  ├── inference engine
  ├── GPU infrastructure
  ├── Kubernetes resources
  ├── networking
  └── supporting services
        │
        ▼
   Running inference service

This provides a concrete demonstration of Crossplane’s ability to create domain-specific control planes.

Reference:

* Crossplane Blog — Building Modelplane
    https://blog.crossplane.io/building-modelplane/

⸻

2. Why Modelplane matters for OEA

The Open Engineering Academy should not teach Crossplane merely as a Kubernetes infrastructure provisioning mechanism.

A more fundamental lesson is:

Crossplane allows engineers to turn domain concepts into declarative APIs and then build control planes that continuously reconcile those APIs with reality.

Modelplane makes this idea tangible.

Instead of:

"I need a GPU VM."

or:

"I need a Kubernetes deployment running vLLM."

the consumer can reason in terms of:

"I need this model served as an inference capability."

The implementation details become part of the control plane.

This is precisely the abstraction shift that makes Crossplane interesting for Open Engineering.

⸻

3. From infrastructure APIs to domain APIs

Traditional infrastructure automation often exposes infrastructure primitives:

VM
Network
Disk
Kubernetes Cluster
GPU
Load Balancer

A Crossplane-based control plane can expose a higher-level API:

Database
Application Environment
Inference Cluster
Model Deployment
Model Service

The progression can be represented as:

Infrastructure
      │
      ▼
Platform
      │
      ▼
Domain capability
      │
      ▼
Declarative API
      │
      ▼
Control Plane

Modelplane is an example of the last three layers being applied to AI inference.

⸻

4. Modelplane and Crossplane concepts

Modelplane provides useful examples of several core Crossplane concepts.

Crossplane concept	Modelplane application
XRD	Domain-specific API definitions
XR	Desired AI workload
Composition	Mapping desired workload to infrastructure
Composition Functions	Dynamic composition and orchestration
Providers	Access to underlying infrastructure
Reconciliation	Continuous convergence toward desired state
Declarative API	AI workload specification
Control plane	Model inference management

This makes Modelplane particularly suitable after students have learned the basic Crossplane mechanics.

⸻

5. Modelplane’s API-design lesson

One of the most valuable educational aspects of Modelplane is not its implementation but its API evolution.

The Modelplane authors describe how they initially designed abstractions around topology and engine-specific behavior and subsequently discovered through worked examples that the abstraction was too tightly coupled.

The API was then redesigned around a more flexible model.

This illustrates an important OEA principle:

The definition should be tested against real use cases before the implementation is optimized.

A useful Academy exercise would therefore not simply ask students to deploy Modelplane.

Students should first examine its domain model and ask:

1. What does the user actually want?
2. Which concepts belong in the public API?
3. Which details should remain implementation details?
4. Which properties should be declarative?
5. Which decisions should be made by the control plane?
6. Can the same API accommodate different infrastructure implementations?

This turns Modelplane into an API-design exercise as well as a Crossplane exercise.

⸻

6. Modelplane as an OEA laboratory

Modelplane fits particularly well with the OEA seven-phase learning approach.

Phase 1 — Explore

Understand the problem of deploying AI inference across heterogeneous infrastructure.

Questions:

* Why is GPU infrastructure difficult to abstract?
* Why should application developers care about GPU topology?
* What changes when inference infrastructure becomes heterogeneous?

Phase 2 — Explain

Explain the control-plane model:

Intent
  ↓
Declarative API
  ↓
Reconciliation
  ↓
Infrastructure
  ↓
Capability

Phase 3 — Model

Design a simplified inference API.

For example:

apiVersion: example.oe.academy/v1alpha1
kind: ModelDeployment
spec:
  model: qwen
  replicas: 1
  serving:
    protocol: openai

The objective is to decide what belongs in the API before implementing it.

Phase 4 — Compose

Create a Crossplane Composition that translates the model deployment into infrastructure.

For example:

ModelDeployment
      │
      ├── Inference runtime
      ├── GPU workload
      ├── Service
      └── Network endpoint

Phase 5 — Implement

Implement the Composition and, where appropriate, Composition Functions.

Students should experience the distinction between:

Definition

and:

Implementation

Phase 6 — Observe

Inspect reconciliation.

Students should be able to answer:

* What did the user declare?
* What resources did Crossplane create?
* What changed when the desired state changed?
* What happens when infrastructure becomes unavailable?
* How does the control plane converge again?

Phase 7 — Extend

Extend the control plane.

Possible exercises:

* Add another inference engine.
* Add GPU selection.
* Add replicas.
* Add another infrastructure provider.
* Add an OpenAI-compatible endpoint.
* Introduce policy constraints.
* Introduce observability.

⸻

7. Modelplane and the OEA learning philosophy

Modelplane supports an important distinction between:

Learning a technology

and:

Learning what the technology makes possible.

The Academy should teach the latter.

Students should not leave the laboratory thinking:

“I learned Modelplane.”

They should leave thinking:

“I learned how Crossplane can be used to create a declarative API for an entire domain.”

Modelplane is evidence of that capability.

⸻

8. Connection to Element-Oriented Engineering

Modelplane also provides a useful bridge to the broader Open Engineering approach.

A complex capability can be decomposed into elements:

Model Deployment
      │
      ├── Model
      ├── Runtime
      ├── Compute
      ├── Storage
      ├── Networking
      └── Observability

Composition then turns those elements into a working capability.

Conceptually:

Definition
     ↓
Elements
     ↓
Composition
     ↓
Implementation
     ↓
Capability

This is closely aligned with the OEA objective of teaching engineers to reason about systems in terms of reusable, composable elements rather than monolithic implementations.

⸻

9. Modelplane versus “alike”

The Academy should avoid making Modelplane the only example.

The educational concept should be:

Building domain-specific control planes with Crossplane.

Modelplane is the primary AI-inference example.

Other domain-specific control planes can subsequently demonstrate the same pattern:

Crossplane
   │
   ├── Infrastructure Control Plane
   ├── Application Platform
   ├── Database Platform
   ├── AI Inference Control Plane
   └── Open Engineering Control Plane

This prevents the curriculum from becoming tied to a single project’s API or implementation.

⸻

10. Recommended position in the OEA curriculum

Modelplane should appear after the Crossplane fundamentals.

Recommended progression:

Crossplane Fundamentals
        │
        ├── Kubernetes resources
        ├── Providers
        ├── XRDs
        ├── XRs
        ├── Compositions
        └── Composition Functions
                │
                ▼
        Domain-specific APIs
                │
                ▼
        Modelplane Case Study
                │
                ▼
        Build an AI Control Plane

It should not be introduced before students understand the basic Crossplane reconciliation model.

⸻

11. Suggested OEA lab

Lab title

Building an AI Control Plane with Crossplane

Starting question

How can we expose AI inference as a declarative platform capability without exposing the underlying GPU infrastructure to every consumer?

Learning outcome

Students learn to:

* identify a domain capability;
* design a declarative API for that capability;
* define an XRD;
* create an XR;
* compose infrastructure;
* use Composition Functions;
* observe reconciliation;
* evolve an API based on real use cases;
* distinguish domain abstractions from implementation details.

Final challenge

Students build a simplified Modelplane-like control plane:

ModelDeployment
       │
       ▼
 Crossplane
       │
       ├── Model runtime
       ├── Compute
       ├── Service
       └── Endpoint
       │
       ▼
 OpenAI-compatible inference API

The implementation does not need to reproduce Modelplane.

The educational objective is to reproduce the control-plane pattern.

⸻

12. Relationship with the OEA seven-phase methodology

Modelplane reinforces the decision to use the seven-phase learning method primarily within OEA labs.

The phases can remain visible through a LikeC4-style lab model:

Explore
   ↓
Explain
   ↓
Model
   ↓
Compose
   ↓
Implement
   ↓
Observe
   ↓
Extend

The resulting architecture can be visualized alongside the learning process.

This creates two complementary views:

Learning view
─────────────
Explore → Explain → Model → Compose → Implement → Observe → Extend
Engineering view
────────────────
Definition → Composition → Reconciliation → Implementation → Capability

The two views reinforce each other without requiring every OEA course to reproduce the full seven-phase treatment.

⸻

13. Key OEA principle

Modelplane suggests a concise principle that can be incorporated into the Academy’s Crossplane material:

Crossplane becomes most powerful when we stop modelling infrastructure and start modelling capabilities.

This should be presented as an architectural principle rather than as a claim that every Crossplane project should operate at the highest possible abstraction level.

The correct abstraction depends on the consumer, domain and operational requirements.

⸻

14. Recommended research and references

Primary

Crossplane Blog — Building Modelplane

https://blog.crossplane.io/building-modelplane/

The primary source for the Modelplane architecture, design decisions, Crossplane implementation and API evolution.

Modelplane

Modelplane GitHub repository

https://github.com/modelplaneai/modelplane

Useful for studying the actual implementation, API definitions, examples and project evolution.

Crossplane

Crossplane documentation

https://docs.crossplane.io/

Primary reference for:

* XRDs
* XRs
* Compositions
* Composition Functions
* Providers
* Reconciliation
* Crossplane v2 architecture

Crossplane GitHub

https://github.com/crossplane/crossplane

Useful for studying the implementation and evolution of Crossplane itself.

⸻

15. Proposed OEA classification

Open Engineering Academy
└── Platform Engineering
    └── Crossplane
        ├── Fundamentals
        ├── Declarative APIs
        ├── Composition
        ├── Composition Functions
        ├── Domain-specific Control Planes
        │   └── Modelplane
        └── Advanced Lab
            └── Build an AI Control Plane

Classification

Technology: Crossplane / Modelplane
Domain: Platform Engineering / AI Infrastructure
Level: Advanced
Learning mode: Case study + laboratory
Primary concept: Domain-specific declarative control planes
Secondary concepts: API design, composition, reconciliation, abstraction, AI infrastructure
OEA relevance: High

⸻

16. Final recommendation

Include Modelplane in the Open Engineering Academy as an advanced Crossplane case study.

Do not make Modelplane itself the learning objective.

Instead, use it to demonstrate the larger engineering pattern:

Domain problem
      ↓
Domain model
      ↓
Declarative API
      ↓
Crossplane composition
      ↓
Control plane
      ↓
Infrastructure
      ↓
Capability

This gives OEA students a concrete example of the transition from learning Crossplane to using Crossplane as an engineering tool for designing new control planes.

That transition is the real educational value of Modelplane.
