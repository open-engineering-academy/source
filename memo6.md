# Memo 6: Agentic Software Engineering Conventions for Open Engineering Academy Labs

Status

Proposal

Purpose

Establish a standard Open Engineering way of learning software engineering with AI agents, while keeping Open Engineering Academy courses concise and approachable.

The proposed convention introduces a seven-phase Agentic Learning Loop for substantial Open Engineering Academy Labs:

Predict → Delegate → Observe → Compare → Generalize → Validate → Internalize

The convention should not be applied to every lesson, explanation, example, demonstration, or simple exercise.

Instead:

Courses teach. Labs train engineering judgement.

This distinction allows Open Engineering Academy to benefit from agentic software engineering without making normal course material unnecessarily verbose.

⸻

## 1. Motivation

Large language models and coding agents increasingly demonstrate effective software-engineering behaviours such as:

* exploring repositories before making changes;
* locating existing conventions and abstractions;
* decomposing problems;
* forming and testing hypotheses;
* making focused changes;
* compiling and testing incrementally;
* interpreting failures;
* correcting implementations;
* inspecting resulting changes;
* verifying acceptance criteria.

The educational opportunity is larger than simply teaching students how to ask an AI to write code.

Open Engineering should use coding agents as observable engineering collaborators.

Students should learn to examine how an agent approaches a problem, compare that approach with their own reasoning, identify useful patterns, validate those patterns, and eventually internalize them.

The goal is therefore not:

Learn to let AI engineer software.

It is:

Learn software engineering by predicting, observing, comparing, validating, and internalizing effective engineering behaviour.

⸻

2. Core Principle

Open Engineering Academy should adopt the following principle:

Agentic learning is experiential learning, not the default presentation format for course material.

The seven-phase learning method should therefore primarily apply to Labs.

Normal instructional material should remain optimized for clarity and conciseness.

⸻

3. Academy Content Model

Open Engineering Academy should distinguish at least the following forms of instructional content.

Lesson

A Lesson explains concepts, technologies, principles, or techniques.

Examples:

* Rust ownership
* Python interfaces
* Kubernetes Pods
* Crossplane compositions
* PyO3 bindings
* SQL persistence

Lessons do not require the Agentic Learning Loop.

⸻

Example / Demonstration

An Example or Demonstration shows how something works.

For example:

let last_run: Option<DateTime<Utc>> = None;

An explanation can immediately accompany the example.

There is no educational benefit in artificially introducing seven phases around such material.

Examples and demonstrations therefore do not require the Agentic Learning Loop.

⸻

Exercise

An Exercise provides small, usually guided practice.

Examples include:

* modify a configuration value;
* add one field to a structure;
* execute a command;
* inspect Kubernetes resources;
* fix a deliberately simple compilation error.

Exercises do not automatically require the Agentic Learning Loop.

They may use individual elements of it when useful.

⸻

Lab

A Lab presents a meaningful engineering problem requiring investigation, judgement, implementation, debugging, architecture, verification, or some combination thereof.

Labs are the primary place where Open Engineering Academy applies the Agentic Learning Loop.

A Lab should normally require the learner to perform the complete seven-phase process.

⸻

4. The Open Engineering Agentic Learning Loop

The standard Lab protocol consists of seven phases:

1. Predict
2. Delegate
3. Observe
4. Compare
5. Generalize
6. Validate
7. Internalize

These phases describe the learning process rather than prescribing a particular LLM, coding agent, IDE, programming language, or technology.

⸻

5. Phase 1 — Predict

Before observing the agent’s solution, the learner investigates the problem and records their own expected approach.

The learner should consider questions such as:

* What is the problem?
* What do I think is causing it?
* Which files or components would I investigate?
* Which existing abstractions might be relevant?
* What implementation approach would I take?
* What could go wrong?
* How would I verify the result?

A Prediction does not need to be correct.

Its purpose is to make the learner’s current engineering model explicit.

This phase is particularly important because observing an agent’s solution first creates hindsight bias.

After seeing a successful solution, it becomes easy to believe:

“That is approximately what I would have done.”

