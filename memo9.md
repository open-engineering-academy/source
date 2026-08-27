# Memo 9: Introduce Technical Storytelling with AI Audio in Open Engineering Academy

Status: Proposed  
Target: Open Engineering Academy  
Artifact: New Academy course/lab  
Working title: Engineering Stories — From Architecture to Audio Drama  

## 1. Purpose

Introduce a new Open Engineering Academy learning experience that teaches engineers how to transform technical concepts, software architecture, infrastructure, and engineering processes into educational audio stories produced with generative AI.

The course should teach a reusable methodology rather than being a tutorial for one particular AI product.

The initial reference implementation should use the existing Crossplane restaurant metaphor and audio drama as its canonical example.

The intended transformation is:

technical concept
    ↓
technical model
    ↓
metaphor
    ↓
characters and responsibilities
    ↓
scenes
    ↓
audio screenplay
    ↓
AI audio production
    ↓
review and iteration
    ↓
educational audio drama

The course should demonstrate that technical storytelling is not merely presentation decoration. Constructing a good metaphor requires the learner to understand responsibilities, boundaries, interactions, abstractions, and cause-and-effect within the underlying technical system.

⸻

2. Motivation

Technical education frequently starts with terminology.

A learner encounters definitions such as:

* Composite Resource Definition
* Composite Resource
* Composition
* Managed Resource
* Provider
* reconciliation

Although technically correct, terminology alone may provide little intuition about how the pieces collaborate.

A story can provide that intuition.

For example, Crossplane can be introduced through a restaurant:

Crossplane concept	Restaurant metaphor
XRD	Menu definition
XR	Customer order
Composition	Recipe
Provider	Kitchen capability
Managed Resource	Prepared component/resource
Reconciliation	Kitchen continually ensuring the order is fulfilled

The metaphor gives learners an existing mental model onto which unfamiliar concepts can be mapped.

The important Open Engineering principle is:

Understand the technical truth before simplifying it into a story.

The metaphor must explain the engineering model rather than replace it.

⸻

3. Proven Reference Experiment

This proposal is based on an actual Open Engineering experiment rather than a hypothetical workflow.

A short Crossplane explanation was transformed into a Dutch-style hoorspel: an audio drama in which narration, dialogue, actions, ambience, and sound effects together communicate the story without requiring accompanying video.

The Crossplane architecture became a restaurant.

Roles such as customer, chef, and apprentice made responsibilities explicit through dialogue.

Actions that would normally be shown visually were narrated.

Scene transitions were deliberately introduced so that the listener could understand changes in location and context.

Sound effects and ambience were included as part of the screenplay rather than treated as unrelated post-production material.

The resulting screenplay was processed using an AI audio-production platform and produced a convincing multi-character MP3 containing narration, dialogue, ambience, and sound effects.

This validates the basic workflow:

engineering knowledge
        ↓
educational metaphor
        ↓
audio screenplay
        ↓
generative audio production
        ↓
finished educational experience

The Academy implementation should capture and generalize this workflow.

⸻

4. Course Positioning

Do not position the course as:

How to use Wondercraft

Instead position it as:

How to teach engineering concepts through AI-generated audio storytelling.

AI production tools are implementation choices.

The Academy should therefore separate:

METHOD
Technical Storytelling
        │
        ├── metaphor design
        ├── character design
        ├── scene design
        ├── screenplay
        ├── narration
        ├── sound design
        └── evaluation
TOOLS
        │
        ├── Wondercraft
        ├── ElevenLabs
        ├── other audio-generation systems
        └── conventional recording/editing

The course remains useful when individual products, models, pricing plans, or capabilities change.

⸻

5. Proposed Course

Create a new course under Open Engineering Academy.

Suggested identity:

engineering-stories

Suggested title:

Engineering Stories

Suggested subtitle:

From Architecture to Audio Drama

The course should be relatively short and highly practical.

A learner should finish the course having produced an actual playable educational audio artifact.

⸻

6. Learning Objectives

After completing the course, learners should be able to:

