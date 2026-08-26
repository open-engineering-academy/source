# Memo 7: LikeC4 Visualization Methodology for Open Engineering Academy Labs

Status

Proposal

Purpose

Extend the Open Engineering Academy Lab methodology so that the seven-phase Agentic Learning Loop is visually documented using LikeC4.

The seven phases remain:

Predict → Delegate → Observe → Compare → Generalize → Validate → Internalize

LikeC4 becomes the visual modeling layer that shows how the learner’s understanding of the system, the agent’s investigation, the resulting implementation, and the extracted engineering knowledge evolve across those phases.

The intended result is:

An Open Engineering Academy Lab should leave behind not only working software and machine-readable evidence, but also a visual record of how engineering understanding evolved.

This memo extends the proposed agentic-software-engineering-conventions approach. It does not replace the seven-phase methodology.

⸻

1. Decision

Open Engineering Academy Labs should support LikeC4-based visualization of their engineering process and outcomes.

The implementation should distinguish three related concerns:

Open Engineering Lab
│
├── Learning
│   └── Seven-phase Agentic Learning Loop
│
├── Evidence
│   └── Machine-readable records of predictions,
│       observations, comparisons, patterns,
│       validation and outcomes
│
└── Model
    └── LikeC4 visualization of the evolving
        engineering understanding

These concerns should remain separate but connected.

The seven phases describe what the learner does.

Evidence records what happened.

LikeC4 visualizes what was understood, discovered, changed, compared and learned.

⸻

2. Important Design Principle

LikeC4 must not merely draw the seven phases as seven boxes.

For example, this is insufficient:

Predict
   ↓
Delegate
   ↓
Observe
   ↓
Compare
   ↓
Generalize
   ↓
Validate
   ↓
Internalize

The seven-phase workflow is already understood.

The more valuable visualization is the system and engineering knowledge observed through those phases.

Therefore:

The seven phases are views over an evolving engineering model.

LikeC4 provides those views.

⸻

3. One Lab, One Evolving Engineering Model

Each substantial Lab should conceptually maintain one evolving model.

That model may represent:

* systems;
* containers;
* components;
* services;
* interfaces;
* APIs;
* runtime infrastructure;
* dependencies;
* boundaries;
* data flows;
* implementation areas;
* files or modules where useful;
* observations;
* hypotheses;
* changes;
* tests;
* evidence;
* engineering patterns.

The model should evolve as the Lab progresses.

Conceptually:

                    LAB MODEL
                        │
         ┌──────────────┼──────────────┐
         │              │              │
         ▼              ▼              ▼
    Architecture   Investigation    Evidence
         │              │              │
         └──────────────┼──────────────┘
                        │
                        ▼
                 Phase-specific
                  LikeC4 views

The learner therefore sees not merely the final architecture but how understanding of that architecture changed during engineering.

⸻

4. The Seven LikeC4 Views

A Lab following the convention should be capable of exposing the following logical views:

lab-predict
lab-delegate
lab-observe
lab-compare
lab-generalize
lab-validate
lab-internalize

The exact LikeC4 syntax and view implementation may evolve independently of this convention.

The semantics of the seven views should remain stable.

⸻

5. Predict View

Objective

Visualize what the learner believes is relevant before the agent performs its investigation.

The Predict view may show:

* components the learner believes are involved;
* suspected failure locations;
* expected change areas;
* expected dependencies;
* proposed data flows;
* proposed implementation boundaries;
* assumptions;
* areas explicitly believed not to require changes.

For example:

Pico
 │
 ├── PicoState        ← expected change
 │
 ├── API
 │
 └── Persistence      ← suspected dependency

This view is valuable because it captures the learner’s mental model before hindsight changes it.

The LikeC4 Predict view should correspond to the machine-readable prediction evidence.

⸻

6. Delegate View

Objective

Show the engineering context supplied to the coding agent.

The Delegate view should clarify the agent’s scope.

