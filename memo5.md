# Memo: Open Engineering Academy Course — Make the Lamp Nod

Status: Proposed implementation specification  
Repository: open-engineering-academy/source  
Artifact: Academy course  
Working course title: Make the Lamp Nod  
Subtitle: From Digital Twin to Physical Actuation with Open Engineering  
Course type: Capstone / integration course  
Primary domain: Open Engineering Robotics  
Reference implementation: PixStars anglepoise lamp head actuation MVP  

⸻

## 1. Executive Summary

The Open Engineering Academy SHALL implement a course named:

Make the Lamp Nod — From Digital Twin to Physical Actuation with Open Engineering

The course demonstrates how an Open Engineering declaration can ultimately cause a physical object to move.

The reference system is the PixStars anglepoise lamp MVP. Its head is actuated by a Dynamixel AX-12A servo controlled by an ESP32 through a 74HCT245 interface.

The physical outcome of the course is deliberately simple:

The learner presses “Nod” in Home Assistant and the physical lamp nods its head.

Achieving that result SHALL require composition of concepts taught elsewhere in the Open Engineering Academy:

* Kubernetes;
* MiniKube;
* Crossplane;
* Open Engineering Definitions;
* Open Engineering Conventions;
* Open Engineering Parsers;
* Open Engineering Rules;
* Pico;
* Manifold;
* event-driven execution;
* Home Assistant;
* edge integration;
* robotics;
* digital twins.

This course MUST NOT become another tutorial teaching each technology independently.

Instead, it SHALL demonstrate how previously learned Open Engineering capabilities compose into an end-to-end cyber-physical system.

The conceptual journey is:

Human Intent
     ↓
Home Assistant
     ↓
Open Engineering Capability
     ↓
Pico Digital Twin
     ↓
Manifold Runtime
     ↓
Open Engineering Event
     ↓
Edge Adapter
     ↓
ESP32
     ↓
74HCT245
     ↓
AX-12A
     ↓
Mechanical Lamp Head
     ↓
Physical Motion

The final proof that the architecture works is:

The lamp nods.

⸻

2. Purpose

The course has five purposes.

2.1 Demonstrate composition

The learner SHALL experience existing Open Engineering concepts as parts of one working system rather than as isolated technologies.

2.2 Introduce cyber-physical Open Engineering

The course SHALL demonstrate that Open Engineering is capable of describing, composing, executing, observing, and controlling physical systems.

2.3 Introduce digital twins through Pico

The AX-12A actuator SHALL have a Pico-based digital representation.

The Pico SHALL represent the logical actuator and its state rather than merely mirroring a hardware register.

2.4 Establish the Open Engineering Robotics pattern

The implementation created by this course SHALL become a reusable reference architecture for future physical devices.

2.5 Create the bridge toward embodied characters

The course SHALL stop at explicit human instruction of a physical gesture.

Future PixStars courses can subsequently introduce:

Character
    ↓
Reasoning
    ↓
Intent
    ↓
Gesture
    ↓
Actuator Capability
    ↓
Physical Motion

Therefore this course establishes the actuator foundation without coupling actuation to character intelligence.

⸻

3. Central Learning Objective

At the end of the course, the learner SHALL be able to explain and demonstrate:

How a semantic command such as nod travels from a human interface through Open Engineering abstractions, a Pico digital twin, runtime behavior and an edge adapter until it becomes physical motion.

The learner SHALL also understand the reverse direction:

Physical Device
      ↓
Telemetry
      ↓
Edge Adapter
      ↓
Pico State
      ↓
Open Engineering
      ↓
Home Assistant
      ↓
Human

The system is therefore not merely remote control.

It is a minimal closed-loop cyber-physical architecture.

⸻

4. Relationship to PixStars

PixStars provides the reference implementation.

The course MUST NOT make PixStars-specific assumptions part of generic Open Engineering infrastructure.

PixStars contributes:

* the anglepoise lamp;
* the AX-12A actuator;
* the ESP32;
* the 74HCT245 interface;
* the physical head mechanism;
* the semantic gesture nod.

Open Engineering contributes:

* definitions;
* conventions;
* identifiers;
* composition;
* digital twins;
* runtime behavior;
* events;
* adapters;
* observability;
* user interfaces;
* infrastructure.

