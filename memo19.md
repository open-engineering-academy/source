# Memo 19: Creative and Engineering Skill Development in Open Engineering Academy

Status: Proposed
Audience: Open Engineering Academy
Scope: Academy learning methodology and Labs
Related: Seven-Phase Learning Method, Academy Labs, LikeC4 Learning Documentation

⸻

1. Purpose

Open Engineering Academy should teach more than the ability to reproduce a technical solution.

The Academy should help learners develop the ability to:

* understand engineering concepts;
* learn and apply engineering methods;
* practice by building real things;
* acquire relevant domain knowledge;
* make informed engineering decisions;
* experiment with alternative solutions;
* learn from feedback;
* develop engineering fluency and judgement.

This memo proposes incorporating these principles into the existing Open Engineering Academy Labs methodology.

The objective is not to introduce a second learning framework. Instead, the existing seven-phase Lab methodology should provide the structure, while the principles described here provide guidance for designing effective learning experiences within each phase.

⸻

2. Reference

The primary inspiration for this memo is Scott H. Young’s article:

How to Learn Creative Skills
Scott H. Young, 16 July 2026
https://www.scotthyoung.com/blog/2026/07/16/how-to-learn-creative-skills/

Young distinguishes between learning technical proficiency and developing creative capability.

The article identifies several important ingredients of effective skill development, including:

* methods;
* concepts;
* practice;
* knowledge;
* judgement;
* experimentation;
* feedback;
* fluency.

The Open Engineering Academy can apply these ideas to engineering education.

⸻

3. Learning Engineering Rather Than Memorising Technology

A technology-oriented course can easily become a sequence of instructions:

Install X
    ↓
Configure Y
    ↓
Run Z
    ↓
Copy the example

This can demonstrate that something works without teaching the learner how to solve the next problem.

Open Engineering Academy should instead aim for:

Understand the problem
        ↓
Understand the concepts
        ↓
Learn the method
        ↓
Apply the method
        ↓
Build something
        ↓
Observe the result
        ↓
Evaluate alternatives
        ↓
Improve the solution

The learner should leave the Lab with a reusable way of thinking, not merely a working example.

⸻

4. Methods, Concepts and Practice

Young’s distinction between methods, concepts and practice provides a useful foundation for Academy Labs.

4.1 Methods

A method describes how an experienced practitioner approaches a problem.

For example:

* how to decompose a system;
* how to define an interface;
* how to investigate a failure;
* how to model an architecture;
* how to refactor code;
* how to test a hypothesis.

Labs should make these methods explicit.

The Academy should avoid presenting expert behaviour as unexplained intuition.

Instead:

Make the method visible.

⸻

4.2 Concepts

Concepts explain why the method works.

A Lab should therefore distinguish between:

WHAT we do

and:

WHY it works

For example, a Pico Lab should not only demonstrate how to connect Python, Rust/PyO3, Celld and Composio.

It should explain the architectural concepts behind the separation of:

Python       → Face
Rust/PyO3    → Muscles
Celld        → Memory
Composio     → Hands

The learner should understand the model well enough to apply it to a different problem.

⸻

4.3 Practice

Understanding a method is insufficient.

The learner must use it.

Every Academy Lab should therefore contain a meaningful construction activity in which the learner creates or modifies something.

The preferred progression is:

Observe
  ↓
Try
  ↓
Build
  ↓
Break
  ↓
Investigate
  ↓
Improve

The learner should encounter enough friction to develop practical understanding.

⸻

5. Knowledge and Engineering Context

Engineering decisions do not occur in isolation.

A learner needs enough surrounding knowledge to understand the available solution space.

For example, a Kubernetes Lab may involve:

* Kubernetes;
* Crossplane;
* Flux;
* containers;
* networking;
* storage;
* APIs;
* controllers;
* declarative configuration.

The Lab does not need to teach every related technology in depth.

Instead, it should provide enough context for the learner to understand:

1. what problem the technology addresses;
2. what alternatives exist;
3. what assumptions the solution makes;
4. what trade-offs are involved.

This keeps the Lab focused while developing broader engineering awareness.

