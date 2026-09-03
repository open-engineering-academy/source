# Memo 11: Course Proposal: Pico Agents with AgentConnect

## Status

Proposed

## Target Repository

Open Engineering Academy

## Course

Pico Agents — Connecting Physical Picos to AI Agents with AgentConnect

## Objective

Create a new Open Engineering Academy course that extends the existing Pico course by introducing AI agents and AgentConnect.

The course should teach learners how a physical Raspberry Pi Pico can become part of an agentic engineering system, where software agents observe the physical world, reason about observations, coordinate with other agents, and execute actions through the Pico.

The course should reuse the existing Pico educational material wherever possible, especially:

* Hello, Pico!
* Pico GPIO
* Sensors
* LEDs
* Buttons
* MQTT
* MicroPython
* networking
* device communication
* existing EMQX/MQTT material

The new course should introduce AgentConnect as the orchestration layer for AI agents rather than attempting to put an LLM directly onto the Pico.

⸻

## 1. Core Idea

The fundamental architecture taught by the course is:
```
                         OPEN ENGINEERING
                                │
                                ▼
                         AI Assistant / Agent
                                │
                                ▼
                          AgentConnect
                                │
                                ▼
                         MQTT / EMQX
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
                 Pico A                  Pico B
                    │                       │
              Sensors / LEDs          Sensors / Motors
```
The Pico is the physical Engineering Element.

AgentConnect provides the agent execution and orchestration environment.

MQTT provides the messaging boundary between software agents and physical devices.

This establishes an important engineering principle:

The Pico does not need to run the AI. The Pico provides sensing and actuation; the agent provides intelligence.

⸻

2. Learning Goals

After completing the course, a learner should understand:

* What an AI agent is.
* What makes an agent different from a conventional program.
* Why AI inference normally belongs outside a microcontroller.
* How AgentConnect can run and coordinate agents.
* How a Pico can expose physical capabilities to an agent.
* How MQTT connects agents and devices.
* How EMQX can act as an MQTT broker.
* How events can trigger agent actions.
* How multiple agents can collaborate.
* How to design safe boundaries between AI and physical systems.
* How this architecture maps onto Open Engineering concepts.

The learner should finish with a working physical/AI system.

⸻

3. Prerequisites

Reuse the prerequisite expectations from the existing Pico course.

Learners should preferably have completed:

Hello, Pico!

and understand:

* basic Python/MicroPython
* variables
* functions
* GPIO
* simple electronics
* flashing MicroPython
* connecting a Pico to a computer

No previous AI-agent experience should be required.

⸻

4. Course Structure

Module 1 — From Pico to Agent

Introduce the evolution:

Program
  ↓
Networked Device
  ↓
IoT Device
  ↓
MQTT Device
  ↓
AI-enabled Device
  ↓
Agentic Device System

Explain that the Pico remains deliberately simple.

The intelligence exists in the surrounding system.

Reuse material from Hello, Pico! rather than rebuilding introductory Pico lessons.

⸻

5. Module 2 — What Is an Agent?

Introduce the concept of an AI agent.

Compare:

Traditional program

input
  ↓
fixed logic
  ↓
output

with:

Agent

observe
   ↓
interpret
   ↓
reason
   ↓
decide
   ↓
act
   ↓
observe again

Connect this to the Open Engineering Kernel primitives:

* Observation
* Investigation
* Execution
* Events
* Messaging
* Workflow
* Memory
* Evidence
* Reporting
* Composition

The learner should understand that agentic behaviour is a system architecture, not simply “putting ChatGPT in a device”.

⸻

6. Module 3 — Meet AgentConnect

Introduce AgentConnect as the agent execution and orchestration layer.

Explain the distinction:

Pico
= physical device
MQTT
= messaging
EMQX
= MQTT infrastructure
AgentConnect
= agent execution/orchestration
AI model
= reasoning capability

The course should use the current AgentConnect documentation and APIs rather than hard-code assumptions about implementation details.

Learners should:

1. Install or access AgentConnect.
2. Create an agent.
3. Configure its runtime.
4. Give it a workspace.
5. Connect appropriate tools.
6. Run the agent.
7. inspect its session/execution.
8. communicate with the agent.