The architecture SHALL therefore preserve this boundary:

OPEN ENGINEERING
       │
       │ provides reusable capabilities
       ▼
PIXSTARS
       │
       │ composes those capabilities
       ▼
CHARACTER BEHAVIOR

The Academy course uses PixStars as a compelling example, not as a special case embedded into the Open Engineering kernel.

⸻

5. Physical Reference Architecture

The minimum physical system SHALL consist of:

ESP32
  │
  ▼
74HCT245
  │
  ▼
Dynamixel AX-12A
  │
  ▼
Mechanical head pivot
  │
  ▼
Anglepoise lamp head

The AX-12A is responsible for the physical head-pitch degree of freedom.

The first gesture SHALL be:

nod

The course MAY later support:

center
look-up
look-down
nod

but nod is mandatory.

⸻

6. Hardware Responsibilities

6.1 ESP32

The ESP32 SHALL act as an Open Engineering edge adapter.

Its responsibilities are limited to:

* network connectivity;
* receiving actuator commands;
* validating device-level commands;
* converting commands to Dynamixel Protocol 1.0;
* communicating with the AX-12A;
* managing UART communication;
* managing communication direction where required;
* reporting actuator state;
* reporting errors;
* reporting connectivity;
* exposing health information.

The ESP32 MUST NOT contain PixStars character reasoning.

It MUST NOT decide when PixStars should nod.

It MUST NOT interpret concepts such as:

agreement
disagreement
happiness
attention
confusion

Those belong at higher semantic layers.

The ESP32 SHALL understand actuator-level concepts such as:

set-position
center
execute-motion
stop
get-position
get-temperature
get-status

⸻

7. 74HCT245 Responsibility

The 74HCT245 belongs entirely to the physical communication implementation.

It SHALL NOT appear as a semantic Open Engineering entity unless a later hardware-observability course explicitly models electronic components.

For this course it is sufficient to explain:

Open Engineering
       ↓
ESP32 edge adapter
       ↓
electrical interface
       ↓
74HCT245
       ↓
AX-12A

The learner should understand that Open Engineering abstractions eventually cross a hardware boundary where voltage levels, buses and electrical communication matter.

⸻

8. AX-12A Responsibility

The AX-12A SHALL remain the physical actuator.

The AX-12A SHALL NOT itself be treated as the complete digital twin.

Instead:

Pico
 │
 │ represents
 ▼
Logical Head-Pitch Actuator
 │
 │ currently implemented by
 ▼
AX-12A

This distinction is essential.

A future implementation MAY replace the AX-12A with another servo without changing the semantic capability exposed to higher layers.

⸻

9. Pico Digital Twin

The course SHALL model the logical PixStars head-pitch actuator as a Pico.

Conceptually:

kind: Pico
metadata:
  name: pixstars-head-pitch
spec:
  type: actuator
  capabilities:
    - center
    - set-position
    - nod
  implementation:
    deviceClass: dynamixel
    model: AX-12A

The actual syntax SHALL follow the canonical Pico conventions already taught by the Open Engineering Academy.

The course MUST reference the existing Pico course rather than inventing an incompatible Pico format.

⸻

10. Pico State Model

At minimum the digital twin SHALL be capable of representing:

desiredPosition: 0
actualPosition: 0
moving: false
torqueEnabled: true
connected: true
temperature: null
lastCommand: null
lastCommandStatus: null
lastUpdated: null

Where hardware telemetry permits it, the course SHOULD populate:

* actual position;
* moving state;
* temperature;
* voltage;
* torque state;
* hardware error state.

The distinction between:

desired state

and:

observed state

MUST be taught explicitly.

For example:

desiredPosition = +15°
actualPosition  = +12°

is not inherently an error.

It is evidence that the physical system is moving toward the desired state.

⸻

11. Identity

Every important Open Engineering entity SHALL use the canonical Open Engineering identifier conventions taught elsewhere in the Academy.

The course MUST NOT create a separate identity scheme.

At minimum identities SHALL exist for:

* physical actuator;
* Pico digital twin;
* actuator capability;
* edge adapter;
* runtime instance;
* relevant events.

The learner SHALL be able to trace an execution using these identities.

⸻

12. Capability Model

The principal capability SHALL be:

nod

The capability is semantic.