1. Analyze a technical system before attempting to simplify it.
2. Identify the concepts and relationships that an audience must understand.
3. Design a metaphor that maps those concepts onto familiar objects and roles.
4. Recognize where a metaphor stops accurately representing the technical system.
5. Transform system responsibilities into characters and dialogue.
6. Structure an engineering explanation as a sequence of dramatic scenes.
7. Write specifically for an audio-only medium.
8. Use narration to communicate actions and context that cannot be seen.
9. Design ambience and sound effects as part of the explanation.
10. Produce a structured screenplay suitable for generative audio systems.
11. Generate a multi-character audio production using an appropriate AI tool.
12. Critically evaluate both the educational and technical accuracy of the resulting production.
13. Iterate from generated output back into the screenplay.

⸻

7. Core Principle: Technical Truth First

A significant risk of teaching through metaphor is creating a memorable but incorrect mental model.

The course must therefore establish two models.

Model A — Technical Model

Describe the real system.

For example:

XR
 │
 ▼
Composition
 │
 ├── Managed Resource
 ├── Managed Resource
 └── Managed Resource

Model B — Narrative Model

Translate that system into the story world.

Order
 │
 ▼
Recipe
 │
 ├── Meal component
 ├── Meal component
 └── Meal component

The learner must maintain an explicit mapping between the two.

This should become a required artifact:

concept.md

or:

metaphor.md

The document should record mappings such as:

| Technical concept | Story concept | Explanation |
|-------------------|---------------|-------------|
| XRD | Menu | Defines what may be ordered |
| XR | Order ticket | Requests an instance |
| Composition | Recipe | Describes how the requested resource is built |

This provides a simple mechanism for reviewing whether the story remains technically defensible.

⸻

8. Story as System Model

The course should explicitly teach that characters are not arbitrary decoration.

Characters can represent responsibilities within a system.

For example:

Developer
    ↓ places
XR / Order
Chef
    ↓ follows
Composition / Recipe
Kitchen
    ↓ operates
Provider capabilities

Dialogue then becomes a way of explaining system interactions.

For example, instead of narration stating:

The developer creates an XR.

the character might say:

“Hi Chef — I would like one application environment.”

The response can expose another responsibility:

“Certainly. I’ll use the recipe associated with that order.”

This gives technical relationships conversational form.

⸻

9. Breaking the Fourth Wall

The Crossplane experiment demonstrated another useful storytelling technique.

Characters may occasionally acknowledge their technical counterparts.

For example:

“Hello Developer—ahum, I mean Customer. What can I serve you today?”

Used sparingly, this allows the story to reinforce the mapping between metaphor and architecture without abandoning the narrative.

The Academy course should describe this as an optional technique.

It is particularly useful when a metaphor risks becoming so entertaining that the learner forgets what each character represents.

⸻

10. Writing for Audio

Audio storytelling has an important constraint:

If the listener cannot hear it, it does not exist.

A conventional screenplay might contain:

The chef places the order ticket beside the stove.

In video, the audience sees this.

In an audio drama, it must instead become something such as:

NARRATOR:
The chef tears the order ticket from the rail and places it beside the recipe.

possibly accompanied by:

[SFX: paper tearing]
[SFX: ticket placed on counter]

The course should therefore distinguish:

visual screenplay
        versus
audio screenplay

Every important action must be represented through at least one of:

* dialogue,
* narration,
* sound effect,
* ambience,
* music.

⸻

11. Scene-Oriented Screenplay

The screenplay should be explicitly divided into scenes.

Example:

SCENE 03 — THE KITCHEN
AMBIENCE:
Busy restaurant kitchen.
NARRATOR:
Meanwhile, behind the restaurant counter, our customer's
order reaches the kitchen.
SFX:
Ticket printer.
CHEF:
Apprentice! New order!
APPRENTICE:
What did they ask for, Chef?
CHEF:
One application environment.
APPRENTICE:
And how do we know how to build it?
CHEF:
We follow the recipe.

Each scene should have:

* purpose,
* location,
* participating characters,
* ambience,
* narration,
* dialogue,
* actions,
* sound effects,
* transition,
* educational outcome.

The last item is important.

Every scene should answer:

What should the learner understand after hearing this scene?

⸻

12. Narrative Arc

Technical storytelling should not simply be documentation read aloud.

The course should introduce a lightweight dramatic structure:

Introduction
     ↓