The Predict phase provides evidence of what the learner actually thought beforehand.

Convention

Predict before Delegate.

For Labs intended to develop engineering judgement, the learner should not inspect the agent’s solution before completing their Prediction.

⸻

6. Phase 2 — Delegate

The same engineering objective is delegated to a suitable coding agent.

The objective should describe the desired outcome and relevant constraints without supplying the learner’s proposed solution.

For example:

Add persistent lifecycle state to Hello, Pico! while preserving the existing public interface and ensuring the implementation is covered by automated tests.

The learner’s Prediction should normally remain hidden from the agent.

This allows two independent approaches to emerge.

The agent is not being asked to confirm the learner’s thinking.

It is being used as an independent engineering collaborator.

⸻

7. Phase 3 — Observe

The learner observes the agent’s engineering trajectory.

The focus should not be limited to the final generated code.

Relevant observations include:

* files inspected;
* repository searches;
* documentation consulted;
* assumptions made;
* hypotheses formed;
* existing patterns discovered;
* implementation decisions;
* tools invoked;
* tests selected;
* failures encountered;
* interpretation of failures;
* corrections performed;
* verification performed;
* final diff or resulting system state.

The important educational object is therefore:

the engineering trajectory, not merely the generated solution.

⸻

8. Phase 4 — Compare

The learner compares their Prediction with the observed agent trajectory.

There are four equally legitimate outcomes:

* the human approach was better;
* the agent approach was better;
* both approaches were approximately equivalent;
* neither approach was satisfactory.

The agent must never be treated as an oracle.

The purpose is critical comparison.

Questions may include:

* What did the agent investigate that I did not?
* What did I consider that the agent missed?
* Which assumptions differed?
* Which approach produced less unnecessary change?
* Which approach was easier to verify?
* Did the agent follow existing repository conventions?
* Did either approach optimize for passing tests rather than solving the underlying problem?
* Which decisions appear reusable elsewhere?

⸻

9. Phase 5 — Generalize

The learner extracts candidate engineering principles from the comparison.

For example:

Inspect transformations at system boundaries before modifying the domain model.

Or:

Search for an existing repository convention before introducing a new abstraction.

Or:

Reproduce a failure before attempting to fix it.

These are candidate patterns, not automatically Open Engineering conventions.

A behaviour should not become a convention simply because an AI agent used it successfully once.

⸻

10. Phase 6 — Validate

The candidate principle is tested against another problem.

The second problem should be sufficiently different that the learner cannot simply reproduce the original implementation.

The purpose is to determine whether the extracted principle is genuinely reusable.

Validation may show that a candidate principle:

* generalizes well;
* applies only under certain conditions;
* requires refinement;
* is not actually useful.

This prevents accidental behaviour from being promoted to engineering doctrine.

⸻

11. Phase 7 — Internalize

The learner applies the acquired engineering knowledge independently.

Ideally, the final challenge requires the learner to solve a related problem without relying on the agent’s implementation.

The objective is not memorization.

The learner should increasingly recognize and apply useful engineering patterns naturally.

The complete progression is therefore:

Problem
   │
   ▼
Predict
   │
   ▼
Delegate
   │
   ▼
Observe
   │
   ▼
Compare
   │
   ▼
Generalize
   │
   ▼
Validate
   │
   ▼
Internalize
   │
   └──────────► Next engineering problem

⸻

12. Keep the Protocol Lightweight

Standardizing the seven phases does not mean every phase requires a long chapter.

The convention standardizes semantics, not verbosity.

A small Lab might contain only:

## Predict
Write down your expected solution and verification strategy.
## Delegate
Give the supplied objective to your coding agent without showing it your solution.
## Observe
Record the important investigation and implementation decisions.
## Compare
Identify the important differences between both approaches.
## Generalize
Extract one potentially reusable engineering principle.
## Validate
Apply that principle to the supplied variation.
## Internalize
Complete the final challenge independently.

A sophisticated architecture or debugging Lab may devote substantially more material to the same phases.

Both comply with the convention.

⸻

13. Recommended Academy Structure