⸻

7. Module 4 — Give the Agent a Pico

Connect the agent environment to a physical Pico.

Start with a simple LED.

The Pico exposes an MQTT interface such as:

pico/living-room/led/set
pico/living-room/led/state

The agent can issue:

ON
OFF

and the Pico publishes its state.

The learner should see:

Agent
  │
  │ MQTT
  ▼
EMQX
  │
  ▼
Pico
  │
  ▼
LED

⸻

8. Module 5 — Give the Pico Senses

Add a sensor.

For example:

* temperature
* light
* button
* distance
* motion

The Pico publishes observations:

pico/living-room/temperature
pico/living-room/light
pico/living-room/button

The agent subscribes to these observations.

Now the architecture becomes:

Pico
 │
 ├── observe
 │
 └── publish
       │
       ▼
     MQTT
       │
       ▼
     Agent
       │
     reason
       │
       ▼
     MQTT
       │
       ▼
     Pico
       │
     act

This is the first complete agentic feedback loop.

⸻

9. Module 6 — Agent Instructions

Teach learners how to give an agent a role.

Example:

You are the Pico Environment Agent.
Your job is to monitor the environment.
You can:
- read temperature observations
- read light observations
- control the status LED
Do not activate an actuator unless the requested action
is within your allowed capabilities.

Explain the relationship between:

* agent role
* tools
* capabilities
* permissions
* workspace
* memory
* runtime

Connect these concepts to Open Engineering AI Assistants.

⸻

10. Module 7 — From Commands to Intent

Move beyond explicit commands.

Instead of:

turn LED on

the learner can ask:

Make the room easier to find when it gets dark.

The agent can reason:

observe light
     ↓
light level is low
     ↓
decide LED should be enabled
     ↓
publish MQTT command
     ↓
Pico turns LED on

The course should emphasize that the agent is not replacing deterministic device firmware.

The Pico still enforces the actual hardware behaviour.

⸻

11. Module 8 — Safety Boundaries

This module is essential.

Teach that an AI agent should not automatically receive unrestricted control of physical systems.

Introduce three layers:

AI Agent
   │
   ▼
Intent / Decision
   │
   ▼
Capability Boundary
   │
   ▼
Pico

For example:

Agent requests:
motor.speed = 100
Capability layer:
maximum allowed speed = 30
Pico:
motor.speed = 30

Teach:

* allowlists
* ranges
* safe defaults
* timeouts
* authentication
* authorization
* command validation
* fail-safe behaviour

The Pico must remain safe even when the agent behaves incorrectly.

⸻

12. Module 9 — Agent Memory

Introduce memory.

The agent can remember observations and previous interactions.

Example:

Monday:
room normally becomes dark around 20:15
Tuesday:
room became dark around 20:10
Wednesday:
room became dark around 20:12

The agent can use this information when making future decisions.

Explain the difference between:

Pico state
MQTT retained state
Agent session context
Agent memory
Open Engineering persistent knowledge

Do not make AgentConnect memory the authoritative Open Engineering knowledge store.

⸻

13. Module 10 — Multiple Agents

Introduce an agent team.

Example:

                Pico System
                     │
                     ▼
              Sensor Agent
                     │
                     ▼
              Environment Agent
                     │
             ┌───────┴────────┐
             ▼                ▼
       Decision Agent    Safety Agent
             │                │
             └───────┬────────┘
                     ▼
                 Pico Agent
                     │
                     ▼
                   Pico

Use AgentConnect’s agent-to-agent capabilities where appropriate.

Learners should understand that agents can specialize.

For example:

* Sensor Agent
* Environment Agent
* Safety Agent
* Device Agent
* Documentation Agent

⸻

14. Module 11 — Event-Driven Agents

Introduce events.

Examples:

temperature changed
button pressed
light level crossed threshold
Pico connected
Pico disconnected
MQTT message received

These events can trigger agent execution.

Example:

button pressed
      ↓
MQTT event
      ↓
AgentConnect
      ↓
Agent
      ↓
reason
      ↓
action

Relate this to the Open Engineering Events primitive and Runner OS.