Question / problem
     ↓
Discovery
     ↓
Increasing complexity
     ↓
Challenge
     ↓
Climax
     ↓
Resolution
     ↓
Technical takeaway

For example, a Crossplane story could begin with the seemingly simple problem:

A developer wants an environment.

The audience subsequently discovers the menu, order, recipe, kitchen, ingredients/resources, and reconciliation process.

The climax should demonstrate why the abstraction matters.

The resolution then reconnects the metaphor to Crossplane.

⸻

13. Sound as Part of the Model

Sound effects should not merely decorate the story.

Where possible they should reinforce the architecture.

Examples:

Order created
→ ticket printer
Composition selected
→ recipe book opening
Resource created
→ kitchen preparation sounds
Provider operation
→ appliance / kitchen activity
Successful reconciliation
→ service bell
Failure
→ kitchen alarm or interruption

This introduces the concept of semantic sound design:

A sound represents an event or state in the technical model.

This idea may later connect naturally with other Open Engineering work involving events, messaging, visualization, voice, and interactive systems.

⸻

14. Proposed Course Structure

Module 1 — Engineering Through Stories

Introduce:

* technical storytelling,
* metaphor,
* narrative learning,
* audio drama,
* benefits and risks.

Demonstrate the finished Crossplane audio story early.

The learner should first experience the result before seeing how it was constructed.

⸻

Module 2 — Find the Technical Truth

Start from architecture and documentation.

Identify:

* actors,
* resources,
* responsibilities,
* relationships,
* events,
* state transitions.

Produce:

concept.md

⸻

Module 3 — Design the Metaphor

Translate the technical model into a familiar world.

Possible worlds include:

* restaurant,
* theatre,
* airport,
* hotel,
* factory,
* postal service,
* detective agency,
* orchestra.

Produce:

metaphor.md

Include the explicit technical-to-narrative mapping.

⸻

Module 4 — Cast the System

Turn important responsibilities into characters.

Define:

characters.md

For each character record:

Character:
Technical counterpart:
Responsibility:
Personality:
Voice:
Relationship to other characters:

⸻

Module 5 — Design the Scenes

Break the explanation into scenes.

Produce:

scenes.md

Each scene should specify:

Goal
Technical concept
Location
Characters
Action
Sound
Transition
Learning outcome

⸻

Module 6 — Write the Audio Screenplay

Transform the scene plan into an audio-first screenplay.

Produce:

screenplay.md

Teach:

* narration,
* dialogue,
* explicit roles,
* audible actions,
* pacing,
* scene transitions,
* ambience,
* sound effects,
* music cues,
* comedic timing,
* controlled fourth-wall breaks.

⸻

Module 7 — Produce with Generative AI

Introduce AI audio-production workflows.

The implementation should support more than one provider.

For example:

screenplay.md
       ↓
audio production platform
       ↓
voices
       +
narration
       +
ambience
       +
sound effects
       +
music
       ↓
audio-play.mp3

Document Wondercraft as the initially validated implementation.

Alternative tools may be documented when their capabilities satisfy the lab requirements.

Avoid designing the course around provider-specific UI steps that may quickly become obsolete.

⸻

Module 8 — Listen Like an Engineer

Generation is not completion.

Review the resulting audio for:

Technical correctness

Does the metaphor still accurately describe the system?

Educational effectiveness

Could someone unfamiliar with the technology explain the important concepts afterward?

Narrative clarity

Can the listener tell:

* who is speaking,
* where the scene occurs,
* what happened,
* why it matters?

Audio quality

Review:

* voice distinction,
* pronunciation,
* pacing,
* silence,
* ambience,
* sound levels,
* effects,
* scene transitions.

Record findings and iterate.

⸻

15. Academy Lab

The course should culminate in a practical lab.

Challenge

Turn an engineering concept into a 2–5 minute educational audio drama.

Learners should preferably select their own concept.

Suggested subjects include:

* Kubernetes,
* Crossplane,
* GitOps,
* PKI,
* TLS,
* OAuth,
* DNS,
* CI/CD,
* event-driven architecture,
* message queues,
* API gateways,
* containers,
* dependency injection.

The Crossplane restaurant should remain the reference implementation rather than the mandatory learner project.

