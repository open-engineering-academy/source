# Memo 10 — EMQX as the Pico Nervous System

**Project:** Open Engineering Picos  
**Domain:** Pico Agent Architecture  
**Status:** Proposal  
**Version:** 1.0  
**Date:** 2026-09-01

---

## Purpose

This memo proposes adopting **EMQX and MQTT as a candidate nervous system for Picos**.

The goal is to give Picos a standard event-driven mechanism for:

- communicating with other Picos;
- discovering available Pico capabilities;
- receiving observations and events;
- publishing state and telemetry;
- invoking capabilities on devices and services;
- coordinating distributed work;
- connecting AI agents to the physical and IoT world.

This proposal complements the existing Pico architecture rather than replacing it.

The key architectural principle is:

> **Composio gives a Pico hands. EMQX gives a Pico a nervous system.**

A Pico remains the agent. EMQX/MQTT provides the communication fabric through which the Pico can sense, communicate, coordinate and act across distributed systems.

---

# 1. The Pico Agent Model

A Pico should be understood as more than an AI model connected to a prompt.

A Pico is an identifiable, autonomous engineering agent with:

- **Identity**
- **Rulesets**
- **Memory**
- **Reasoning**
- **Mission / Intent**
- **Capabilities**
- **Skills**
- **Evidence**
- **Events**
- **Communication**
- **Execution**
- **Hands**

The architecture can therefore be visualised as:

```text
                         ┌──────────────────────┐
                         │        PICO          │
                         │                      │
                         │  Identity            │
                         │  Rulesets            │
                         │  Memory              │
                         │  Reasoning           │
                         │  Mission             │
                         │  Capabilities        │
                         │  Skills              │
                         │  Evidence            │
                         └──────────┬───────────┘
                                    │
                 ┌──────────────────┴──────────────────┐
                 │                                     │
          Composio — HANDS                  EMQX — NERVOUS SYSTEM
          MCP / Agent Tools                 MQTT / Events / A2A
                 │                                     │
                 ▼                                     ▼
        External digital world                 Distributed world
        APIs / SaaS / GitHub                   Other Picos
        Cloud services                         Devices
        Enterprise systems                     Sensors
                                                Actuators
```

This creates a useful separation of concerns.

---

# 2. Composio: Pico's Hands

The Pico architecture already proposes **Composio** as a mechanism for connecting an agent to external tools.

Composio can provide:

- MCP-based tools;
- AI agent tools;
- authentication and integration with external services;
- access to APIs and SaaS systems;
- execution of actions in external systems.

Therefore:

> **Composio is a candidate implementation of Pico's external hands.**

A Pico can reason about an action and use a Composio tool to perform it.

Examples:

```text
Pico
  │
  ├── reason
  │
  └── use hand
        │
        ▼
     Composio
        │
        ├── GitHub
        ├── Slack
        ├── Jira
        ├── Cloud API
        └── Other SaaS
```

---

# 3. EMQX: Pico's Nervous System

MQTT is fundamentally different from an ordinary tool invocation mechanism.

It provides an event-driven communication fabric.

EMQX can therefore provide the infrastructure through which a Pico:

- receives observations;
- publishes events;
- communicates with other agents;
- communicates with devices;
- discovers capabilities;
- receives telemetry;
- exposes state;
- participates in distributed workflows.

The conceptual model is:

```text
                  ┌───────────────┐
                  │     EMQX      │
                  │               │
                  │ MQTT Broker   │
                  │ Event Fabric  │
                  │ Discovery     │
                  │ Agent A2A     │
                  └───────┬───────┘
                          │
           ┌──────────────┼──────────────┐
           │              │              │
         Pico A         Pico B         Device
           │              │              │
      Architect       Detective       Sensor
```

The broker becomes the communication fabric rather than the intelligence itself.

---

# 4. Why MQTT Fits Picos

MQTT has several properties that are particularly attractive for a distributed Pico ecosystem.

## 4.1 Event-driven communication

Picos do not need to continuously poll other systems.

Instead:

```text
Event → MQTT → Pico
```

For example:

```text
kubernetes/deployment/checkout/status
```

could produce an event that wakes or informs an appropriate Pico.

---

## 4.2 Loose coupling