It SHALL NOT expose raw Dynamixel register manipulation to the caller.

The desired abstraction is:

nod()

not:

writeRegister(30, 614)
sleep(300)
writeRegister(30, 410)
...

The distinction demonstrates one of the central Open Engineering principles:

Consumers request capabilities. Implementations determine how those capabilities are realized.

⸻

13. Nod Behavior

The first implementation SHALL define nod as a deterministic motion sequence.

A canonical sequence SHALL be supplied by the course implementation.

For example:

START
  ↓
center
  ↓
move slightly downward
  ↓
move slightly upward
  ↓
return to center
  ↓
END

Exact safe servo positions SHALL be configurable.

They MUST NOT be hard-coded into generic Open Engineering definitions.

Configuration SHALL distinguish:

logical gesture

from:

physical calibration

For example:

nod:
  center: 0
  down: 15
  up: -8
  repetitions: 1
  speed: safe

These values are illustrative until calibrated against the physical lamp.

The implementation SHALL include a calibration step before executing the full nod sequence.

⸻

14. Safety

Physical actuation introduces safety requirements not present in purely virtual Academy courses.

The implementation SHALL provide:

* configurable minimum position;
* configurable maximum position;
* configurable movement speed;
* command timeout;
* emergency stop;
* communication failure handling;
* safe startup state;
* safe shutdown state.

The learner SHALL NOT be instructed to execute unrestricted servo movement.

The course SHALL require calibration before gesture execution.

The safe sequence is:

Discover
   ↓
Connect
   ↓
Read current state
   ↓
Establish safe limits
   ↓
Test small movement
   ↓
Return to center
   ↓
Enable gesture

⸻

15. Crossplane

Crossplane SHALL be responsible for declarative composition.

The learner SHALL NOT manually assemble every runtime resource.

Instead, the learner SHALL request an Open Engineering actuator capability.

Conceptually:

apiVersion: robotics.open-engineering.io/v1alpha1
kind: Actuator
metadata:
  name: pixstars-head
spec:
  capabilities:
    - nod

The actual API version and schema SHALL follow existing Open Engineering Definitions and Crossplane course conventions.

Crossplane SHALL compose the resources necessary to realize the requested actuator.

Conceptually:

Actuator XR
    │
    ├── Pico representation
    ├── runtime registration
    ├── event connectivity
    ├── edge-adapter configuration
    ├── observability
    └── Home Assistant exposure

⸻

16. Relationship to the Existing Crossplane Course

The Academy implementation MUST NOT repeat foundational Crossplane material.

Instead it SHALL link learners to the existing Crossplane course for:

* XRDs;
* XRs;
* Compositions;
* Composition Functions;
* reconciliation;
* providers;
* declarative infrastructure concepts.

This course SHALL answer the more advanced question:

What happens when the thing being composed eventually controls a physical actuator?

⸻

17. Kubernetes

Kubernetes SHALL provide the local runtime substrate.

The course MUST assume that learners understand:

* Pods;
* Deployments;
* Services;
* ConfigMaps;
* Secrets;
* namespaces;
* controllers;
* reconciliation.

Where those concepts are required, the course SHALL link to the existing Kubernetes material rather than reproducing it.

⸻

18. MiniKube

MiniKube SHALL provide the canonical local Kubernetes environment for this course.

The intended local architecture is:

Developer Workstation
┌───────────────────────────────────────────────┐
│ MiniKube                                      │
│                                               │
│ Crossplane                                    │
│ Open Engineering resources                    │
│ Manifold                                      │
│ Pico runtime                                  │
│ event/messaging infrastructure                │
│ Home Assistant integration                    │
│ observability                                 │
└───────────────────────────────────────────────┘
                       │
                       │ LAN / Wi-Fi
                       ▼
                    ESP32
                       │
                       ▼
                   74HCT245
                       │
                       ▼
                    AX-12A
                       │
                       ▼
                     Lamp

The existing MiniKube course SHALL remain the authoritative source for installing and operating MiniKube.

This course SHALL provide only validation commands required to verify that its prerequisites are available.

⸻

19. Manifold

Manifold SHALL provide the Pico/runtime execution environment used by the course.

Crossplane and Manifold SHALL have clearly separated responsibilities.

Crossplane

Answers:

What should exist?

Manifold / Pico runtime

Answers:

What should happen?

The course MUST make this distinction explicit.

⸻

20. Runtime Behavior

A nod request SHALL produce an event or equivalent runtime instruction.

Conceptually:

pixstars.head.nod.requested

The Pico runtime SHALL respond by executing the configured nod behavior.

Conceptually:

ON pixstars.head.nod.requested
IF actuator.connected
AND actuator.ready
AND actuator.withinSafeLimits
THEN execute nod
ELSE report failure

The exact rule representation SHALL reuse the Open Engineering Rules conventions already established by the Academy.

⸻

21. Event Flow

The complete forward execution SHALL be observable.

1. User presses NOD.
2. Home Assistant emits a nod request.
3. Open Engineering resolves the target capability.
4. An event is created.
5. The Pico receives or observes the event.
6. Manifold executes the applicable rule.
7. The nod gesture becomes actuator commands.
8. Commands are sent to the ESP32 edge adapter.
9. ESP32 translates them to Dynamixel Protocol 1.0.
10. Commands pass through the electrical interface.
11. AX-12A moves.
12. Lamp head moves.
13. Telemetry is returned.
14. Pico observed state changes.
15. Home Assistant reflects the updated state.

The course SHALL provide enough logging and observability for the learner to trace this complete chain.

⸻

22. Messaging

The implementation SHALL use the messaging/event mechanism already standardized by Open Engineering.

If MQTT is the currently adopted transport, the course SHALL use MQTT.

Transport details SHALL remain below the semantic event layer.

Conceptually:

Semantic event
     ↓
Open Engineering messaging
     ↓
transport adapter
     ↓
MQTT
     ↓
ESP32

The semantic architecture MUST NOT become coupled to MQTT topic naming.

This ensures that another transport can later replace MQTT without redefining nod.

⸻

23. Home Assistant

Home Assistant SHALL provide the first human control interface.

The minimum dashboard SHALL expose:

PixStars Lamp
Connection:       Connected
Head position:    0°
Moving:           No
Torque:           Enabled
Last command:     nod
Last result:      Success
[ NOD ]
[ CENTER ]
[ STOP ]

NOD is mandatory.

CENTER and STOP SHOULD also be provided.

⸻

24. Home Assistant Is Not the Controller

The course MUST teach that Home Assistant is an interface, not the owner of the actuator behavior.

Home Assistant requests:

nod

It MUST NOT implement the complete servo trajectory.

Incorrect:

Home Assistant
    ↓
position 15
    ↓
delay
    ↓
position -8
    ↓
delay
    ↓
position 0

Correct:

Home Assistant
      ↓
     nod
      ↓
Open Engineering
      ↓
gesture behavior
      ↓
actuator implementation

This allows future interfaces to request exactly the same capability.

⸻

25. Future Interfaces

The architecture SHALL deliberately allow nod to originate from:

* Home Assistant;
* CLI;
* web application;
* automated test;
* another Pico;
* workflow;
* AI agent;
* character runtime;
* voice instruction;
* story timeline.

None of these SHALL require knowledge of Dynamixel Protocol 1.0.

⸻

26. Semantic Layering

The course SHALL explicitly teach the following layering:

WHY
Character meaning
"PixStars agrees"
        ↓
WHAT
Gesture intent
"nod"
        ↓
HOW — LOGICAL
Gesture sequence
down → up → center
        ↓
HOW — DEVICE
Servo positions and speeds
        ↓
HOW — PROTOCOL
Dynamixel Protocol 1.0
        ↓
HOW — ELECTRICAL
ESP32 + 74HCT245
        ↓
PHYSICS
AX-12A rotates lamp head

This diagram is one of the key teaching artifacts of the course.

⸻

27. Character Boundary

This course SHALL NOT implement autonomous PixStars character behavior.

The course ends at:

Human
 ↓
Nod instruction
 ↓
Physical nod

A future course can build:

Character
 ↓
Observation
 ↓
Reasoning
 ↓
Emotional/semantic intent
 ↓
Gesture selection
 ↓
nod
 ↓
Physical nod

This boundary prevents robotics infrastructure from becoming coupled to a particular character implementation.

⸻

28. Simulation First

The course SHALL support completion without immediately connecting physical hardware.