⸻

16. Apply the Open Engineering Lab Method

The lab should follow the standard Open Engineering learning methodology.

A suitable mapping is:

OBSERVE
Understand the technical system.
        ↓
INVESTIGATE
Identify actors, responsibilities and relationships.
        ↓
DESIGN
Create the metaphor and narrative mapping.
        ↓
COMPOSE
Create characters, scenes and screenplay.
        ↓
EXECUTE
Generate the audio production.
        ↓
EVALUATE
Review technical, educational and audio quality.
        ↓
REFLECT
Document what the metaphor clarified and what it obscured.

Where Academy conventions define canonical names for these phases, use those names consistently.

⸻

17. Visualize the Lab

Where supported by Open Engineering Academy conventions, visualize the lab process using the established LikeC4-oriented documentation approach.

For example:

Technical System
       ↓
Concept Model
       ↓
Metaphor
       ↓
Characters
       ↓
Scenes
       ↓
Screenplay
       ↓
Audio Generator
       ↓
MP3
       ↓
Evaluation

The visualization should allow learners to understand both the workflow and its resulting artifacts.

⸻

18. Suggested Lab Repository Structure

Use a structure similar to:

technical-audio-story/
├── README.md
├── concept.md
├── metaphor.md
├── characters.md
├── scenes.md
├── screenplay.md
├── production.md
├── evaluation.md
├── reflection.md
└── output/
    └── audio-play.mp3

Optional:

├── diagrams/
├── prompts/
├── assets/
└── transcripts/

Generated binary audio does not necessarily need to be committed directly to Git when repository size or licensing makes that undesirable. The implementation should follow existing Open Engineering artifact conventions.

⸻

19. Screenplay as Intermediate Representation

The course should introduce an engineering interpretation of the screenplay.

The screenplay can be considered an intermediate representation between technical knowledge and a rendered educational experience.

SOURCE MODEL
Architecture
Documentation
Schemas
ADRs
Definitions
        ↓
TRANSFORMATION
Technical model
Metaphor
Narrative model
        ↓
INTERMEDIATE REPRESENTATION
screenplay.md
        ↓
RENDERERS
Wondercraft
Other AI audio systems
Human actors
Conventional audio production
        ↓
ARTIFACT
audio-play.mp3

This distinction is valuable.

The screenplay should remain useful independently of the renderer.

This is conceptually compatible with Open Engineering’s broader Composer philosophy: structured knowledge can be transformed into another representation and subsequently rendered by specialized tooling.

⸻

20. Future Composer Opportunity

Do not make automation of screenplay generation a prerequisite for the initial course.

However, design the artifacts so that a future Open Engineering Composer could potentially transform structured engineering knowledge into a first screenplay draft.

A future pipeline could resemble:

Open Engineering Definition
          +
architecture model
          +
documentation
          ↓
Technical Story Composer
          ↓
metaphor proposal
          ↓
character model
          ↓
scene model
          ↓
screenplay.md
          ↓
audio renderer
          ↓
audio artifact

Human review should remain important, particularly for metaphor accuracy and narrative quality.

⸻

21. Provider Abstraction

The course should distinguish between capabilities and products.

Required production capabilities might be described as:

capabilities:
  multi_voice: true
  narration: true
  sound_effects: true
  ambience: true
  scene_control: true
  audio_export: true

A provider can then be evaluated against those requirements.

This prevents accidental dependency on one commercial service.

Wondercraft can initially be documented as:

Validated provider used by the reference implementation.

The course documentation should mention that free tiers of commercial services may introduce limitations such as watermarks, advertisements, generation limits, or restricted exports, and that these conditions can change.

Do not hard-code current pricing into the course.

⸻

22. Evaluation Rubric

Consider scoring learner projects across five dimensions.

Dimension	Question
Technical accuracy	Does the story correctly represent the engineering concept?
Metaphor quality	Does the metaphor improve understanding without introducing serious misconceptions?
Narrative clarity	Can the listener follow the story without visual assistance?
Audio communication	Do voice, narration and sound communicate actions and context effectively?
Learning outcome	Can the listener explain the underlying technical model afterward?

Technical accuracy should carry significant weight.

