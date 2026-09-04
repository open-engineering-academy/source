# Memo 12: Rerun Pico Course Extension

## Course

Open Engineering Academy

## Extension

Visualizing Agent Observations with Rerun

## Format

Pico course extension

## Status

Proposal

⸻

## 1. Overview

This course extension introduces learners to Rerun as a practical visualization and temporal-observation capability for Open Engineering Agents.

Learners build a small agent-enabled system that produces observations and then use Rerun to:

* record observations;
* visualize structured and multimodal data;
* inspect events over time;
* replay system behaviour;
* correlate observations with agent decisions;
* investigate anomalies;
* produce evidence for an engineering investigation.

The course connects AI agents, observation, evidence, visualization, and investigation through a compact hands-on project.

The objective is not to teach Rerun as an isolated visualization product. Instead, learners discover how a temporal visualization system can become part of an agentic engineering workflow.

⸻

## 2. Learning Objective

By completing the extension, learners should understand how to answer:

“What did my agent observe, what happened over time, and why did it make this decision?”

Learners will be able to create a simple pipeline:

System
   ↓
Observations
   ↓
Agent
   ↓
Decisions
   ↓
Rerun Recording
   ↓
Timeline
   ↓
Investigation
   ↓
Evidence

⸻

3. Why Rerun?

AI agents are often presented as systems that receive input, reason, and produce output.

That model becomes insufficient when an agent operates over time.

A real engineering agent may need to understand:

* what happened before an event;
* what changed;
* what the system looked like at a particular moment;
* which observations influenced a decision;
* whether multiple signals changed simultaneously;
* whether a failure can be reproduced.

Rerun provides a visual and temporal representation of these observations.

This makes it a useful educational bridge between agent reasoning and engineering observability.

⸻

4. Target Audience

The extension is aimed at learners who have completed or are familiar with introductory Open Engineering Academy material covering:

* software engineering;
* AI agents;
* APIs;
* basic Python or another supported programming language;
* event-driven systems;
* engineering investigations.

No previous Rerun experience is required.

⸻

5. Course Size

Recommended format:

Pico course: 30–60 minutes

The extension can also be expanded into a larger practical course of approximately 90 minutes.

Suggested structure:

Lesson 1 — Why Visualize Agents?
Lesson 2 — Your First Rerun Recording
Lesson 3 — Recording Agent Observations
Lesson 4 — Exploring the Timeline
Lesson 5 — Investigating an Anomaly
Lesson 6 — Agent + Evidence
Challenge — Build Your Own Agent Investigation

⸻

6. Course Project

The learner builds a small Agent Observation System.

The system generates a stream of observations.

For example:

temperature
position
velocity
confidence
events
agent state
agent decisions

The observations are recorded into Rerun.

The learner then investigates the resulting timeline.

Example:

time ─────────────────────────────────────────>
sensor        ───────╱╲──────╱╲──────────────
confidence    ────────────────╲______________
agent state   IDLE ──► OBSERVE ──► INVESTIGATE
decision                     └────► ACT
event                         anomaly

The learner’s task is to determine why the agent transitioned into the investigation state.

⸻

7. Lesson 1 — Why Visualize Agents?

Objective

Understand why temporal visualization is useful for agentic systems.

Topics

* agents as temporal systems;
* observations;
* events;
* state;
* decisions;
* evidence;
* replay.

Pico activity

Present a simple agent timeline and ask learners to identify:

1. what happened;
2. when it happened;
3. what changed;
4. what decision followed;
5. what evidence supports the decision.

Key concept

An agent does not only produce answers. It continuously operates in a changing environment.

⸻

8. Lesson 2 — Your First Rerun Recording

Objective

Create a basic Rerun recording.

Learners install the Rerun SDK and create a minimal application that records a value over time.

Example conceptual code:

import rerun as rr
rr.init("open-engineering-agent")
rr.connect_grpc()
for step in range(100):
    value = calculate_value(step)
    rr.log(
        "agent/value",
        rr.Scalar(value)
    )

