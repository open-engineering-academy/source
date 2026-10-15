# Memo 23: Refactor the Pico Course Around Capsules

* Target: Open Engineering Academy  
* Type: Curriculum and architecture proposal  
* Status: Proposed  
* Date: 2026-10-15  

## 1. Summary

Refactor the Open Engineering Academy course on Picos to teach capsule-first development. A Pico should be introduced as a minimal runtime and composition of small, explicit, independently testable capabilities rather than as an application that requires a large collection of framework-specific dependencies from the start.

The course should teach learners to define a capsule contract, implement and test one capsule, compose it into a minimal Pico, validate the composition, run it, and add capabilities incrementally.

This is a proposed curriculum direction. It does not assert that the existing Pico implementation already supports every capability or mechanism described below. The relevant contracts, Composer behaviour, runtime responsibilities, and integration points must be validated against the current Open Engineering repositories before implementation.

## 2. Motivation

A Pico can accumulate complexity when its core implementation directly depends on several programming frameworks, databases, message brokers, agent platforms, and deployment systems. Requiring learners to install and understand all of these technologies at the beginning makes the course harder to follow and creates unnecessary coupling.

Capsules provide a way to make capabilities explicit and composable. The intended benefits are:

* Keep the Pico core small.
* Define stable interfaces between a capability and its consumers.
* Keep implementation-specific dependencies inside the relevant capsule or execution environment.
* Make optional capabilities genuinely optional.
* Test capsules independently before composing them.
* Validate compatibility and dependency requirements during composition.
* Allow implementations to evolve without unnecessarily changing the Pico’s public contract.
* Teach one capability at a time, building toward a complete Pico.

Capsules do not automatically eliminate dependency complexity. The architecture must define and enforce interface contracts, dependency boundaries, version compatibility, and runtime requirements.

## 3. Architectural principle

Adopt the following learning principle:

A Pico is composed from explicit capabilities. A capsule defines and implements a capability behind a contract; the Pico composes the capabilities it needs.

Use the existing Open Engineering separation of definitions and implementations:

* Open Engineering Capsules: owns capsule definitions, contracts, metadata, lifecycle conventions, dependency declarations, and composition rules.
* Open Engineering Capsule: provides concrete capsule implementations.
* Open Engineering Picos: defines and implements the Pico composition and its minimal core.
* Open Engineering Academy: teaches learners to define, implement, compose, validate, run, and operate Picos.

These are proposed responsibility boundaries. Confirm repository names, current ownership, and existing APIs before introducing or duplicating concepts.

### 3.1 Conceptual composition

A Pico may be composed from a minimal core and optional capabilities such as:

* Runtime and lifecycle support.
* Persistence or memory.
* Event and messaging transport.
* External tool or protocol adapters.
* AI or inference.
* Bot interfaces.
* Observability and operational interfaces.

These are examples, not a required list. A basic Pico should not need to install every technology.

### 3.2 Contract before implementation

A capsule definition should specify, as appropriate:

* Identity and version.
* Capability and purpose.
* Inputs and outputs.
* Public interfaces and events.
* Configuration and secrets requirements.
* Dependencies and capability requirements.
* Lifecycle and execution expectations.
* Compatibility constraints.
* Health, diagnostics, and test expectations.
* Security permissions and resource requirements.

The exact schema belongs in the relevant definitions repository and should be agreed before the course depends on it. Avoid inventing a second, course-specific capsule format.

## 4. Proposed course progression

The Pico course should use the following modules. Each module should have a clear learning objective, a practical exercise, observable evidence of completion, and a short reflection.

### Module 1 — Understand a Pico

Teach

* What a Pico is and what responsibilities belong in its core.
* The difference between a capability, a capsule definition, a capsule implementation, and a composed Pico.
* Why direct, framework-specific coupling can make systems difficult to test and evolve.

Exercise

* Inspect a minimal Pico definition and identify its required versus optional capabilities.

Evidence

* A short architecture diagram and a minimal Pico definition.

### Module 2 — Define a capsule

Teach

* Capsule metadata and contract boundaries.
* Inputs, outputs, configuration, dependencies, versions, and lifecycle.
* The distinction between a contract and a particular implementation.

Exercise

* Define a small, technology-independent capability using the canonical capsule definition format.

Evidence

* A valid capsule definition and contract tests or validation rules.

### Module 3 — Implement and test a capsule

Teach