A beautiful production that teaches the wrong architecture should not pass merely because it is entertaining.

⸻

23. Reference Implementation

Create a canonical example based on the Crossplane restaurant audio drama.

Suggested location:

examples/
└── crossplane-restaurant/
    ├── README.md
    ├── concept.md
    ├── metaphor.md
    ├── characters.md
    ├── scenes.md
    ├── screenplay.md
    ├── production.md
    └── evaluation.md

Where licensing and repository policy permit, provide the resulting audio artifact or a link to the published artifact.

The example should explain concepts such as:

XRD → Menu
XR → Order
Composition → Recipe
Managed Resources → Prepared components
Provider → Kitchen capability

The example should retain the playful character interactions, narration of actions, explicit role references, scene transitions, ambience, and sound effects that made the experimental production effective.

⸻

24. Reverse-Engineering Teaching Approach

An effective course opening would be to let the learner hear the finished Crossplane story first.

Then ask:

How did an architecture model become this?

Subsequent modules progressively reveal:

finished MP3
      ↑
screenplay
      ↑
scenes
      ↑
characters
      ↑
metaphor
      ↑
technical model

After reverse-engineering the reference example, learners perform the process in the forward direction for their own project.

This creates a useful learning loop:

EXPERIENCE
Hear the result
     ↓
DECONSTRUCT
Understand its construction
     ↓
CONSTRUCT
Create another one
     ↓
REFLECT
Evaluate the transformation

⸻

25. Definition of Done

The initial Academy implementation is complete when:

* a new Engineering Stories course exists;
* the course explains technical storytelling independently of any specific vendor;
* the Crossplane restaurant is included as the reference implementation;
* learners explicitly model technical truth before creating metaphors;
* metaphor mappings are documented;
* audio-first screenplay conventions are documented;
* narration, dialogue, ambience and sound effects are covered;
* scene-oriented storytelling is taught;
* at least one AI audio-production workflow is documented;
* Wondercraft is documented as the initially validated implementation;
* the lab follows the Open Engineering Academy lab methodology;
* the lab workflow is visualized where appropriate;
* learners produce a 2–5 minute educational audio artifact;
* technical accuracy is part of the evaluation;
* provider-specific implementation details are isolated from the general methodology;
* course artifacts are structured so future Composer automation remains possible.

⸻

26. Implementation Priority

Recommended priority:

Phase 1 — Capture

Preserve the successful Crossplane experiment:

concept
metaphor
characters
scenes
screenplay
production notes
result

Do this first so the practical lessons learned during the experiment are not lost.

Phase 2 — Generalize

Extract the reusable methodology from the Crossplane-specific material.

Phase 3 — Course

Create the Academy lessons and exercises.

Phase 4 — Lab

Create the learner challenge and evaluation rubric.

Phase 5 — Automate

Only after the manual methodology works reliably, investigate a Technical Story Composer or related Open Engineering automation.

⸻

27. Architectural Principle

The implementation should preserve the following separation:

             WHAT IS TRUE?
                   │
            Technical Model
                   │
                   ▼
        HOW CAN WE EXPLAIN IT?
                   │
               Metaphor
                   │
                   ▼
        HOW CAN WE EXPERIENCE IT?
                   │
                Story
                   │
                   ▼
        HOW DO WE REPRESENT IT?
                   │
              Screenplay
                   │
                   ▼
          HOW DO WE RENDER IT?
                   │
            Audio Producer
                   │
                   ▼
             Audio Artifact

Each stage should remain inspectable.

This is important because errors can then be traced back to their origin.

A technical error belongs in the model.

A misleading analogy belongs in the metaphor.

Confusing dialogue belongs in the story.

A bad pronunciation belongs in rendering.

This makes creative production compatible with an engineering workflow.

⸻

28. Decision

Implement Engineering Stories — From Architecture to Audio Drama as an Open Engineering Academy course and practical lab.

Use the successful Crossplane restaurant audio drama as the first canonical reference implementation.

Treat AI audio generation as a renderer of a structured screenplay rather than as the subject of the course.

Most importantly, establish the following principle as the foundation of the course:

We do not simplify technology by abandoning its engineering model. We understand the model first, transform it deliberately, and use story to make that understanding accessible.