A Pico does not need to know the implementation details of every other participant.

Instead, it can communicate through topics and capability contracts.

```text
Pico A
   │
   │ publish
   ▼
EMQX
   │
   │ route
   ▼
Pico B
```

This supports a highly distributed architecture.

---

## 4.3 Many-to-many communication

A single event can be consumed by multiple Picos.

For example:

```text
repository/security/alert
            │
            ▼
           EMQX
        ┌────┼────┐
        │    │    │
        ▼    ▼    ▼
      Cyber  Code  Release
      Pico   Pico  Pico
```

This makes MQTT particularly suitable for collaborative Pico ecosystems.

---

# 5. Pico-to-Pico Communication

One of the most important potential applications is **Pico-to-Pico collaboration**.

A Pico should not necessarily need to know every other Pico in advance.

Instead, Picos can advertise capabilities.

For example:

```yaml
agent:
  id: pico-architecture-042
  kind: architecture-detective

capabilities:
  - kubernetes
  - crossplane
  - architecture-investigation
  - repository-analysis

protocols:
  - mqtt
  - a2a

status: online
```

Another Pico could discover this capability and delegate work.

Conceptually:

```text
Pico A
  │
  │ "I need Kubernetes architecture analysis"
  ▼
EMQX / Agent Registry
  │
  │ discover
  ▼
Pico B
  │
  │ investigate
  ▼
Evidence / Result
  │
  └──────────────► Pico A
```

This provides an infrastructure foundation for the Pico-to-Pico identity and collaboration model.

---

# 6. Agent Discovery

Agent discovery should be treated as a first-class Pico capability.

A Pico should be able to determine:

1. which agents exist;
2. which agents are currently available;
3. what capabilities they provide;
4. how they can be contacted;
5. what protocols they support;
6. what constraints apply.

A future Pico discovery contract could resemble:

```yaml
pico:
  identity:
    id: pico-architecture-042

  kind: architecture-detective

  capabilities:
    - kubernetes
    - crossplane
    - architecture-investigation

  communication:
    protocols:
      - mqtt
      - a2a

  status:
    state: online
```

The exact schema should be defined by Open Engineering rather than copied directly from an infrastructure provider.

---

# 7. Device Agent Integration

EMQ has introduced the concept of turning IoT devices into AI agents through a device specification describing device properties, commands and events.

This is highly relevant to Pico.

A device might expose:

```yaml
properties:
  temperature:
    type: number

commands:
  set_temperature:
    parameters:
      value:
        type: number

events:
  temperature_alert:
    payload:
      temperature:
        type: number
```

The Pico can then reason over the device's state and capabilities.

This enables an important extension of the Pico concept:

> **A Pico does not have to exist only in software. A Pico can inhabit or control a physical device.**

Examples include:

- robots;
- lamps;
- sensors;
- garden devices;
- industrial equipment;
- smart-home devices;
- autonomous machines.

---

# 8. Open Engineering Element Definitions

EMQ Device Agent specifications should not become the canonical definition of a Pico.

Open Engineering should remain the source of truth for the semantic model.

The preferred architecture is:

```text
              Open Engineering
                     │
                    OEED
                     │
              ┌──────┴──────┐
              │             │
           Pico Model   Device Adapter
              │             │
              ▼             ▼
           Pico OS      EMQ Device Agent
              │             │
              └──────┬──────┘
                     │
                   MQTT
                     │
                    EMQX
```

The Open Engineering Element Definition (OEED) should describe the element semantically.

An EMQX DeviceSpec can then be treated as an infrastructure-specific projection or adapter.

This prevents vendor lock-in.

---

# 9. Pico Transport Abstraction

Picos should not be hard-coded to EMQX.

The architecture should introduce an abstraction:

> **Pico Agent Transport**

MQTT/EMQX becomes the first implementation.

Conceptually:

```text
                 Pico Agent
                     │
              Pico Transport
                     │
        ┌────────────┼────────────┐
        │            │            │
       MQTT         A2A          Future
        │
       EMQX
```

This keeps the Pico architecture portable.

The Pico should understand concepts such as:

- message;
- event;
- observation;
- command;
- capability;
- presence;
- discovery;
- delegation;
- result.