The implementation SHALL therefore support at least two actuator adapters:

SimulatedActuator

and:

DynamixelAX12AActuator

Both SHALL implement the same logical actuator contract.

This enables:

Home Assistant
      ↓
     nod
      ↓
Pico
      ↓
Simulated Actuator

before:

Home Assistant
      ↓
     nod
      ↓
Pico
      ↓
Physical AX-12A

This is essential for:

* CI;
* automated testing;
* Academy learners without hardware;
* development safety;
* debugging;
* repeatability.

⸻

29. Course Progression

The course SHALL be divided into the following modules.

Module 0 — The Challenge

Introduce only the desired result:

Press a button and make the lamp nod.

Show the final system before explaining it.

⸻

Module 1 — Meet the Physical System

Explain:

ESP32
 ↓
74HCT245
 ↓
AX-12A
 ↓
Lamp head

Introduce the physical boundary.

Do not yet introduce character intelligence.

⸻

Module 2 — From Device to Capability

Transform the hardware-centric idea:

AX-12A servo

into the semantic capability:

HeadPitchActuator
  └── nod

Teach capability-oriented engineering.

⸻

Module 3 — Create the Digital Twin

Reuse the existing Pico course.

Create:

pixstars-head-pitch

Teach:

* desired state;
* observed state;
* capabilities;
* identity;
* events.

⸻

Module 4 — Simulate the Actuator

Implement the simulated adapter.

Execute nod without physical hardware.

Verify state transitions.

This module SHALL be executable in CI.

⸻

Module 5 — Compose the Actuator

Reuse the existing Crossplane course.

Create the Open Engineering actuator claim/XR.

Demonstrate Crossplane composing its dependencies.

⸻

Module 6 — Run It Locally

Reuse:

* Kubernetes course;
* MiniKube course.

Deploy the required Open Engineering runtime locally.

Verify all components.

⸻

Module 7 — Bring the Pico Alive

Reuse the Manifold course.

Register/run the Pico.

Demonstrate event handling.

Execute a simulated nod.

⸻

Module 8 — Build the Edge Adapter

Introduce the ESP32 adapter.

Teach the boundary between:

Open Engineering semantics

and:

device protocol

Implement communication with the actuator.

⸻

Module 9 — Connect the Physical AX-12A

Connect:

ESP32
 ↓
74HCT245
 ↓
AX-12A

Perform:

1. connectivity test;
2. telemetry read;
3. safe-limit configuration;
4. small movement;
5. center;
6. stop test.

Only after these succeed may the nod gesture be enabled.

⸻

Module 10 — Expose the Capability

Connect Home Assistant.

Expose:

NOD
CENTER
STOP

and actuator state.

⸻

Module 11 — Trace the Nod

The learner SHALL trace:

Home Assistant
 ↓
Open Engineering
 ↓
Event
 ↓
Pico
 ↓
Manifold
 ↓
Adapter
 ↓
ESP32
 ↓
Dynamixel
 ↓
AX-12A
 ↓
Lamp

and the telemetry path back.

⸻

Module 12 — Make the Lamp Nod

This is the capstone exercise.

No new major technology SHALL be introduced.

The learner SHALL:

1. open Home Assistant;
2. inspect actuator readiness;
3. press NOD;
4. observe the physical movement;
5. inspect the event trace;
6. inspect updated Pico state.

Success condition:

The physical lamp nods and the complete execution is observable.

⸻

30. Course Prerequisites

The Academy SHALL declare dependencies on existing courses rather than duplicate them.

Recommended prerequisite graph:

Kubernetes
     ↓
MiniKube
     ↓
Crossplane
     │
     ├─────────────┐
     ▼             ▼
Definitions       Pico
     │             │
Conventions       Manifold
     │             │
Rules             │
     └──────┬──────┘
            ▼
      Home Assistant
            │
            ▼
     MAKE THE LAMP NOD

Where the Academy’s actual dependency graph differs, existing canonical courses SHALL take precedence.

⸻

31. Required Cross-References

The implementing AI SHALL search the Open Engineering Academy source for existing material covering:

* Kubernetes;
* MiniKube;
* Crossplane;
* XRD;
* XR;
* Composition;
* Composition Functions;
* Definitions;
* Conventions;
* Parsers;
* Rules;
* Pico;
* Manifold;
* Home Assistant;
* identifiers;
* events;
* messaging;
* robotics.