⸻

6. Engineering Judgement

A central goal of Open Engineering Academy should be the development of engineering judgement.

The learner should increasingly be able to answer:

“Why would I choose this approach?”

rather than only:

“How do I implement this approach?”

Labs should therefore deliberately expose decisions.

For example:

Problem
   ↓
Possible approaches
   ↓
Constraints
   ↓
Trade-offs
   ↓
Decision
   ↓
Implementation
   ↓
Observed consequences

The learner should be encouraged to record the reasoning behind important decisions.

This naturally connects Academy Labs with:

* Architecture Decision Records;
* Open Engineering Architecture;
* LikeC4 models;
* implementation repositories;
* conventions;
* rules;
* refactoring.

⸻

7. Experimentation

Creative and engineering capability grows through experimentation.

Academy Labs should therefore not always have a single predetermined path.

Where appropriate, a Lab should provide a safe space to ask:

“What happens if we do this differently?”

For example:

Baseline implementation
        ↓
Hypothesis
        ↓
Alternative implementation
        ↓
Experiment
        ↓
Observe
        ↓
Compare
        ↓
Learn

The objective is not necessarily to find a “winner”.

The objective is to understand the consequences of different engineering choices.

This is particularly valuable when teaching:

* architecture;
* performance;
* distributed systems;
* AI;
* local versus cloud execution;
* programming languages;
* modelling;
* automation;
* user interfaces.

⸻

8. Feedback

Feedback should be part of the Lab rather than an activity that occurs only at the end.

Useful feedback can come from:

* automated tests;
* linters;
* compilers;
* type systems;
* architecture validation;
* LikeC4 models;
* runtime behaviour;
* performance measurements;
* visual inspection;
* peer review;
* AI-assisted review;
* human reflection.

The Lab should make this feedback visible.

A useful cycle is:

Build
  ↓
Measure
  ↓
Inspect
  ↓
Reflect
  ↓
Change
  ↓
Build again

This transforms errors from failures into learning events.

⸻

9. Fluency

The ultimate objective is not merely completing a Lab.

It is developing enough familiarity that the learner can use the method in a new context.

A useful progression is:

I have seen it
      ↓
I understand it
      ↓
I can reproduce it
      ↓
I can modify it
      ↓
I can explain it
      ↓
I can choose when to use it
      ↓
I can apply it somewhere new

The final stages represent engineering fluency.

Academy Labs should therefore include opportunities to transfer the learned method to a slightly different problem.

⸻

10. Integration With the Seven-Phase Learning Method

The existing Seven-Phase Learning Method should remain the primary structure for Open Engineering Academy Labs.

The principles in this memo should be applied inside those phases, rather than becoming additional mandatory phases.

Each phase can explicitly consider the following questions:

Learning dimension	Question
Method	What method are we learning?
Concept	Why does it work?
Practice	What will the learner build?
Knowledge	What context is necessary?
Judgement	What decision must the learner make?
Experimentation	What can the learner vary?
Feedback	How will the learner know what happened?
Fluency	Where can the learner reuse the method?

This keeps Labs compact while making them substantially richer learning experiences.

⸻

11. The Academy Lab Learning Loop

The combined approach can be represented as:

                 ┌───────────────┐
                 │    PROBLEM    │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │   CONCEPTS    │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │    METHOD     │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │    PRACTICE   │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │  EXPERIMENT   │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │   FEEDBACK    │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │   JUDGEMENT   │
                 └───────┬───────┘
                         ↓
                 ┌───────────────┐
                 │    FLUENCY    │
                 └───────┬───────┘
                         │
                         └──────────────→ NEW PROBLEM

This loop reinforces the idea that learning is not a linear transfer of information.

It is a cycle of understanding, doing, observing and improving.

⸻

12. LikeC4 Documentation

The learning process and its outcome should be documented using the same modelling principles used elsewhere in Open Engineering.

Where appropriate, a Lab should have a LikeC4 representation showing:

Learner
   │
   ├── learns → Concept
   │
   ├── applies → Method
   │
   ├── creates → Artefact
   │
   ├── experiments → Alternative
   │
   ├── receives → Feedback
   │
   └── develops → Capability