* Implement a capsule behind its contract.
* Keep third-party dependencies local to the implementation or its execution environment where feasible.
* Unit and contract testing, error handling, and diagnostics.

Exercise

* Implement one small capability, such as a greeting or status capability, without introducing a database, message broker, AI framework, or bot platform.

Evidence

* An independently testable implementation, repeatable tests, and documented dependency requirements.

### Module 4 — Compose a Pico

Teach

* Declarative composition of capsule capabilities.
* Dependency resolution, interface binding, version compatibility, and validation.
* Clear failures for missing capabilities or incompatible contracts.

Exercise

* Compose the capsule from Module 3 into a minimal Pico and validate the result.

Evidence

* A reproducible composition definition and a successful validation report.

### Module 5 — Run and inspect the Pico

Teach

* The boundary between composition and execution.
* Runtime responsibilities, configuration, lifecycle, logging, health, and failure handling.
* How the intended Open Engineering runtime and Wrangler fit into the current architecture, where applicable.

Exercise

* Run the composed Pico, invoke its capability, and inspect its logs and health information.

Evidence

* A repeatable run procedure and captured test results.

### Module 6 — Extend and operate the Pico

Teach

* Add an optional capability without redesigning the core.
* Operate and observe the Pico through the relevant Open Engineering Operations interfaces.
* Distinguish capsule functionality from deployment and operational tooling.

Exercise

* Add one optional capability, such as persistence, an event adapter, a tool integration, or a bot interface. Choose only one for the first extension.

Evidence

* A working extension, tests, an updated composition, and operational evidence.

## 5. Dependency-management rules to teach

The course should make these principles explicit:

1. Minimal core: Keep the Pico core responsible for composition and the agreed runtime boundary, not every application capability.
2. Optional by default: Databases, brokers, AI frameworks, and bot platforms are not baseline requirements unless the Pico’s stated purpose requires them.
3. Explicit dependencies: Declare required capabilities and implementation/runtime requirements; do not rely on undocumented transitive dependencies.
4. Contract-based integration: Connect capabilities through documented interfaces, events, or protocols.
5. Independent testing: Test a capsule against its contract before integrating it into a Pico.
6. Compatibility checks: Validate capsule and contract versions during composition.
7. Reproducibility: Record the composition and resolve implementation versions reproducibly.
8. Secure configuration: Keep secrets out of source control and grant each capsule only the permissions it needs.
9. Graceful failure: Report missing capabilities and incompatible versions clearly; do not silently fall back to unsafe or unexpected implementations.
10. Observable operation: Provide useful health, diagnostics, and logs without forcing every capsule to adopt the same internal technology stack.

Do not introduce a general-purpose dependency-injection framework merely to implement these principles. Use the smallest mechanism compatible with the existing Open Engineering architecture.

## 6. Reuse existing ecosystem capabilities

Treat the following as possible implementations or integrations, not mandatory Pico dependencies:
```
Capability	Candidate technology or ecosystem	Course guidance
Application logic or AI	Python and suitable AI libraries	Add only when required by the use case.
Native performance	Rust and PyO3, where appropriate	Keep language bridging behind a clear capsule boundary.
Local persistence	Celld / SQLite, if supported by the current design	Add as a persistence capability rather than a universal dependency.
Tool integration	Composio or another supported adapter	Keep external tools behind explicit interfaces and permissions.
Messaging	EMQX or another supported event transport	Make transport replaceable and optional.
Bot interaction	Mausbot or another supported bot integration	Teach as an extension after the minimal Pico works.
Operations	Open Engineering Operations	Use operational interfaces to inspect and manage running Picos.
Infrastructure composition	Crossplane, where appropriate	Teach infrastructure provisioning separately from application-level capsule composition.
```
Before using a candidate in course instructions, verify its current role, compatibility, maintenance state, licensing, and fit with the existing implementation.

## 7. Relationship to Crossplane and declarative engineering

The course should reinforce the distinction between composing application capabilities and provisioning infrastructure.

Crossplane’s Composite Resource Definitions (XRDs) define custom API schemas, while Compositions describe how resources are assembled into a larger solution. This is a useful educational analogy for definitions and composition, but a Pico capsule is not automatically a Crossplane resource, and Crossplane should not become a prerequisite for the first capsule exercise.

Teach the concepts in this order:

1. Define the desired capability.
2. Implement and test it.
3. Compose the capability into a Pico.
4. Validate and execute the Pico.
5. Provision infrastructure or introduce platform integrations only when the exercise needs them.