The underlying transport should remain replaceable.

---

# 10. Event Model

The Pico event model should distinguish between at least:

### Observation

Something was observed.

```yaml
type: observation
source: pico-sensor-01
subject: garden/soil
data:
  moisture: 32
```

### Event

Something happened.

```yaml
type: event
source: kubernetes
subject: deployment/checkout
event: rollout_failed
```

### Command

A request to perform an action.

```yaml
type: command
target: pico-garden-01
command: water
```

### Delegation

A Pico asks another Pico to perform work.

```yaml
type: delegation
source: pico-architect
target: pico-kubernetes
mission: investigate_cluster
```

### Result

The outcome of an operation.

```yaml
type: result
source: pico-kubernetes
mission: investigate_cluster
status: completed
```

These semantic concepts should ultimately become part of the Open Engineering Pico communication conventions.

---

# 11. Identity

Every Pico participating in the communication fabric must have a stable identity.

This connects directly to the Pico Identity architecture.

A Pico identity should be independent from:

- MQTT client IDs;
- IP addresses;
- hostnames;
- Kubernetes pod names;
- EMQX-generated identifiers.

Infrastructure identifiers may change.

The Pico identity must not.

Conceptually:

```text
Pico Identity
     │
     ├── MQTT Client ID
     ├── A2A Identity
     ├── Kubernetes Identity
     └── Device Identity
```

This is particularly important for mobile, ephemeral and dynamically scaled Picos.

---

# 12. Security

MQTT communication must not imply unrestricted trust.

Picos should authenticate and authorize communication.

Security should cover:

- Pico identity;
- broker authentication;
- topic authorization;
- command authorization;
- capability authorization;
- encryption;
- delegation;
- auditability.

A Pico should not automatically be able to execute every command merely because it can publish to a topic.

For example:

```text
Pico A
  │
  │ request: reboot-device
  ▼
Authorization
  │
  ├── identity valid?
  ├── capability allowed?
  ├── operation permitted?
  └── mission authorized?
          │
          ▼
       Device
```

This should be integrated with Pico Rulesets.

---

# 13. Rulesets

Rulesets determine what a Pico is allowed and expected to do.

The communication layer therefore becomes another input into the rules engine.

For example:

```text
MQTT Event
     │
     ▼
Pico Observation
     │
     ▼
Ruleset Evaluation
     │
     ├── ignore
     ├── investigate
     ├── delegate
     └── execute
```

This is an important distinction:

> **MQTT delivers information; Pico Rulesets determine what the Pico should do with it.**

---

# 14. Memory and Evidence

Events received through EMQX should not automatically become long-term memory.

The Pico should determine whether an event is:

- transient telemetry;
- an observation;
- evidence;
- a fact;
- a state transition;
- a mission input;
- a memory candidate.

This preserves the distinction between the communication layer and the cognitive layer.

```text
EMQX
 │
 ▼
Event
 │
 ▼
Pico
 │
 ├── discard
 ├── observe
 ├── store
 ├── investigate
 └── act
```

---

# 15. Physical Picos

The combination of EMQX and Pico creates an especially interesting possibility for Open Engineering.

A physical object can become a Pico.

For example:

```text
              ┌──────────────────┐
              │ Physical Pico    │
              │                  │
              │ Sensors          │
              │ Actuators        │
              │ Local AI         │
              │ Identity         │
              └────────┬─────────┘
                       │
                      MQTT
                       │
                       ▼
                     EMQX
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
       Pico A        Pico B       Pico C
```

This provides a natural architecture for projects such as:

- robotic Picos;
- PixStars characters;
- autonomous lamps;
- environmental sensors;
- interactive installations;
- IoT engineering agents.

---

# 16. Kubernetes

EMQX is also a natural fit for the Kubernetes-based Pico environment.

A Pico may run as:

- a Kubernetes Deployment;
- a Job;
- a sidecar;
- a controller;
- an operator;
- a service;
- an ephemeral investigation agent.

EMQX provides communication between those Picos without requiring direct network coupling.

A possible architecture is:

```text
Kubernetes Cluster
│
├── EMQX
│
├── Pico Architect
├── Pico Detective
├── Pico Engineer
├── Pico Release
├── Pico Documentation
└── Pico Character
```

