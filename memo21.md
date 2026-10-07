# Memo 21: Open Engineering Operations Course

Status: Proposed  
Target: Open Engineering Academy  
Related project: Open Engineering Operations  
Implementation platform: Budibase  

## 1. Purpose

Create an Open Engineering Academy course that teaches learners how to operate an Open Engineering ecosystem through an Open Engineering Operations environment.

The course uses Open Engineering Operations as its practical target and Budibase as the implementation technology for the human-facing operations console.

The course should demonstrate how operators can observe, understand and operate the runtime state of Picos through dashboards, telemetry, events and controlled operational actions.

## 2. Core idea

A Pico is an operational building block of the Open Engineering ecosystem.

Open Engineering Operations provides the operational envelope around these Picos:
```
                    Open Engineering Operations
                              │
                    ┌─────────┴─────────┐
                    │   Operations UI   │
                    │     Budibase      │
                    └─────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
          Observe          Diagnose        Operate
              │               │               │
              └───────────────┼───────────────┘
                              │
                         Pico ecosystem
                              │
       ┌──────────┬───────────┼───────────┬───────────┐
       │          │           │           │           │
    Python     Rust/PyO3     Celld      Composio     EMQX
     Pico        Pico        Pico        Pico        Pico
```
The important architectural distinction is:

Budibase is the operator interface; Open Engineering Operations is the operational system; Picos remain the systems being operated.

Budibase should therefore not become the source of truth for Pico definitions or implementations.

3. Academy learning objective

After completing the course, a learner should be able to:

* understand the operational role of a Pico;
* identify what information an operator needs about a Pico;
* expose Pico health and telemetry to an operations environment;
* build dashboards for ecosystem and Pico health;
* inspect events and operational history;
* diagnose degraded or unavailable Picos;
* perform controlled operational actions;
* understand the relationship between telemetry, events and operational state;
* build an operational interface using Budibase;
* document the resulting operational architecture using Open Engineering conventions.

4. Course structure

The course can follow the Open Engineering Academy seven-phase learning method.

Phase 1 — Discover

Understand the Pico ecosystem and the problem of operating distributed software components.

Questions:

* What is a Pico?
* What does an operator need to know?
* What does “healthy” mean for a Pico?
* Which information belongs to the Pico and which belongs to Operations?

Phase 2 — Model

Define an operational model for Picos.

A Pico operational model may include:

pico:
  identity:
  type:
  version:
  status:
  health:
  capabilities:
  telemetry:
  events:
  operations:

The course should distinguish between:

* desired state;
* observed state;
* health;
* capabilities;
* telemetry;
* events;
* available operations.

Phase 3 — Connect

Connect the operational environment to the Pico ecosystem.

The learner establishes the interfaces through which Open Engineering Operations can retrieve information and, where appropriate, request actions.

The course should emphasize explicit interfaces rather than direct coupling between the Budibase UI and individual Pico implementations.

Phase 4 — Observe

Build the first Open Engineering Operations dashboard.

Example overview:

Open Engineering Operations
Ecosystem Health
─────────────────────────────────
Picos             5
Healthy           4
Degraded          1
Unavailable       0
Recent Events
─────────────────────────────────
12:41  Celld      health recovered
12:37  EMQX       message rate increased
12:31  Composio   tool invocation completed

The learner learns to move from raw telemetry to useful operational information.

Phase 5 — Diagnose

Use the Operations environment to investigate problems.

A Pico detail view could contain:

Python Pico
Status:       Running
Health:       Healthy
Version:      0.x
Uptime:       ...
Capabilities: ...
Telemetry
────────────────────────
Requests
Latency
Errors
Resource usage
Recent Events
────────────────────────
...
Operational Actions
────────────────────────
Restart
Refresh
Inspect

The emphasis should be on evidence-based diagnosis, rather than merely displaying status indicators.

Phase 6 — Operate

Introduce controlled operational actions.

Examples might include:

* refresh state;
* restart a component;
* enable/disable a capability;
* trigger a diagnostic operation;
* acknowledge an incident;
* initiate a controlled job.

Operations should be explicit, auditable and permission-aware.

The course should teach the principle:

Observe first, operate second.

Phase 7 — Improve

Use operational observations to improve the ecosystem.

Learners should identify:

* missing telemetry;
* unclear health signals;
* recurring failures;
* missing operational actions;
* dashboard improvements;
* automation opportunities.

This closes the loop between operating the ecosystem and engineering the ecosystem.

5. Budibase role

Budibase is used as the practical implementation platform for the Operations user interface.