It may show:

* systems exposed to the agent;
* repository or workspace boundaries;
* target components;
* known constraints;
* required interfaces;
* acceptance criteria;
* systems that must remain unchanged.

This view should answer:

What engineering environment and objective did the agent actually receive?

It should not incorporate discoveries made later during Observe.

This preserves the distinction between supplied context and discovered context.

⸻

7. Observe View

Objective

Visualize the agent’s actual engineering trajectory.

The Observe view may identify:

* components inspected;
* modules searched;
* interfaces discovered;
* files modified;
* dependencies followed;
* boundaries investigated;
* tests executed;
* failures encountered;
* new relationships discovered;
* assumptions disproved.

For example, the learner may predict:

Pico
 │
 └── PicoState

but the agent may discover:

Pico
 │
 ├── API
 │    │
 │    └── Serialization Boundary
 │
 └── PicoState

The Observe view makes that difference explicit.

The educational object is not just the resulting code.

It is the engineering trajectory through the system.

⸻

8. Compare View

Objective

Visually compare the learner’s predicted engineering approach with the agent’s observed approach.

This is potentially the most important LikeC4 view in the Lab.

The Compare view should make differences obvious.

For example:

             HUMAN                     AGENT
              Pico                      Pico
               │                         │
               ▼                         ▼
          PicoState                     API
               │                         │
               ▼                         ▼
         Persistence              Serialization
                                            │
                                            ▼
                                       PicoState
                  └──────────┬──────────┘
                             ▼
                      FINAL APPROACH
                             API
                              │
                              ▼
                        Serialization
                              │
                              ▼
                          PicoState
                              │
                              ▼
                         Persistence

This tells a richer story than a prose statement such as:

The human approached the problem through the domain model while the agent approached it through the system boundary.

LikeC4 should make such differences directly visible.

⸻

9. Compare Outcomes

The visualization must not imply that the agent approach is automatically better.

The Compare phase should support all four legitimate outcomes:

human-preferred
agent-preferred
hybrid-preferred
neither-satisfactory

Where appropriate, LikeC4 styles or tags may distinguish these outcomes.

For example:

Human discovery
Agent discovery
Shared discovery
Final retained element
Rejected approach

The exact visual styling should be provided by the Open Engineering LikeC4 theme rather than hard-coded by individual Labs.

⸻

10. Generalize View

Objective

Connect the specific engineering observation to a reusable engineering pattern.

Suppose the agent inspected an API serialization boundary before changing the internal domain model.

The learner might derive:

Inspect system boundaries before modifying a domain representation.

The LikeC4 Generalize view could associate the pattern with the relevant relationship:

API
 │
 │  «inspect-boundary-first»
 ▼
Serialization
 │
 ▼
Domain Model

The pattern should not become a formal convention simply because it appears in one Lab.

It remains a candidate pattern until validated.

⸻

11. Validate View

Objective

Visualize whether the candidate pattern applies to another engineering problem.

The Validate view should show:

* the new context;
* where the pattern was applied;
* whether it succeeded;
* where it failed;
* whether its scope required refinement.

For example:

Candidate Pattern
       │
       ▼
Problem A ── confirmed
       │
Problem B ── confirmed
       │
Problem C ── conditional
       │
       ▼
Refined Pattern

This is important because Open Engineering should avoid converting one successful behavior into unsupported doctrine.

⸻

12. Internalize View

Objective

Visualize the final engineering understanding after the learner independently applies the acquired knowledge.

This view should represent:

* the final system architecture;
* the final implementation relationships;
* retained engineering patterns;
* resolved uncertainties;
* relevant evidence;
* the independently completed outcome.

The Internalize view therefore acts as both:

1. the final Lab model; and
2. evidence of how the learner’s understanding matured.

⸻

13. Temporal Model of Learning

Taken together, the seven LikeC4 views form a temporal record.

Conceptually:

t0             t1              t2              t3
Predict ───► Observe ───► Compare ───► Internalize
  │             │              │              │
  ▼             ▼              ▼              ▼
Model₀         Model₁         Model₂         Model₃

The complete Lab may offer a phase selector such as:

Predict
Delegate
Observe
Compare
Generalize
Validate
Internalize

Selecting a phase reveals the corresponding state of engineering understanding.

This makes the Lab visually replayable.

⸻

14. Visual Replay of Learning

A future Open Engineering Academy interface should be able to render the Lab as an interactive sequence.

The learner could move through:

[ Predict ]
     ↓
What I thought mattered
[ Delegate ]
     ↓
What the agent was told
[ Observe ]
     ↓
What the agent actually investigated
[ Compare ]
     ↓
Where our approaches differed
[ Generalize ]
     ↓
What reusable principle emerged
[ Validate ]
     ↓
Whether that principle survived another problem
[ Internalize ]
     ↓
What I can now do independently

This effectively creates a visual replay of engineering learning.

⸻

15. Relationship to Existing Open Engineering LikeC4 Direction

Open Engineering already uses LikeC4 as a preferred architecture-modeling approach.

Academy Labs should reuse that same modeling infrastructure rather than introducing a separate diagramming technology.

The Academy should therefore inherit:

* LikeC4 tooling;
* Open Engineering LikeC4 conventions;
* Open Engineering visual theming;
* rendering infrastructure;
* future 2D visualization;
* future 3D visualization where useful;
* common model parsing;
* common model validation.

Lab visualization should be a specialization of the Open Engineering LikeC4 ecosystem.

It should not become an isolated Academy-specific visualization technology.

⸻

16. Recommended Lab Repository Structure

A Lab may adopt a structure such as:

lab/
├── lab.yaml
├── README.md
│
├── model/
│   ├── system.c4
│   ├── investigation.c4
│   └── views.c4
│
├── evidence/
│   ├── prediction.yaml
│   ├── delegation.yaml
│   ├── observation.yaml
│   ├── comparison.yaml
│   ├── pattern.yaml
│   ├── validation.yaml
│   └── outcome.yaml
│
├── workspace/
│   └── ...
│
└── solution/
    └── ...

The exact structure should remain adaptable.

The important separation is:

model/
evidence/
workspace/
solution/

⸻

17. Do Not Require Manual Duplication

A major implementation constraint is:

The learner should not be required to maintain the same information manually in Markdown, YAML, and LikeC4.

Doing so would introduce unnecessary ceremony.

Instead, Open Engineering tooling should increasingly derive visualizations from structured evidence wherever practical.

For example:

prediction.yaml
       │
       ▼
Lab model generator
       │
       ▼
LikeC4 Predict view

Likewise:

agent trajectory
       │
       ▼
observation.yaml
       │
       ▼
Lab model generator
       │
       ▼
LikeC4 Observe view

Human-authored LikeC4 should remain possible when architectural modeling itself is part of the learning objective.

But redundant manual transcription should not be the default.

⸻

18. Evidence as the Source of Truth

Where possible, structured evidence should remain the authoritative record of the learning process.

LikeC4 should visualize that evidence.

Conceptually:

Engineering Activity
         │
         ▼
Structured Evidence
         │
         ├─────────────► Assessment
         │
         ├─────────────► Pattern analysis
         │
         └─────────────► LikeC4 visualization

This preserves machine readability.

The visual model is extremely valuable, but it should not become the only representation of evidence.

⸻

19. LikeC4 as an Engineering Evidence View

This introduces a broader use of LikeC4 within Open Engineering.

Traditionally, architecture visualization answers:

What exists and how is it connected?

Academy Lab visualization additionally answers:

What did we believe?

What did we inspect?

What changed?

What did we discover?

Why was this implementation chosen?

What engineering principle emerged?

Where was that principle subsequently validated?

LikeC4 therefore becomes a view not only of architecture but of engineering evidence associated with architecture.