This fits the existing Open Engineering runtime model:

```text
Kernel
  ↓
Operating System
  ↓
Capsule
  ↓
Pico
  ↓
Application
```

with communication flowing through the Pico Agent Transport.

---

# 17. Relationship to MCP

MCP and MQTT should not be treated as competitors.

They operate at different levels.

### MCP

MCP is primarily useful for exposing tools and contextual capabilities to an agent.

```text
Pico → MCP → Tool
```

### MQTT

MQTT is primarily useful for event-driven communication between distributed participants.

```text
Pico → MQTT → Pico / Device / Service
```

Therefore:

```text
                    Pico
                     │
          ┌──────────┴──────────┐
          │                     │
         MCP                   MQTT
          │                     │
       Tools / Hands       Events / Nervous System
          │                     │
       Composio               EMQX
```

This separation should be preserved.

---

# 18. Relationship to Composio

The resulting Pico architecture has a particularly clean division:

| Concern | Candidate technology |
|---|---|
| Identity | Open Engineering Pico Identity |
| Rules | Open Engineering Pico Rulesets |
| Reasoning | AI model / Pico runtime |
| Memory | Pico Memory |
| External tools | Composio |
| Tool protocol | MCP |
| Events | MQTT |
| Agent transport | Pico Agent Transport |
| Broker | EMQX |
| Device agents | EMQX Device Agent |
| Pico-to-Pico communication | MQTT / A2A |
| Physical world | IoT / devices / actuators |

The resulting mental model is:

> **Pico is the agent. Composio is the hands. EMQX is the nervous system.**

---

# 19. Proposed Pico Architecture

The resulting reference architecture is:

```text
                         ┌─────────────────────────┐
                         │          PICO           │
                         │                         │
                         │ Identity                │
                         │ Mission                 │
                         │ Rulesets                │
                         │ Reasoning               │
                         │ Memory                  │
                         │ Evidence                │
                         │ Capabilities            │
                         └───────────┬─────────────┘
                                     │
                 ┌───────────────────┼───────────────────┐
                 │                   │                   │
                 ▼                   ▼                   ▼
             COMPOSIO            MCP              PICO TRANSPORT
               HANDS              │                    │
                 │                │                    │
                 ▼                ▼                    ▼
          External systems      Tools              MQTT / A2A
                                                      │
                                                      ▼
                                                    EMQX
                                                      │
                         ┌────────────────────────────┼──────────────┐
                         │                            │              │
                         ▼                            ▼              ▼
                       Picos                        Devices        Services
```

---

# 20. Proposed Open Engineering Artifacts

To implement this architecture, the following artifacts should be added to the Open Engineering ecosystem.

## Pico Agent Transport

Repository/domain:

```text
open-engineering-picos
```

Define:

- transport abstraction;
- message envelope;
- event model;
- command model;
- delegation model;
- result model;
- discovery model;
- presence model.

## Pico MQTT Conventions

Define:

- topic naming;
- QoS conventions;
- retained messages;
- session behaviour;
- correlation IDs;
- message IDs;
- timestamps;
- identity;
- authorization;
- discovery.

## Pico Agent Discovery

Define:

- capability advertisement;
- discovery queries;
- availability;
- capability versions;
- protocol negotiation.

## Pico-to-Pico Protocol

Define:

- delegation;
- collaboration;
- requests;
- responses;
- events;
- evidence exchange.

## EMQX Adapter

Implement:

```text
Pico Agent Transport
        │
        ▼
 MQTT Adapter
        │
        ▼
      EMQX
```

EMQX should therefore be an implementation, not the semantic owner of the Pico protocol.

---

# 21. Open Engineering Academy — Pico Course

This architecture should become part of the **Pico course** in Open Engineering Academy.

The course should teach the progression:

```text
1. What is a Pico?
        ↓
2. Pico Identity
        ↓
3. Pico Rulesets
        ↓
4. Pico Memory
        ↓
5. Pico Capabilities
        ↓
6. Pico Hands — Composio
        ↓
7. Pico Nervous System — MQTT / EMQX
        ↓
8. Pico-to-Pico Communication
        ↓
9. Agent Discovery
        ↓
10. Physical / IoT Picos
        ↓
11. Building a Pico Ecosystem
```