This keeps the beginner path focused while preserving a route toward Kubernetes, Crossplane, and broader Open Engineering orchestration.

## 8. Lab methodology and assessment

Apply the Academy’s standard lab approach to practical exercises without making every explanatory section of the course verbose. Each lab should state:

* Goal: What the learner will build.
* Starting point: Repository, prerequisites, and known-good state.
* Steps: A short, ordered implementation path.
* Validation: Commands or checks that demonstrate success.
* Outcome: The definition, implementation, composition, or runtime artefact produced.
* Reflection: What the learner learned about contracts, coupling, or dependency boundaries.

Where LikeC4 is already available in the Academy workflow, use it to visualize the lab’s relevant components, interfaces, and composition. Keep diagrams proportional to the exercise; the first capsule lab should remain small.

Assessment should prioritize demonstrated behaviour over technology choice. A learner succeeds when the capsule conforms to its contract, tests pass, the Pico composition validates, the capability runs, and dependencies are explicit.

## 9. Migration plan for the existing course

Refactor incrementally rather than rewriting all course material at once.

1. Inventory: Review the existing Pico course and identify framework-specific prerequisites, duplicated explanations, and required integrations.
2. Verify the canonical model: Inspect the current capsule definitions, implementations, Pico repository, Composer, and runtime interfaces. Record existing conventions before proposing schema changes.
3. Establish the minimum path: Define the smallest supported capsule and Pico composition that can be tested and executed.
4. Create the first lab: Implement one simple capsule end to end. Use this to test the teaching sequence and dependency boundaries.
5. Reclassify existing content: Mark each current topic as core, optional extension, advanced integration, or infrastructure/operations.
6. Move optional integrations later: Keep persistence, messaging, AI, bots, and external tool integrations in extension modules unless needed for the core learning outcome.
7. Update diagrams and assessment: Align course diagrams, prerequisites, exercises, and completion criteria with the verified architecture.
8. Pilot and revise: Have a learner follow the course from a clean environment. Measure setup time, failed prerequisites, clarity, and repeatability before finalizing the refactor.

Do not change production interfaces or introduce new capsule schemas solely to match the proposed teaching sequence. If the current architecture cannot support a proposed exercise, document the gap and decide whether it belongs in this Academy memo or in a separate implementation memo for the responsible repository.

## 10. Acceptance criteria

The course refactor is ready for review when:

* The initial learning path does not require unrelated optional platforms or frameworks.
* A learner can define a capsule using the canonical format.
* The learner can test the capsule independently.
* A minimal Pico can be composed and validated using the existing supported mechanisms.
* The resulting Pico can be run using documented instructions.
* Required and optional dependencies are clearly distinguished.
* Adding an optional capability does not require rewriting the minimal Pico core.
* Tests and validation steps provide repeatable evidence of success.
* Security, configuration, version compatibility, and failure behaviour are addressed at an appropriate level.
* Links to the relevant Open Engineering repositories and documentation are accurate and maintained.

## 11. Decision requested

Approve capsule-first development as the organizing principle for the Open Engineering Academy Pico course, subject to verification against the existing capsule and Pico implementations.

The first implementation milestone should be a single end-to-end lab: define one capsule, implement it, test it, compose it into a minimal Pico, run it, and document the evidence. Use that lab to validate both the architecture and the curriculum before expanding the course.

## 12. References

### Open Engineering

* Open Engineering Academy: https://github.com/open-engineering-academy
* Open Engineering Picos: https://github.com/open-engineering-picos
* Open Engineering Operations: https://github.com/open-engineering-operations

Verify the current canonical repositories for Open Engineering Capsules and Open Engineering Capsule before adding their URLs. Do not infer repository URLs from naming conventions.

### Crossplane

* Composite Resources: https://docs.crossplane.io/latest/composition/composite-resources/
* Compositions: https://docs.crossplane.io/latest/composition/compositions/
* Composition overview: https://docs.crossplane.io/latest/composition/

These references support the declarative composition analogy and are not specifications for the Pico capsule contract.

### Kubernetes

* Kubernetes documentation: https://kubernetes.io/docs/home/

Use the official documentation when a later module needs Kubernetes concepts, deployment, configuration, or runtime operations. Keep these prerequisites out of the first capsule lab unless necessary.

⸻

Guiding principle: Teach the capability first, the capsule contract second, composition third, and infrastructure-specific implementation only when the learner needs it.