⸻

15. Module 12 — Build the Pico Agent

The learner now creates a complete agent.

The agent should:

1. Observe Pico telemetry.
2. Interpret observations.
3. Maintain relevant context.
4. Decide whether action is necessary.
5. Validate the proposed action.
6. Send a command.
7. Observe the resulting device state.
8. Report what happened.

The result should demonstrate:

Observation
    ↓
Investigation
    ↓
Decision
    ↓
Execution
    ↓
Observation
    ↓
Evidence
    ↓
Report

This is the Open Engineering Kernel pattern expressed through a physical device.

⸻

16. Final Project — The Intelligent Pico

Build a small autonomous physical system.

The exact hardware should remain simple and reusable.

Suggested project:

Pico Environment Agent

The Pico contains:

* LED
* button
* temperature sensor
* light sensor

The system contains:

* Pico
* MQTT
* EMQX
* AgentConnect
* AI agent

The agent should be able to:

* monitor the environment
* answer questions about the environment
* control the LED
* react to events
* remember relevant observations
* explain why it performed an action
* respect safety constraints

Example interaction:

User:
"It feels dark in here."
Agent:
"I'll check the light level."
Pico:
light = 18%
Agent:
"The measured light level is low.
I'll activate the indicator LED."
Pico:
LED = ON
Agent:
"Indicator enabled because the measured light
level was below the configured threshold."

⸻

17. Evidence

The final system should demonstrate that an agent action can be traced.

For example:

Observation:
light = 18%
Decision:
activate indicator
Policy:
minimum light = 25%
Action:
pico/living-room/led/set = ON
Result:
pico/living-room/led/state = ON

This introduces the learner to the Open Engineering concept of Evidence.

The agent should ideally be able to explain its action based on observable facts rather than claiming that it acted successfully without verification.

⸻

18. Open Engineering Mapping

The course should explicitly map the project to the Open Engineering architecture.

Pico Course Concept	Open Engineering
Pico	Engineering Element
Sensor	Observation capability
LED/actuator	Execution capability
MQTT	Messaging
EMQX	Infrastructure
AgentConnect	Agent Runtime / Orchestration
AI Agent	AI Assistant
Agent skill	Capability / Capsule
Event	Event
Agent memory	Memory
Agent decision	Investigation / reasoning
Device command	Execution
Sensor result	Evidence
Agent report	Reporting
Multiple agents	Composition
Scheduled agent	Runner OS

This mapping should be part of the course material.

⸻

19. Reuse Existing Pico Material

The course must reuse rather than duplicate existing Academy content.

Particularly reuse:

* Hello, Pico!
* MicroPython setup
* GPIO
* LED examples
* button examples
* sensor examples
* networking
* MQTT
* existing Pico exercises

The new course should link to those lessons and only introduce the additional material necessary for agentic operation.

Where the existing Pico course already contains a working MQTT/EMQX example, use it as the foundation for the AgentConnect exercises.

⸻

20. EMQX Integration

Reuse the existing Open Engineering work around EMQX.

The course should demonstrate:

AgentConnect
      │
      ▼
    MQTT
      │
      ▼
    EMQX
      │
      ├──────── Pico
      ├──────── Pico
      └──────── other devices

MQTT topics should follow the Open Engineering MQTT conventions.

Do not invent course-specific topic conventions if an existing Open Engineering MQTT convention already exists.

⸻

21. AgentConnect Integration Requirements

The implementation should verify the current AgentConnect capabilities before course publication.

Specifically investigate:

* Agent creation
* Agent configuration
* Agent runtimes
* MCP
* ACP
* Agent-to-agent communication
* Webhooks
* Events
* Scheduling
* Workspace management
* Memory
* Permissions
* GitHub integration
* Local/self-hosted execution

Only document APIs that are currently supported.

⸻

22. Hardware Philosophy

The course should deliberately avoid requiring expensive hardware.

The preferred setup is:

1 × Raspberry Pi Pico
1 × breadboard
LEDs
resistors
button
1 × simple sensor

Optional components can extend the project.

The important lesson is the architecture, not the complexity of the electronics.

⸻

23. Architecture Exercise