Academy courses should remain free to organize instructional material naturally.

A typical course might look like:

Course
│
├── Lesson 1
├── Lesson 2
├── Example
├── Exercise
│
├── Lesson 3
├── Lesson 4
│
├── Lab
│   ├── Predict
│   ├── Delegate
│   ├── Observe
│   ├── Compare
│   ├── Generalize
│   ├── Validate
│   └── Internalize
│
├── Lesson 5
├── Demonstration
│
└── Lab
    ├── Predict
    ├── Delegate
    ├── Observe
    ├── Compare
    ├── Generalize
    ├── Validate
    └── Internalize

This creates a useful rhythm:

Learn → See → Exercise → Lab → Reflect

The course teaches established knowledge.

The Labs periodically require the learner to integrate that knowledge into actual engineering behaviour.

⸻

14. Example: Hello, Pico!

Consider an Open Engineering Academy course teaching Rust.

Lessons may explain:

* structs;
* ownership;
* Option<T>;
* serialization;
* timestamps;
* testing.

These lessons remain conventional and concise.

The course could subsequently introduce:

Lab — Make Hello, Pico! Stateful

The Lab then uses the Agentic Learning Loop.

Predict

The learner determines how they would represent Pico state, where state should live, which files require modification, and how the implementation should be tested.

Delegate

The same objective is independently supplied to the coding agent.

Observe

The learner records how the agent explores the repository, interprets existing structures, modifies the implementation, compiles it, tests it, and corrects failures.

Compare

The learner compares both approaches.

Perhaps the agent discovers an existing serialization convention.

Perhaps the learner identifies stronger boundary validation.

The preferred result may therefore be a hybrid of both approaches.

Generalize

The learner might derive:

Search for existing repository conventions before introducing a new abstraction.

Validate

The course supplies another implementation problem in which the learner must determine whether that principle applies.

Internalize

The learner completes a final variation independently.

The Lab therefore teaches considerably more than Rust syntax.

It develops engineering judgement.

⸻

15. Evidence

Open Engineering should encourage Labs to produce lightweight evidence of the learning process.

For example:

experiment:
  objective: "Implement persistent Pico state"
prediction:
  hypothesis: "State belongs in PicoState"
  expected_files:
    - src/lib.rs
  verification:
    - cargo test --workspace
observation:
  inspected:
    - Cargo.toml
    - src/lib.rs
    - tests/
  actions:
    - search
    - modify
    - test
    - inspect-diff
comparison:
  preferred_approach: hybrid
  findings:
    - "Agent identified an existing serialization convention."
    - "Human proposed stronger boundary validation."
pattern:
  candidate: inspect-existing-conventions-before-introducing-abstractions
validation:
  result: confirmed
internalization:
  completed_independently: true

The exact schema should be defined separately and may evolve.

The important principle is that learning outcomes can be supported by evidence rather than inferred solely from completion of the generated implementation.

⸻

16. Engineering Pattern Corpus

Repeated Labs create another opportunity.

Candidate patterns extracted during Generalize and confirmed during Validate can gradually contribute to an Open Engineering engineering-pattern corpus.

Possible categories include:

patterns/
├── investigation/
├── architecture/
├── implementation/
├── debugging/
├── testing/
├── verification/
├── security/
└── operations/

Examples might eventually include:

* reproduce-before-changing;
* search-before-assuming;
* inspect-existing-conventions-first;
* inspect-boundaries-before-domain-changes;
* smallest-change-first;
* focused-tests-before-full-suite;
* verify-behaviour-not-only-test-success;
* inspect-the-final-diff.

Patterns should require evidence across multiple problems before being promoted into normative Open Engineering conventions.

This establishes an important distinction:

Observation
     │
     ▼
Candidate Pattern
     │
     ▼
Repeated Validation
     │
     ▼
Engineering Pattern
     │
     ▼
Possible Convention

Open Engineering should therefore avoid declaring something a “best practice” merely because a model produced it.

⸻

17. Humans and Agents Share Engineering Conventions

The longer-term objective should be broader than Academy education.

The same engineering conventions that teach humans can also guide Open Engineering agents.