The exact implementation should follow the current Rerun SDK documentation when the course is published.

Pico exercise

Learners modify the program so that the recorded value changes according to an input or simulated process.

⸻

9. Lesson 3 — Recording Agent Observations

Objective

Move from generic telemetry to agent observations.

Learners record multiple streams such as:

agent/state
agent/confidence
agent/decision
sensor/value
environment/value
events

The learner should see that each observation has:

* identity;
* value;
* time;
* context.

Engineering concept

Introduce the Open Engineering distinction between:

Observation → Evidence → Finding

Rerun primarily supports the first two.

The agent is responsible for interpreting them.

⸻

10. Lesson 4 — Exploring the Timeline

Objective

Use Rerun’s temporal capabilities to inspect system behaviour.

Learners explore:

* timelines;
* timestamps;
* entities;
* synchronized observations;
* state changes;
* recorded events.

The exercise asks learners to locate a specific event and inspect what happened immediately before and after it.

Example:

Find the moment when confidence drops below 50%. What other observations changed within the same period?

This introduces temporal correlation as an engineering investigation technique.

⸻

11. Lesson 5 — Investigating an Anomaly

Objective

Use Rerun as an investigation tool.

Provide learners with a recording containing an intentional anomaly.

For example:

Normal operation
       ↓
Sensor drift
       ↓
Confidence decreases
       ↓
Agent changes state
       ↓
Unexpected decision

Learners must identify the root cause.

The lesson teaches that the agent should not simply report:

“An anomaly occurred.”

It should be able to explain:

“The anomaly began after the sensor value deviated from its expected range, causing confidence to fall and triggering the investigation state.”

Rerun provides the visual evidence supporting that explanation.

⸻

12. Lesson 6 — Agent + Evidence

Objective

Connect agent reasoning with recorded evidence.

The learner creates an investigation record containing:

investigation:
  observation:
    source: sensor
    entity: sensor/value
  event:
    type: anomaly
  evidence:
    recording: rerun
    timeline: runtime
    start: ...
    end: ...
  finding:
    ...

The learner sees how a visual recording can become part of a larger engineering investigation.

⸻

13. Challenge — Build Your Own Agent Investigation

Learners receive a simulated system containing an unknown fault.

They must:

1. instrument the system;
2. record observations;
3. run the agent;
4. inspect the Rerun recording;
5. identify the anomaly;
6. determine the likely cause;
7. document the evidence;
8. explain the agent’s resulting decision.

Challenge output

A short investigation report:

Observation
Evidence
Investigation
Finding
Decision

⸻

14. Optional Physical AI Extension

For a more advanced version, the course can introduce multimodal observations.

Learners can record:

* camera images;
* positions;
* trajectories;
* object detections;
* confidence values;
* agent state.

This introduces the relationship between:

Vision
   +
Agent
   +
Environment
   +
Time
   +
Evidence

This extension is particularly relevant to the Open Engineering Vision, Robotics, Simulation, and Character Capsules.

⸻

15. Optional PixStars Extension

A future Academy exercise can use PixStars as an embodied-character example.

The learner records:

character/state
character/emotion
character/attention
lamp/head
lamp/leds
microphone/events
speech/events
mqtt/events

The learner can then inspect the character’s behaviour over time.

Example investigation:

Why did the character change its behaviour?

The learner correlates:

microphone event
       ↓
speech recognition
       ↓
agent decision
       ↓
character state
       ↓
lamp movement
       ↓
LED change

This demonstrates a complete embodied-agent pipeline.

⸻

16. Open Engineering Concepts Introduced

The course should explicitly connect Rerun to Open Engineering concepts.

Observation

Something the system detects or measures.

Event

Something that happens at a particular point in time.

Evidence

Recorded information that can support an engineering conclusion.

Investigation

A structured attempt to understand a system or phenomenon.

Finding

A conclusion derived from observations and evidence.

Agent

A system capable of observing, reasoning, deciding, and acting.

Rerun primarily supports:

Observation
Event
Evidence
Visualization
Replay