Include an exercise where learners draw their own system architecture.

They should identify:

Physical World
      ↓
Pico
      ↓
MQTT
      ↓
EMQX
      ↓
AgentConnect
      ↓
AI Agent
      ↓
Decision
      ↓
MQTT
      ↓
Pico
      ↓
Physical World

Then ask:

Which parts are deterministic and which parts are probabilistic?

This should lead to an important engineering discussion:

* Pico firmware should be deterministic.
* Safety limits should be deterministic.
* MQTT transport should be deterministic.
* AI reasoning is probabilistic.
* Agent decisions should be constrained by deterministic capabilities and policies.

⸻

24. Assessment

Assessment should be practical.

Learners should demonstrate:

Level 1

A Pico publishes sensor data.

Level 2

An agent receives and understands the data.

Level 3

The agent controls a Pico actuator.

Level 4

The system reacts to events.

Level 5

The agent maintains context/memory.

Level 6

Multiple agents collaborate.

Level 7

The system produces traceable evidence.

Level 8

Safety boundaries prevent unsafe actions.

A final challenge should ask learners to extend the system with another sensor or actuator.

⸻

25. Course Narrative

The course should follow the same spirit as Hello, Pico!:

Hello, Pico!
      ↓
Hello, Network!
      ↓
Hello, MQTT!
      ↓
Hello, Agent!
      ↓
Hello, AgentConnect!
      ↓
Hello, Intelligent Device!
      ↓
Hello, Agent Team!

The learner should experience a gradual transition from simple embedded programming to distributed agentic engineering.

⸻

26. Deliverables

Create:

course/
├── README.md
├── lessons/
│   ├── 01-from-pico-to-agent/
│   ├── 02-what-is-an-agent/
│   ├── 03-agentconnect/
│   ├── 04-connect-the-pico/
│   ├── 05-sensors/
│   ├── 06-agent-instructions/
│   ├── 07-intent/
│   ├── 08-safety/
│   ├── 09-memory/
│   ├── 10-multiple-agents/
│   ├── 11-events/
│   └── 12-final-project/
├── examples/
├── exercises/
├── diagrams/
└── hardware/

Follow the existing Open Engineering Academy course conventions rather than imposing this structure if the Academy already has an established format.

⸻

27. Definition of Done

The course is complete when:

* [ ]	Existing Pico lessons have been identified and reused.
* [ ]	AgentConnect integration has been validated against its current APIs.
* [ ]	AgentConnect setup is documented.
* [ ]	A Pico can publish telemetry through MQTT.
* [ ]	EMQX can route the telemetry.
* [ ]	An AgentConnect agent can consume Pico observations.
* [ ]	The agent can control a Pico actuator.
* [ ]	Event-driven operation works.
* [ ]	Agent memory/context is demonstrated.
* [ ]	Multi-agent operation is demonstrated.
* [ ]	Safety boundaries are demonstrated.
* [ ]	Agent decisions produce traceable evidence.
* [ ]	The final project works with inexpensive Pico hardware.
* [ ]	All examples are reproducible.
* [ ]	Existing Open Engineering MQTT conventions are followed.
* [ ]	Existing Pico course material is reused rather than duplicated.
* [ ]	The course maps the implementation back to Open Engineering concepts.

⸻

28. Desired Outcome

The learner should finish the course understanding that an AI-enabled physical system does not need to turn the microcontroller into a miniature AI computer.

Instead:

                    AI
                     │
               AgentConnect
                     │
                  MQTT
                     │
                    Pico
                     │
              Physical World

This architecture creates a clean separation between:

Intelligence

AI agents and AgentConnect.

Communication

MQTT and EMQX.

Physical execution

Pico firmware and hardware.

Engineering semantics

Open Engineering.

That separation is the central lesson of the course.

⸻

Recommendation

Proceed with implementation as a new Open Engineering Academy Pico course.

The course should become the next evolutionary step after Hello, Pico!, turning the Pico from a simple programmable microcontroller into a physical Engineering Element participating in an Open Engineering agent ecosystem.

The central educational message should be:

Give the Pico senses and actions. Give the agent intelligence. Connect them with an open messaging system.