⸻

20. Suggested Model Semantics

The Lab modeling convention should support concepts such as:

System element
Component
Boundary
Dependency
Data flow
Predicted element
Observed element
Modified element
Discovered element
Validated element
Human hypothesis
Agent observation
Shared conclusion
Candidate pattern
Validated pattern
Evidence
Test
Failure
Decision
Outcome

Not all of these need to become first-class LikeC4 elements.

Some may be expressed through:

* tags;
* metadata;
* relationships;
* annotations;
* links;
* styles;
* extensions.

The implementation should prefer extending LikeC4 naturally rather than building a parallel modeling language.

⸻

21. Proposed Tags

The convention may define reusable tags such as:

#prediction
#agent-observed
#human-observed
#shared
#discovered
#modified
#tested
#failed
#validated
#candidate-pattern
#validated-pattern
#rejected

The Open Engineering LikeC4 theme can then map these tags into consistent visual semantics.

Individual Academy courses should not invent their own styling for these states.

⸻

22. Styling

LikeC4 Lab views should inherit the Open Engineering visual language.

The implementation should prioritize:

* minimalism;
* clarity;
* calm presentation;
* strong hierarchy;
* consistent semantic styling;
* avoidance of excessive visual noise.

Phase-specific differences should rely on a limited number of semantic visual treatments.

The diagrams should communicate engineering meaning rather than decorate the course.

⸻

23. 2D and 3D

The primary representation should remain 2D because it is efficient for:

* comparison;
* inspection;
* learning;
* documentation;
* code review;
* accessibility.

Where the Open Engineering LikeC4 rendering environment supports 3D, Labs may optionally provide 3D views for systems where spatial understanding adds value.

Examples may include:

* Kubernetes clusters;
* robotics systems;
* physical/digital twins;
* distributed runtime environments;
* nested Open Engineering Picos;
* IoT systems.

3D should not be mandatory for the seven-phase Lab methodology.

The model should remain independent of its rendering dimension.

⸻

24. Example: Hello, Pico!

Consider a Lab:

Make Hello, Pico! Stateful

Predict

The learner initially models:

HelloPico
   │
   ▼
PicoState
   │
   ▼
Persistence

The learner expects PicoState to require modification.

⸻

Delegate

The agent receives:

HelloPico
   │
   ├── Public API must remain stable
   │
   └── Persistent state required

⸻

Observe

The agent discovers:

HelloPico
   │
   ▼
API Boundary
   │
   ▼
Serialization
   │
   ▼
PicoState
   │
   ▼
Persistence

The serialization boundary becomes a newly discovered relevant element.

⸻

Compare

The view shows:

Learner prediction:
PicoState → Persistence
Agent investigation:
API → Serialization → PicoState → Persistence

The difference is immediately visible.

⸻

Generalize

The learner derives:

«inspect-boundary-before-domain-change»

associated with:

API → Serialization → Domain Model

⸻

Validate

A second problem involving another API/data-model boundary is supplied.

The learner checks whether the same pattern applies.

⸻

Internalize

The learner independently completes a final state-management problem and produces the final LikeC4 model.

The completed Lab now contains:

* working code;
* passing tests;
* the original prediction;
* agent trajectory;
* visual comparison;
* candidate pattern;
* validation;
* final system model.

⸻

25. Lab Artifact Model

A completed Lab should conceptually produce:

Lab
│
├── Objective
│
├── Source / implementation
│
├── Test results
│
├── Evidence
│   ├── Prediction
│   ├── Delegation
│   ├── Observation
│   ├── Comparison
│   ├── Generalization
│   ├── Validation
│   └── Internalization
│
└── LikeC4 model
    ├── Predict view
    ├── Delegate view
    ├── Observe view
    ├── Compare view
    ├── Generalize view
    ├── Validate view
    └── Internalize view

This becomes the durable output of the learning experience.

⸻

26. Link to Engineering Patterns