while Open Engineering Agents provide:

Reasoning
Investigation
Decision
Execution
Reporting

⸻

17. Architecture

The educational architecture should remain simple.

┌──────────────────────┐
│       Environment    │
└──────────┬───────────┘
           │
       observations
           │
           ▼
┌──────────────────────┐
│        Agent         │
│                      │
│ Observe              │
│ Reason               │
│ Decide               │
└──────────┬───────────┘
           │
        events/state
           │
           ▼
┌──────────────────────┐
│     Rerun Adapter    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│        Rerun         │
│                      │
│ Recording + Viewer   │
└──────────────────────┘

⸻

18. Technology

The initial course should use Python because it provides a low barrier to entry and allows learners to focus on the engineering concepts rather than infrastructure.

Potential future versions can introduce:

* Rust;
* C++;
* robotics frameworks;
* simulation environments;
* MCP;
* Kubernetes;
* Open Engineering Agent runtimes.

The course should avoid unnecessary infrastructure.

The learner should be able to complete the first exercises locally.

⸻

19. Pico Course Design Principles

The extension should follow the Open Engineering Academy Pico philosophy:

Small

Each lesson should teach one meaningful concept.

Practical

Every lesson should result in something observable.

Interactive

Learners should modify code or data rather than only read explanations.

Progressive

Each lesson should build on the previous one.

Agentic

The learner should gradually move from visualization toward autonomous investigation.

Reusable

The resulting instrumentation pattern should be applicable to other Open Engineering projects.

⸻

20. Assessment

Assessment should be practical rather than theoretical.

Possible questions:

Knowledge

What does Rerun provide to an Open Engineering Agent?

Expected concept:

Temporal multimodal recording and visualization of observations and evidence.

Application

An agent made an unexpected decision. What would you inspect first?

Expected answer:

The observations and system state immediately before the decision.

Investigation

Why is a timeline useful to an engineering agent?

Expected answer:

It allows observations and events to be correlated in time and helps establish causal or temporal relationships.

Challenge

Learners successfully identify the cause of a deliberately introduced anomaly and provide evidence from the recording.

⸻

21. Completion Criteria

A learner completes the Pico extension when they can:

* create a Rerun recording;
* log agent observations;
* inspect a timeline;
* identify a system event;
* correlate multiple observations;
* investigate an anomaly;
* associate evidence with an agent finding;
* explain the relationship between Rerun and an Open Engineering Agent.

⸻

22. Future Extensions

The Pico course can become the entry point for larger Academy courses.

Potential follow-up courses:

Rerun for Robotics

Robot state, sensors, trajectories, and simulation.

Rerun for Computer Vision

Images, detections, tracking, segmentation, and model confidence.

Rerun for AI Agents

Agent state, observations, decisions, and tool execution.

Rerun for Simulation

Simulation replay and experiment comparison.

Rerun for Character Systems

Embodied characters and temporal behavioural analysis.

Rerun for Detective OS

Evidence-driven investigation of runtime behaviour.

⸻

23. Open Engineering Academy Positioning

The extension should be positioned as an example of a broader Open Engineering principle:

Make engineering behaviour observable to both humans and agents.

Rerun provides the visual and temporal layer.

Open Engineering Agents provide the reasoning and investigation layer.

Together they create:

Observe
   ↓
Record
   ↓
Visualize
   ↓
Investigate
   ↓
Understand
   ↓
Decide
   ↓
Act

This is a powerful pattern for teaching agentic engineering.

⸻

24. Recommendation

Create “Visualizing Agent Observations with Rerun” as a Pico course extension for Open Engineering Academy.

The initial version should use a small simulated agent and Python.

The course should then provide an optional path toward physical AI and embodied systems, culminating in a PixStars-based example.

Rerun should be introduced not merely as a visualization library, but as an observation, evidence, replay, and investigation capability within an agentic engineering architecture.

⸻

References

* Rerun: https://rerun.io/
* Rerun Documentation: https://rerun.io/docs/
* Rerun GitHub: https://github.com/rerun-io/rerun