The learner should understand that a useful agent needs more than an LLM.

A Pico needs:

```text
Brain       → Reasoning
Memory      → Context
Rules       → Behavioural discipline
Identity    → Continuity
Hands       → Composio / Tools
Nervous Sys → MQTT / EMQX
Community   → Pico-to-Pico
```

This should become one of the central conceptual models of the Pico course.

---

# 22. Suggested Academy Exercise

A practical exercise should build a small Pico ecosystem.

### Pico 1 — Architect

Receives a mission:

```text
Investigate the architecture of system X.
```

### Pico 2 — Detective

Advertises:

```text
architecture-investigation
kubernetes
repository-analysis
```

### Pico 3 — Device Pico

Exposes:

```text
temperature
status
restart
```

### Exercise flow

```text
Architect Pico
      │
      │ discover
      ▼
    EMQX
      │
      ▼
Detective Pico
      │
      │ investigation
      ▼
    Evidence
      │
      ▼
Architect Pico

Meanwhile:

Device
  │
  │ temperature event
  ▼
EMQX
  │
  ▼
Pico
  │
  └── reason → act
```

The learner thereby experiences:

- identity;
- events;
- MQTT;
- discovery;
- Pico-to-Pico collaboration;
- rules;
- tools;
- physical devices.

---

# 23. Architectural Principle

The central principle proposed by this memo is:

> **Picos should communicate through a transport abstraction, with MQTT/EMQX as a first-class implementation for event-driven and distributed communication.**

And the complementary principle is:

> **Open Engineering owns the semantics; infrastructure providers implement the transport.**

This means Open Engineering should define what a Pico means by:

- identity;
- capability;
- event;
- observation;
- command;
- delegation;
- result;
- presence;
- discovery.

EMQX should provide the infrastructure to transport and route those concepts.

---

# 24. Decision

**Proposed decision: ACCEPT as an architectural direction.**

Adopt EMQX/MQTT as a candidate implementation of the **Pico Nervous System** and **Pico Agent Transport**, while keeping the transport abstract and vendor-neutral.

Adopt the following conceptual vocabulary:

```text
Pico
 ├── Brain        → AI / Reasoning
 ├── Memory       → Context / Experience
 ├── Identity     → Continuity
 ├── Rules        → Engineering Discipline
 ├── Hands        → Composio / MCP / Tools
 └── Nervous Sys  → MQTT / EMQX / Events
```

This creates a coherent architecture in which a Pico can reason, remember, obey rules, act on external systems, communicate with other Picos and interact with the physical world.

---

# 25. Next Steps

1. Define the **Pico Agent Transport** abstraction.
2. Define **Pico MQTT Conventions**.
3. Define the **Pico Message Envelope**.
4. Define Pico **events, observations, commands, delegations and results**.
5. Define **Pico Agent Discovery**.
6. Map Pico Identity onto MQTT client/session concepts without making them equivalent.
7. Define authorization rules for Pico-to-Pico communication.
8. Build an EMQX adapter/reference implementation.
9. Investigate EMQX Device Agent integration.
10. Build a minimal multi-Pico proof of concept.
11. Add the EMQX/Nervous System chapter to the Open Engineering Academy Pico course.
12. Connect the implementation to the existing **Composio / Hands** architecture.

---

# Appendix A — The Pico Mental Model

The Pico architecture can now be explained with a human metaphor:

```text
                         PICO
                          │
            ┌─────────────┼─────────────┐
            │             │             │
           Brain        Memory        Identity
            │             │             │
         Reasoning     Experience    Continuity
            │
            ▼
          Rules
            │
            ▼
       Engineering
        Discipline
            │
       ┌────┴────┐
       │         │
     Hands    Nervous System
       │         │
    Composio   EMQX
       │         │
    MCP/Tools  MQTT
       │         │
       ▼         ▼
  Digital World  Distributed World
```

This is intentionally simple enough to become a teaching model while remaining useful as an architectural guide.

---

# Appendix B — One-Sentence Definition

> **A Pico is an identifiable, rule-governed AI agent that can reason, remember, use hands to act on external systems, and communicate through a nervous system with other agents, services and the physical world.**