Conceptually:

             Open Engineering
                    │
          Engineering Conventions
               ┌────┴────┐
               │         │
               ▼         ▼
             Human      Agent
               │         │
               └────┬────┘
                    ▼
                Execution
                    │
                    ▼
                 Evidence
                    │
                    ▼
                 Compare
                    │
                    ▼
                 Patterns
                    │
                    ▼
               Conventions
                    │
                    └────────► Future execution

This supports a broader Open Engineering principle:

Humans and agents can operate from shared engineering conventions, produce comparable evidence, and improve engineering practice through observed outcomes.

The Academy is the natural place to teach this behaviour.

⸻

18. Proposed Repository

Create a repository under Open Engineering Conventions:

open-engineering-conventions/
└── agentic-software-engineering-conventions

Recommended repository name:

agentic-software-engineering-conventions

“Agentic Software Engineering” is preferred over “Agent Software Engineering” because the convention concerns software engineering performed in collaboration with agents rather than engineering the agents themselves.

⸻

19. Suggested Repository Structure

An initial repository could contain:

agentic-software-engineering-conventions/
├── README.md
│
├── specification/
│   ├── way-of-work.md
│   ├── labs.md
│   ├── phases.md
│   ├── evidence.md
│   └── assessment.md
│
├── schemas/
│   ├── lab.schema.yaml
│   ├── prediction.schema.yaml
│   ├── observation.schema.yaml
│   ├── comparison.schema.yaml
│   └── pattern.schema.yaml
│
├── templates/
│   ├── lab.md
│   ├── prediction.md
│   ├── observation.md
│   ├── comparison.md
│   └── pattern.md
│
├── patterns/
│   ├── investigation/
│   ├── architecture/
│   ├── implementation/
│   ├── debugging/
│   ├── testing/
│   └── verification/
│
└── examples/
    └── hello-pico/

The first version should remain intentionally small.

The repository should standardize the learning protocol before attempting to build a large catalogue of patterns.

⸻

20. Machine-Readable Convention

Where practical, the Academy should be able to declare that a Lab follows the convention.

For example:

learning:
  convention:
    id: agentic-software-engineering
    version: "1"
  type: lab
  phases:
    - predict
    - delegate
    - observe
    - compare
    - generalize
    - validate
    - internalize

This enables future Open Engineering tooling to recognize Labs and potentially:

* generate Lab scaffolding;
* validate required phases;
* capture learning evidence;
* integrate coding agents;
* compare predictions and observations;
* catalogue candidate patterns;
* assess completion;
* visualize engineering trajectories.

The convention should therefore be designed for both human readability and machine interpretation.

⸻

21. Agent Independence

For meaningful comparison, the learner’s Prediction should normally not be included in the prompt supplied to the agent.

The two approaches should be sufficiently independent to reveal meaningful differences.

The default should therefore be:

Human
  │
  └── Prediction ───────────┐
                           │
Problem                    ▼
  │                     Compare
  └── Agent Execution ─────┘

rather than:

Human Prediction
       │
       ▼
Agent implements human plan
       │
       ▼
Compare

The latter can still be useful for implementation work, but it provides substantially less educational information about alternative engineering approaches.

⸻

22. Model Independence

The convention must not depend on a particular AI provider or coding agent.

Labs should be executable with suitable tools including:

* local large language models;
* cloud-hosted large language models;
* coding agents;
* IDE-integrated agents;
* command-line agents;
* future Open Engineering agents.

The learning protocol concerns engineering behaviour, not model branding.

This also makes it possible to compare different agents against the same Lab in the future.

⸻

23. Assessment

Academy assessment should not primarily reward whether the agent generated working code.

A successful Lab should demonstrate that the learner can:

1. formulate an independent engineering hypothesis;
2. define a verification strategy;
3. critically observe an agent’s approach;
4. identify meaningful differences;
5. distinguish useful behaviour from accidental behaviour;
6. derive a candidate engineering principle;
7. test that principle elsewhere;
8. eventually apply the acquired knowledge independently.

This prevents Academy Labs from becoming exercises in merely operating coding agents.