Potential Budibase screens include:

Dashboard
Picos
Pico Detail
Events
Incidents
Operations
Jobs
Audit

Budibase is particularly useful for demonstrating how an operational interface can be assembled quickly without requiring the learner to implement an entire frontend application.

The Academy should nevertheless make the architectural boundary explicit:

             Open Engineering Operations
                       │
              operational API/model
                       │
                 ┌─────┴─────┐
                 │           │
             Budibase      Other UI
                 │
             Operator

This allows Budibase to be replaced later without redesigning the operational model.

6. Pico operations

The course should use real Open Engineering Picos as examples where possible.

Initial examples include:

Pico	Operational concern
Python Pico	Application and AI-facing runtime
Rust/PyO3 Pico	Native computational capabilities
Celld Pico	Persistent SQLite-based memory
Composio Pico	Tools, MCP and agent capabilities
EMQX Pico	Messaging and event transport

The exact implementation should remain independent of the Academy course where possible. The course teaches how to operate Picos, rather than teaching the internal implementation of each Pico.

7. LikeC4 documentation

The course should use the Open Engineering architecture documentation approach to visualize the operational system.

For example:

Operator
   │
   ▼
Operations Console
   │
   ▼
Open Engineering Operations
   │
   ├── Python Pico
   ├── Rust/PyO3 Pico
   ├── Celld Pico
   ├── Composio Pico
   └── EMQX Pico

Sequence diagrams can illustrate operational scenarios such as:

Operator → Operations → Pico: request health
Pico → Operations: health result
Operations → Operator: dashboard update

and:

Operator → Operations: restart Pico
Operations → Pico: restart request
Pico → Operations: operation accepted
Pico → Operations: operation completed
Operations → Audit: record operation
Operations → Operator: result

This makes operational behavior part of the architecture documentation rather than merely describing the UI.

8. Course lab

The central Academy lab should progressively build a small but functional Operations Console.

Starting point

A running Pico ecosystem with observable runtime information.

Outcome

A Budibase-based Operations Console capable of:

1. listing Picos;
2. showing Pico status;
3. showing health information;
4. displaying telemetry;
5. displaying recent events;
6. displaying Pico capabilities;
7. invoking at least one controlled operational action;
8. recording operational activity.

The learner should finish with something that feels like a real operations cockpit rather than a collection of isolated exercises.

9. Architectural principles

The course should establish the following Open Engineering principles.

Operations is an architectural concern

Operating software is not an afterthought. Observability, health, events and operational actions should be considered when designing a Pico.

Separate observation from control

Reading the state of a Pico and changing its state are different operations and should have different interfaces and permissions.

Preserve the source of truth

Budibase should present and operate on information; it should not silently become the canonical definition of the ecosystem.

Prefer explicit contracts

Operations should communicate with Picos through explicit operational interfaces rather than depending on implementation details.

Make operations observable

Operational actions should themselves generate events or audit records where appropriate.

Design for replacement

The operational model should not depend unnecessarily on Budibase. Budibase is an implementation of the Operations user interface.

10. Relationship to Open Engineering Operations

The Academy course should link directly to the Open Engineering Operations repository:

https://github.com/open-engineering-operations

Open Engineering Operations is the implementation project.

Open Engineering Academy is the learning environment.

The relationship can therefore be expressed as:

Open Engineering Academy
        │
        │ teaches
        ▼
Open Engineering Operations
        │
        │ operates
        ▼
Pico Ecosystem

This allows the course and the implementation project to evolve together without making the Academy itself the operational platform.

11. Suggested course title

Operating Picos with Open Engineering Operations

Alternative subtitle:

Build dashboards, observe telemetry, diagnose health and operate an Open Engineering Pico ecosystem.

12. Expected outcome for Open Engineering Academy

This course provides an important missing perspective in the Academy.

Other courses can teach learners how to design and build Open Engineering components. This course teaches them how to run and operate those components once they exist.

The resulting learning path becomes:

Learn
  ↓
Model
  ↓
Build
  ↓
Connect
  ↓
Observe
  ↓
Operate
  ↓
Improve

Open Engineering Operations therefore becomes both a real Open Engineering project and a practical teaching environment for the operational side of Element-Oriented Engineering.

References

* Open Engineering Operations — GitHub: https://github.com/open-engineering-operations
* Budibase — documentation: https://docs.budibase.com/
* Budibase — official website: https://budibase.com/
* Open Engineering Academy — GitHub organization: https://github.com/open-engineering-academy
* LikeC4 — architecture-as-code documentation: https://likec4.dev/