This makes the learning architecture visible.

The LikeC4 model should remain a useful abstraction rather than becoming documentation overhead.

The principle is:

Model the learning system when the model helps the learner understand the system.

⸻

13. Example: Pico Academy Lab

Consider an Open Engineering Academy Lab introducing Picos.

A purely instructional Lab might say:

Install Python
Install Rust
Install PyO3
Create the Pico
Add Celld
Connect Composio
Run the Pico

An Open Engineering Lab should additionally ask:

Concepts

What is a Pico?

What responsibilities belong inside a Pico?

Why separate interface, computation, memory and tools?

Method

How do we decompose the capability?

How do we define the boundaries?

Practice

Build a working Pico.

Knowledge

Investigate the relevant technologies and alternatives.

Judgement

Decide where a capability belongs.

Experimentation

Replace one implementation component and observe the consequences.

Feedback

Test the Pico and inspect its behaviour.

Fluency

Apply the same decomposition method to another capability.

The learner consequently learns both:

how to build this Pico

and:

how to reason about building the next Pico.

That distinction is central to the Academy.

⸻

14. AI-Assisted Learning

These principles are especially relevant now that AI can generate substantial amounts of implementation code.

AI can make it easy to skip practice.

For example:

Learner describes problem
        ↓
AI generates solution
        ↓
Learner runs solution
        ↓
Done

This can produce an operational result without necessarily producing learning.

Open Engineering Academy should instead encourage:

Learner understands problem
        ↓
Learner forms hypothesis
        ↓
AI assists exploration
        ↓
Learner evaluates result
        ↓
Learner modifies solution
        ↓
Learner explains decision
        ↓
Learner applies method independently

AI should therefore be treated as a learning instrument, not merely a code-generation shortcut.

This is particularly important for Labs involving programming, architecture, AI, automation and infrastructure.

⸻

15. Design Principle

The following principle should guide Academy Lab design:

An Open Engineering Academy Lab should teach a reusable method, explain the concepts behind it, provide deliberate practice, expose engineering decisions, encourage experimentation, provide feedback, and leave the learner able to apply the method to a new problem.

⸻

16. Relationship to Open Engineering

This approach aligns with the broader Open Engineering philosophy.

Open Engineering does not merely produce artefacts.

It makes engineering knowledge reusable through:

* definitions;
* conventions;
* models;
* rules;
* implementations;
* documentation;
* experiments;
* stories;
* reusable components.

The Academy should apply the same principle to learning.

The learner should not merely receive an answer.

The learner should acquire a reusable engineering capability.

⸻

17. Proposed Academy Principle

The following statement can become an Open Engineering Academy learning principle:

Open Engineering Academy teaches methods, develops understanding, provides practice, encourages experimentation, and cultivates engineering judgement through real-world Labs.

Or, more compactly:

Learn the concept. Practice the method. Experiment with the implementation. Reflect on the result. Reuse the capability.

⸻

18. References

1. Scott H. Young, “How to Learn Creative Skills”, 16 July 2026.
    https://www.scotthyoung.com/blog/2026/07/16/how-to-learn-creative-skills/
2. Open Engineering Academy — Academy Labs and Seven-Phase Learning Method.
    Internal Open Engineering Academy methodology.
3. LikeC4 — Architecture-as-code modelling approach used as inspiration for documenting systems and, where useful, learning processes.
    https://likec4.dev/

⸻

19. Recommendation for Adoption

Adopt the principles in this memo as design guidance for Open Engineering Academy Labs.

Do not add these principles as additional mandatory steps to the Seven-Phase Learning Method.

Instead:

Seven Phases
     │
     ├── Methods
     ├── Concepts
     ├── Practice
     ├── Knowledge
     ├── Judgement
     ├── Experimentation
     ├── Feedback
     └── Fluency

The Seven Phases remain the structure.

These learning dimensions become the quality criteria for designing each Lab.

This keeps the Academy methodology simple enough to use while ensuring that its Labs develop genuine engineering capability rather than merely transferring technical instructions.