The learner, not the agent, remains the subject being educated.

⸻

24. Scope

The convention should initially target software-engineering Labs.

Applicable subjects include:

* programming;
* debugging;
* testing;
* architecture;
* infrastructure as code;
* Kubernetes;
* Crossplane;
* CI/CD;
* security engineering;
* integration;
* observability;
* performance engineering;
* documentation engineering.

The underlying learning model may eventually prove useful beyond software engineering, but that should not unnecessarily broaden the initial convention.

⸻

25. Adoption by Open Engineering Academy

Open Engineering Academy should adopt the convention incrementally.

Existing courses should not be rewritten so that every section follows seven phases.

Instead:

New courses

Authors should identify meaningful integration points where a Lab can consolidate preceding lessons.

Existing courses

Existing substantial hands-on assignments can gradually be classified as Labs and migrated to the convention when those courses are next updated.

Small exercises

Leave them small.

Do not turn a five-minute exercise into a seven-section Lab merely for structural consistency.

Labs

Use the complete Agentic Learning Loop when the learning objective genuinely concerns engineering judgement.

This keeps migration inexpensive and avoids unnecessary course expansion.

⸻

26. Design Constraint: Avoid Pedagogical Ceremony

The convention must not become ceremony for its own sake.

A seven-phase Lab is valuable only when the learner has meaningful decisions to make and meaningful agent behaviour to compare.

Therefore:

Do not create a Lab when an Exercise is sufficient.

And:

Do not expand a phase merely to satisfy formatting expectations.

A good Lab may have a two-sentence Predict phase and a substantial Compare phase.

Another may require extensive Prediction but only a short Validation.

The seven phases establish the learning lifecycle, not equal-sized documentation sections.

⸻

27. Open Engineering Way of Work

This convention establishes a recognizable Open Engineering approach to learning engineering with AI:

We do not merely ask an agent for the answer.

We first determine what we think.

We allow an agent to investigate independently.

We observe what it actually does.

We compare both approaches critically.

We extract potentially reusable engineering knowledge.

We validate that knowledge against another problem.

We practice until that knowledge becomes our own.

In compact form:

Predict → Delegate → Observe → Compare → Generalize → Validate → Internalize

This should become the standard experiential learning protocol for substantial Open Engineering Academy Labs.

⸻

28. Decision

Create agentic-software-engineering-conventions under Open Engineering Conventions.

Define the seven-phase Agentic Learning Loop as the default protocol for substantial Open Engineering Academy Labs.

Do not require the protocol for:

* Lessons;
* explanations;
* reference material;
* examples;
* demonstrations;
* ordinary small Exercises.

Open Engineering Academy should distinguish Exercises from Labs, with Labs representing substantial engineering experiences intended to develop engineering judgement.

The Academy should progressively adopt the convention as courses are created or revised.

⸻

29. Guiding Principles

The implementation should preserve the following principles:

1. Courses teach; Labs train engineering judgement.
2. Predict before Delegate.
3. Observe the engineering trajectory, not merely the generated code.
4. The agent is a collaborator, not an oracle.
5. Human and agent approaches are independently valuable evidence.
6. Generalize patterns only after critical comparison.
7. Validate before promoting a pattern.
8. Internalization, not delegation, is the educational objective.
9. Standardize semantics, not verbosity.
10. Do not create a Lab where a simple Exercise is sufficient.
11. Keep the convention model- and tool-independent.
12. Make evidence machine-readable where this adds value.
13. Allow accumulated evidence to improve future Open Engineering conventions.

The resulting feedback loop is:

Human Engineering
        │
        ▼
Prediction
        │
        ├──────────────┐
        │              ▼
        │        Agent Engineering
        │              │
        └──────┬───────┘
               ▼
            Compare
               │
               ▼
           Generalize
               │
               ▼
            Validate
               │
               ▼
          Internalize
               │
               ▼
     Better Human Engineering
               │
               └──────────────►

This is the intended Open Engineering outcome: AI should not reduce the amount of engineering we learn. It should increase the rate at which we can learn engineering.