The Generalize and Validate phases should integrate with the proposed engineering-pattern corpus in:

agentic-software-engineering-conventions/
└── patterns/

A Lab may identify:

Candidate Pattern
       │
       ▼
Validation
       │
       ▼
Validated Lab Pattern
       │
       ▼
Evidence across multiple Labs
       │
       ▼
Open Engineering Pattern
       │
       ▼
Possible Convention

LikeC4 can visualize where such patterns apply within real architectures.

This gives patterns spatial and architectural context rather than leaving them as disconnected prose.

⸻

27. Pattern Provenance

A reusable pattern should be traceable back to the Labs that produced evidence for it.

Conceptually:

Pattern:
inspect-boundary-before-domain-change
               │
      ┌────────┼─────────┐
      ▼        ▼         ▼
    Lab A    Lab B      Lab C
      │        │         │
      └────────┼─────────┘
               ▼
        Evidence corpus

A LikeC4 pattern view may eventually expose this provenance.

This supports evidence-based Open Engineering conventions.

⸻

28. Academy UI

The Open Engineering Academy should eventually provide a standardized Lab visualization interface.

A possible structure is:

┌───────────────────────────────────────────────┐
│ LAB: Make Hello, Pico! Stateful               │
├───────────────────────────────────────────────┤
│ Predict │ Delegate │ Observe │ Compare │ ...  │
├───────────────────────────────────────────────┤
│                                               │
│                 LikeC4 View                   │
│                                               │
├───────────────────────────────────────────────┤
│ Evidence / Explanation                        │
└───────────────────────────────────────────────┘

Selecting a phase updates the LikeC4 view and associated evidence.

The interface should make comparison effortless.

⸻

29. Comparison Mode

The Academy should eventually support a dedicated Compare mode.

Possible options include:

Human
Agent
Overlay
Final

or:

Prediction
Observation
Difference
Resolution

The learner should be able to visually answer:

What did I miss?

What did the agent miss?

What did both approaches agree on?

What was retained in the final implementation?

This functionality would materially strengthen the educational value of the seven-phase methodology.

⸻

30. Architecture Drift Across a Lab

LikeC4 also makes it possible to show how architecture changes during implementation.

For example:

Before Lab
A → B
After Lab
A → Boundary → B → Persistence

The learner can therefore distinguish:

* changes in understanding;
* changes in implementation;
* changes in actual architecture.

These should not be conflated.

The LikeC4 conventions should make it possible to identify each separately.

⸻

31. Learning Model Versus Runtime Model

The Lab should not corrupt or overload the canonical runtime architecture with pedagogical metadata.

Where appropriate, distinguish:

Canonical System Model
          │
          ├── Runtime architecture views
          │
          └── Academy Lab views

The same underlying architectural elements may be reused.

Lab-specific evidence remains associated with Lab views rather than permanently polluting the canonical architecture definition.

⸻

32. Lab Model Composition

Where a course operates against an existing Open Engineering system model, the Lab should reference or compose that model rather than recreate it.

Conceptually:

Existing Pico model
        │
        ├────────────┐
        │            │
        ▼            ▼
Canonical view    Lab overlay
                     │
                     ▼
               Seven phase views

This is especially important for Open Engineering Academy courses built around common components such as:

* Pico;
* Crossplane;
* MiniKube;
* Manifold;
* Home Assistant;
* Kubernetes;
* Celld;
* PyO3.

The architectural definition should remain reusable across multiple Labs.

⸻

33. Course Verbosity

The LikeC4 methodology must not increase ordinary course verbosity.

The earlier Academy principle remains:

Courses teach. Labs train engineering judgement.

Therefore:

* Lessons do not need seven LikeC4 views.
* Examples do not need seven LikeC4 views.
* Demonstrations do not need seven LikeC4 views.
* Small Exercises do not need seven LikeC4 views.
* Substantial Labs use the seven-phase model where it adds genuine learning value.