Existing Academy material SHALL be linked rather than copied whenever possible.

The implementation MUST avoid creating parallel definitions of concepts that already have canonical Academy material.

⸻

32. Repository Structure

The implementing AI SHALL adapt this structure to the existing Academy course conventions.

Conceptually:

courses/
└── make-the-lamp-nod/
    ├── index.qmd
    ├── README.md
    ├── prerequisites.qmd
    ├── architecture.qmd
    │
    ├── modules/
    │   ├── 00-challenge.qmd
    │   ├── 01-physical-system.qmd
    │   ├── 02-capability.qmd
    │   ├── 03-digital-twin.qmd
    │   ├── 04-simulation.qmd
    │   ├── 05-crossplane.qmd
    │   ├── 06-minikube.qmd
    │   ├── 07-manifold.qmd
    │   ├── 08-edge-adapter.qmd
    │   ├── 09-physical-actuator.qmd
    │   ├── 10-home-assistant.qmd
    │   ├── 11-observability.qmd
    │   └── 12-capstone.qmd
    │
    ├── definitions/
    ├── compositions/
    ├── picos/
    ├── rules/
    ├── simulation/
    ├── edge/
    │   └── esp32/
    ├── home-assistant/
    ├── kubernetes/
    ├── tests/
    ├── diagrams/
    └── assets/

If the Academy already defines another course layout, the existing Academy convention SHALL win.

⸻

33. Quarto

The course SHALL integrate with the Academy’s existing Quarto publishing system.

The implementing AI SHALL:

1. inspect the current Academy Quarto structure;
2. follow existing navigation conventions;
3. add the course to the appropriate Academy navigation;
4. preserve existing styling;
5. ensure all internal references resolve;
6. ensure diagrams render correctly;
7. ensure code/configuration examples are syntax highlighted;
8. ensure the complete Academy build remains successful.

The AI MUST NOT introduce a second documentation framework.

⸻

34. Executable Course Philosophy

Where possible, examples SHALL be executable rather than illustrative.

The learner should be able to clone the course material and progress from:

simulation

to:

local runtime

to:

physical hardware

without rewriting the architecture.

⸻

35. Automated Testing

The course implementation SHALL include automated tests for the non-physical portions.

Tests SHALL verify at minimum:

* definitions validate;
* identifiers validate;
* Pico configuration validates;
* Crossplane resources validate;
* simulated actuator accepts commands;
* nod produces the expected state transitions;
* invalid movement is rejected;
* safe limits are enforced;
* unavailable actuator produces an error;
* event correlation works.

⸻

36. Hardware Tests

Hardware tests SHALL be clearly marked and SHALL NOT execute automatically in CI.

Suggested test classes:

unit
integration
simulation
hardware

The default CI pipeline SHALL execute:

unit
integration
simulation

but NOT:

hardware

Hardware tests require explicit opt-in.

⸻

37. Observability

Every nod request SHALL have a correlation identifier.

The learner SHALL be able to follow one request through the system.

Conceptually:

correlation:
01H...XYZ
Home Assistant
     ↓
nod.requested
     ↓
Pico
     ↓
rule.executed
     ↓
actuator.commanded
     ↓
edge.command.sent
     ↓
servo.moving
     ↓
servo.position.changed
     ↓
nod.completed

The course SHOULD expose this trace in a learner-friendly form.

⸻

38. Evidence

Successful execution SHALL generate evidence.

At minimum:

request accepted
event created
rule executed
command sent
physical/simulated movement observed
final state reported
gesture completed

This connects the course to Open Engineering’s evidence-driven design principles.

⸻

39. Failure Scenarios

The course SHALL deliberately teach several failure modes.

At minimum:

Servo unavailable

Expected result:

nod failed:
actuator unavailable

ESP32 disconnected

Expected result:

edge adapter unavailable

Unsafe requested position

Expected result:

command rejected:
outside configured safe limits

Timeout

Expected result:

gesture failed:
actuator did not reach expected state

Runtime unavailable

The capability SHALL report degraded/unavailable rather than pretending execution succeeded.

⸻

40. Desired-State Principle

A central lesson SHALL be:

Requesting motion is not proof that motion occurred.

Therefore:

COMMAND SENT

is not equivalent to:

GESTURE COMPLETED

The system SHALL distinguish:

requested
accepted
executing
completed
failed

This distinction becomes increasingly important as Open Engineering expands into robotics.

⸻

41. Definition of Done — Course

The course SHALL be considered complete only when all of the following are true:

* the course builds successfully in Quarto;
* prerequisite courses are linked;
* concepts are not unnecessarily duplicated;
* the Pico digital twin is implemented;
* the simulated actuator works;
* Crossplane composition works;
* the system runs on MiniKube;
* the Pico executes in the chosen Manifold/Pico runtime;
* events can trigger nod;
* Home Assistant exposes the capability;
* the simulated path works end-to-end;
* ESP32 edge integration is documented and implemented;
* AX-12A communication is implemented;
* safe calibration is documented;
* physical nod works;
* telemetry returns to the digital twin;
* execution is observable;
* automated tests pass;
* hardware tests are opt-in;
* failure scenarios are documented;
* the final capstone produces a physical nod.

⸻

42. Definition of Done — Learner

A learner completes the course when they can demonstrate:

Home Assistant
      ↓
     NOD
      ↓
Open Engineering
      ↓
Pico
      ↓
Manifold
      ↓
ESP32
      ↓
AX-12A
      ↓
physical nod

and explain the responsibility of each layer.

The learner SHALL also demonstrate the simulated implementation.

⸻

43. Architectural Principles

The course SHALL reinforce the following principles.

Composition over duplication

Reuse Academy courses and Open Engineering capabilities.

Semantic interfaces over hardware interfaces

Expose nod, not Dynamixel registers.

Digital twin over remote control

Maintain desired and observed state.

Declarative composition over manual assembly

Use Crossplane.

Runtime behavior separate from infrastructure

Crossplane determines what exists; Manifold/Pico determines what happens.

Edge adapters isolate hardware

ESP32 understands the physical device but not character semantics.

Simulation before physics

Every capability SHOULD be testable without hardware.

Evidence over assumption

A sent command does not prove physical execution.

Safe by design

Physical movement SHALL operate inside explicitly configured boundaries.

Replaceable implementations

The logical head actuator MUST survive replacement of the AX-12A implementation.

⸻

44. Future Expansion

The architecture SHALL intentionally enable later Academy courses.

Multiple actuators

Head Pitch Pico
Head Yaw Pico
Base Rotation Pico
Lamp Arm Pico
Light Pico

Gesture composition

look-left
look-right
nod
shake-head
look-up
look-down
wake-up
sleep

Character embodiment

Character Pico
      ↓
Gesture Planner
      ↓
Actuator Picos

Voice

"Hey A.I."
    ↓
Voice
    ↓
Character
    ↓
Intent
    ↓
Gesture

AI reasoning

Observation
     ↓
LLM / reasoning
     ↓
Character decision
     ↓
gesture intent
     ↓
nod

Choreography

Multiple capabilities can later be coordinated with:

* lighting;
* audio;
* speech;
* projection;
* movement;
* stage cues.

This provides the path from a single actuator toward the complete PixStars performance system.

⸻

45. Strategic Significance

This course should be treated as more than a robotics tutorial.

It establishes an important Open Engineering milestone.

Earlier Academy material can demonstrate:

Definition
    ↓
Composition
    ↓
Runtime
    ↓
Software

This course extends the chain to:

Definition
    ↓
Composition
    ↓
Runtime
    ↓
Event
    ↓
Digital Twin
    ↓
Edge
    ↓
Electronics
    ↓
Actuator
    ↓
Physical World

Open Engineering therefore ceases to be demonstrated only as a way of describing and operating software.

It becomes a method for composing cyber-physical systems.

⸻

46. The Pedagogical Payoff

The course MUST preserve the simplicity of its final moment.

After working through:

* definitions;
* Kubernetes;
* MiniKube;
* Crossplane;
* composition;
* Pico;
* Manifold;
* rules;
* events;
* digital twins;
* edge adapters;
* networking;
* device protocols;
* telemetry;
* Home Assistant;
* observability;

the learner reaches the final exercise.

The dashboard displays:

PixStars Lamp
Status: READY
[ NOD ]

The learner presses:

NOD

The lamp lowers its head.

It raises its head.

It returns to center.

The telemetry updates.

The event trace reports:

nod.completed

That moment is the explanation of why all the preceding abstractions exist.

⸻

47. Instruction to the Implementing AI

When this memo is supplied to an AI responsible for implementing the Open Engineering Academy course, the AI SHALL proceed as follows:

1. Inspect the complete existing Open Engineering Academy repository.
2. Determine the canonical course and Quarto structure.
3. Locate all prerequisite courses and relevant existing lessons.
4. Reuse and cross-reference those lessons rather than duplicating them.
5. Inspect current Open Engineering conventions, identifiers, definitions, Pico, Rules, Crossplane and Manifold implementations.
6. Treat those existing implementations as authoritative where they differ from illustrative syntax in this memo.
7. Create the Make the Lamp Nod course according to Academy conventions.
8. Implement the simulated actuator first.
9. Implement automated tests for the simulation.
10. Implement the Crossplane composition.
11. Implement deployment to MiniKube.
12. Integrate the Pico with Manifold.
13. Implement event-driven nod.
14. Implement the Home Assistant interface.
15. Verify the complete simulated path.
16. Implement the ESP32 edge adapter.
17. Implement the AX-12A adapter using Dynamixel Protocol 1.0.
18. Document the ESP32 → 74HCT245 → AX-12A physical boundary.
19. Implement safe calibration and physical testing instructions.
20. Verify telemetry from the physical actuator.
21. Verify the complete physical execution path.
22. Add observability and correlation.
23. Add failure exercises.
24. Add diagrams.
25. Add course navigation.
26. Run all Academy validation and build processes.
27. Fix all broken references and tests.
28. Verify the Academy can be built from a clean checkout.
29. Verify the course can be completed in simulation without hardware.
30. Verify the course can be completed with the PixStars reference hardware.
31. Document any unavoidable hardware-specific calibration values rather than embedding them into generic definitions.
32. Do not invent alternative Open Engineering concepts where canonical ones already exist.

Where information in the existing Open Engineering repositories is more specific than this memo, existing canonical Open Engineering definitions SHALL win.

Where this memo defines an architectural boundary, that boundary SHALL be preserved unless an existing Architecture Decision Record explicitly supersedes it.

⸻

48. Final Architectural Test

Before declaring implementation complete, the implementing AI SHALL be able to answer every arrow in this diagram:

                    HUMAN
                      │
                      │ nod
                      ▼
               HOME ASSISTANT
                      │
                      │ semantic request
                      ▼
              OPEN ENGINEERING
                      │
                      │ capability/event
                      ▼
                 PICO TWIN
                      │
                      │ rule
                      ▼
                  MANIFOLD
                      │
                      │ actuator command
                      ▼
                EDGE ADAPTER
                      │
                      │ network message
                      ▼
                    ESP32
                      │
                      │ Dynamixel Protocol 1.0
                      ▼
                  74HCT245
                      │
                      │ electrical communication
                      ▼
                   AX-12A
                      │
                      │ rotation
                      ▼
                  LAMP HEAD
                      │
                      ▼
                     NOD
                      │
                      │ telemetry
                      ▼
                   AX-12A
                      │
                      ▼
                    ESP32
                      │
                      ▼
                 PICO TWIN
                      │
                      ▼
               HOME ASSISTANT

For every arrow the course SHALL explain:

* what crosses the boundary;
* who owns the contract;
* how failure is represented;
* how the interaction is tested;
* how the interaction is observed.

If an arrow cannot be explained, tested, or observed, implementation is not yet complete.

⸻

49. Final Vision

The purpose of this course can be summarized in one sentence:

Declare a meaningful capability in Open Engineering and follow it all the way until the physical world changes.

The implementation begins with a modest piece of hardware:

ESP32
  +
74HCT245
  +
AX-12A

Open Engineering turns it into:

a discoverable,
identifiable,
declarative,
composable,
observable,
testable,
safe,
digital-twin-backed
physical capability.

PixStars then gives that capability meaning.

Today:

The human presses NOD.

Tomorrow:

The character decides to nod.

The Academy course SHALL deliberately build the architectural bridge between those two worlds.

And its final acceptance test remains beautifully simple:

The lamp nods.