The visual methodology is therefore scoped to Labs.

⸻

34. Progressive Adoption

The implementation should proceed incrementally.

Phase 1

Define:

* the seven LikeC4 Lab view semantics;
* minimal tags;
* expected relationship to evidence;
* one reference Lab.

Use Hello, Pico! as the reference implementation where practical.

Phase 2

Add generated LikeC4 views from structured Lab evidence.

Phase 3

Add Academy phase navigation.

Phase 4

Add Compare visualization.

Phase 5

Connect candidate and validated patterns to the engineering-pattern corpus.

Phase 6

Add historical / temporal Lab replay.

Phase 7

Optionally add 3D rendering where meaningful.

⸻

35. Repository Responsibilities

The responsibilities should remain separated across the Open Engineering ecosystem.

agentic-software-engineering-conventions

Defines:

* seven-phase Lab semantics;
* evidence requirements;
* Lab methodology;
* pattern lifecycle;
* relationship between phases and views.

Open Engineering LikeC4 conventions / modeling infrastructure

Defines:

* modeling syntax;
* model composition;
* tags;
* visual semantics;
* theme;
* rendering conventions.

Open Engineering Academy

Implements:

* Labs;
* learning flow;
* learner interaction;
* evidence capture;
* phase navigation;
* assessment.

Individual Lab repositories/content

Provide:

* objectives;
* problem context;
* canonical architecture references;
* Lab-specific evidence;
* Lab-specific LikeC4 views where required.

⸻

36. Machine-Readable Lab Declaration

A Lab may declare its visualization approach as follows:

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
visualization:
  methodology: likec4
  views:
    - lab-predict
    - lab-delegate
    - lab-observe
    - lab-compare
    - lab-generalize
    - lab-validate
    - lab-internalize
evidence:
  source: ./evidence

This should be treated as illustrative rather than a finalized schema.

⸻

37. Open Engineering Lab Principle

The combined methodology can be summarized as:

                         LAB
                         │
                         ▼
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
                         ▼
                 Engineering Outcome
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
    Working Code      Evidence         LikeC4
                                      Visual Model

All three outcomes matter.

Working code proves implementation.

Evidence records the learning trajectory.

LikeC4 makes that trajectory understandable.

⸻

38. Guiding Principles

The implementation should preserve these principles:

1. The seven phases remain the learning methodology.
2. LikeC4 is the visualization methodology.
3. Evidence remains machine-readable.
4. The seven phases are views over an evolving engineering model.
5. Do not reduce the method to a seven-box process diagram.
6. Visualize engineering understanding, not merely workflow.
7. Capture the learner’s model before agent influence.
8. Make human-versus-agent differences visible.
9. Do not assume the agent is correct.
10. Show how candidate patterns arise from real system context.
11. Validate patterns before promoting them.
12. Reuse canonical Open Engineering LikeC4 models wherever possible.
13. Avoid redundant manual documentation.
14. Generate visualization from evidence where practical.
15. Do not make ordinary Academy lessons more verbose.
16. Keep 2D as the primary representation; treat 3D as optional.
17. Separate canonical runtime architecture from Lab-specific learning overlays.
18. Make a completed Lab visually replayable where possible.

⸻

39. Final Recommendation

Adopt LikeC4 as the standard visual modeling methodology for substantial Open Engineering Academy Labs that use the seven-phase Agentic Learning Loop.

Do not treat LikeC4 merely as final architecture documentation.

Use it to visualize the evolution from:

initial human hypothesis

through:

agent investigation

through:

human-agent comparison

through:

engineering pattern discovery and validation

to:

final internalized engineering understanding.

The resulting Open Engineering Lab model becomes:

Learn through seven phases.

Record the evidence.

Visualize the evolution with LikeC4.

This creates a distinctive Open Engineering learning experience in which engineering is not only performed but made observable, comparable, evidence-backed, machine-readable, and visually understandable.
