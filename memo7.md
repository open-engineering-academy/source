# Memo 7: Durable Picos with celld

Repository: open-engineering-academy/source  
Proposed course: Durable Picos with celld  
Status: Implementation specification  
Audience: Open Engineering Academy maintainers, course authors, AI coding agents, and learners  
Prerequisites: Existing Open Engineering Academy foundation material and the Hello, Pico! course  
Primary outcome: Extend the existing Hello, Pico! journey so a Pico can execute as a durable, stateful actor using celld while remaining independent of celld at the Open Engineering abstraction level.  

⸻

1. Purpose

Implement a new Open Engineering Academy course teaching how an Open Engineering Pico can be realized as a durable, addressable, persistent actor using celld.

The course MUST build on existing Academy material rather than recreate it.

In particular, reuse the existing Hello, Pico! implementation and the courses/material covering:

* Pico
* Pico Engine/runtime concepts
* Wrangler
* Kubernetes
* Minikube
* Crossplane
* FluxCD where applicable
* Manifold
* Home Assistant
* Open Engineering Definitions
* Open Engineering Conventions
* Open Engineering metadata and identifiers
* Open Engineering observability concepts

The learner should start with the familiar:

Hello, Pico!

and progressively transform its runtime realization into:

Hello, Pico!
      │
      ▼
Open Engineering Pico
      │
      ▼
Pico Runtime SPI
      │
      ▼
celld Runtime Adapter
      │
      ▼
celld Cell / Durable Object
      │
      ├── Identity
      ├── State
      ├── SQLite
      ├── RPC / HTTP
      ├── Alarms
      └── WebSockets

The most important architectural lesson is:

Pico is the Open Engineering abstraction. celld is one possible runtime implementation.

The course MUST NOT redefine Pico in terms of celld or Cloudflare Durable Objects.

⸻

2. Why this course exists

celld is a self-hosted implementation of significant parts of the Cloudflare Workers and Durable Objects programming model.

Reference:

* celld: https://github.com/denoland/celld
* celld documentation: https://github.com/denoland/celld/tree/main/docs
* Background article: https://www.devclass.com/devops/2026/08/13/nodejs-creator-liberates-durable-objects-from-cloudflare-with-celld/5287580

A celld cell has properties that map naturally onto Open Engineering Pico concepts:

Open Engineering	celld
Pico	Cell / Durable Object
Pico identity	Cell identity/address
Pico state	Durable state
Pico runtime	V8 isolate / Worker runtime
Pico persistence	SQLite
Pico event	Request, RPC, alarm, WebSocket event
Pico communication	HTTP, RPC, WebSocket
Pico suspension	Hibernation
Durable Pico storage	SQLite replicated to S3-compatible storage
Wrangler	Worker application packaging
Kubernetes	celld runtime hosting
Crossplane	Declarative runtime/infrastructure provisioning
Manifold	Observation and engineering representation
Home Assistant	Physical-world interaction and monitoring

This makes celld an excellent vehicle for teaching an important Open Engineering principle:

separate the engineering model from its runtime realization.

⸻

3. Course title

Use:

Durable Picos with celld

Suggested subtitle:

From “Hello, Pico!” to a persistent, addressable, hibernating actor.

Do not title the course “celld Picos” or otherwise imply that Picos depend on celld.

⸻

4. Position within the Academy

The course should form part of a progression rather than exist as an isolated tutorial.

Recommended learning path:

Open Engineering Foundations
        │
        ▼
Kubernetes / Minikube
        │
        ▼
Crossplane
        │
        ▼
Pico Fundamentals
        │
        ▼
Hello, Pico!
        │
        ▼
Durable Picos with celld
        │
        ├───────────────┐
        ▼               ▼
Pico Runtime       Distributed Picos
Architecture
        │
        ▼
Physical/Digital Twins

Where prerequisite courses already teach concepts sufficiently, link to those lessons rather than duplicate their content.

⸻

5. Learning objectives

At completion, a learner MUST be able to:

1. Explain what a Pico is.
2. Explain the difference between a Pico and its runtime.
3. Explain the actor model in the context of Picos.
4. Explain what celld provides.
5. Explain the relationship between a celld cell and a Durable Object.
6. Explain why celld is an implementation option rather than part of the Pico definition.
7. Run celld locally.
8. package suitable runtime logic for celld.
9. deploy the Hello, Pico! example through the celld runtime adapter.
10. address an individual Pico instance.
11. send events to it.
12. persist Pico state.
13. restart the runtime without losing durable state.
14. demonstrate Pico hibernation/reactivation where supported.
15. inspect the Pico’s SQLite-backed state.
16. expose useful Pico state through Open Engineering observation mechanisms.
17. run the runtime on Minikube.
18. provision relevant runtime infrastructure declaratively using Crossplane.
19. understand how S3-compatible storage participates in durable/distributed celld operation.
20. understand the security boundaries involved.
21. distinguish Open Engineering APIs from celld-specific APIs.
22. replace the celld adapter without changing the Pico’s engineering definition.

⸻

6. Reuse the existing Hello, Pico!

Do NOT create an unrelated sample application.

The course MUST reuse and evolve the existing Academy Hello, Pico! example.

The existing Pico contains state conceptually equivalent to:

pub struct PicoState {
    pub id: String,
    pub version: String,
    pub status: String,
    pub message: String,
    pub event_count: u64,
    pub last_run: Option<DateTime<Utc>>,
}

and behavior equivalent to:

hello(name)

Each invocation:

1. receives an event;
2. increments event_count;
3. records last_run;
4. produces a greeting;
5. exposes the resulting Pico state.

The durable course extends this behavior rather than replacing it.

⸻

7. The experiment

The central course experiment should be extremely easy to understand.

Initially:

POST hello
     │
     ▼
Hello Pico
     │
     ▼
event_count = 1

Call again:

event_count = 2

Then deliberately terminate/restart the runtime.

Call again:

event_count = 3

The learner has now demonstrated the essential property:

Pico state belongs logically to the Pico and survives the lifecycle of an individual execution context.

This simple experiment should anchor the entire course.

⸻

8. Target architecture

The completed lab should resemble:

                    Open Engineering
                           │
                    Pico Definition
                           │
                           ▼
                   Pico Runtime SPI
                           │
                           ▼
                 celld Runtime Adapter
                           │
                           ▼
                    celld Runtime
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
           Pico A       Pico B       Pico C
              │            │            │
              ▼            ▼            ▼
           SQLite       SQLite       SQLite
              │            │            │
              └────────────┼────────────┘
                           ▼
                  S3-compatible storage

When deployed locally:

Mac
 │
 ▼
Minikube
 │
 ├── Crossplane
 │
 ├── FluxCD                    optional where already taught
 │
 ├── celld
 │    └── Hello Pico
 │
 ├── Manifold
 │
 └── Home Assistant

The implementation MUST remain usable without Home Assistant so that Home Assistant is an integration exercise rather than a hard runtime dependency.

⸻

9. Pico Runtime SPI

A key deliverable of this course should be an explicit runtime boundary.

Conceptually:

Pico
 │
 ▼
PicoRuntime
 │
 ├── NativeRuntime
 │
 └── CelldRuntime

The exact interface should follow existing Open Engineering conventions, but conceptually it needs operations such as:

deploy
start
invoke
inspect
suspend
resume
delete

Not every runtime needs to implement these operations identically.

Capabilities should therefore be discoverable rather than assumed.

For example:

runtime:
  class: durable
capabilities:
  - persistence
  - rpc
  - alarms
  - websocket
  - hibernation

Do not leak celld-specific configuration into the generic Pico model unless it is placed explicitly inside an implementation-specific extension.

⸻

10. Runtime selection

Prefer a semantic runtime request such as:

spec:
  runtime:
    class: durable

rather than:

spec:
  runtime:
    implementation: celld

The platform should be able to resolve:

durable
   │
   ▼
runtime policy
   │
   ▼
celld

This permits future alternatives:

Pico
 │
 ▼
runtime class
 │
 ├── native
 ├── durable
 ├── wasm
 ├── edge
 └── embedded

without altering the Pico abstraction.

An implementation override MAY be provided for development/testing where useful.

⸻

11. Course modules

Implement the course as a sequence of practical modules.

Module 1 — Revisit Hello, Pico!

Reuse the existing course.

Learners should:

* run Hello, Pico!;
* execute its tests;
* invoke hello;
* inspect PicoState;
* observe event_count;
* understand last_run.

Do not reteach Rust fundamentals here.

⸻

Module 2 — State versus process

Introduce the problem:

Process dies
     │
     ▼
What happens to Pico state?

Have the learner intentionally restart the existing implementation and observe what happens.

Introduce:

* volatile state;
* durable state;
* runtime lifecycle;
* entity lifecycle.

Establish:

Entity lifetime and process lifetime are different concerns.

⸻

Module 3 — Actor-oriented Picos

Introduce only the actor-model concepts necessary for the course:

          message
             │
             ▼
        ┌─────────┐
        │  Pico   │
        │         │
        │  state  │
        └─────────┘
             │
             ▼
          response

Teach:

* identity;
* encapsulated state;
* message/event handling;
* serialized execution;
* location transparency;
* lifecycle independence.

Relate these concepts to the Pico material already present in the Academy.

⸻

Module 4 — Meet celld

Introduce celld.

Explain:

* cells;
* Workers;
* Durable Objects;
* V8 isolates;
* SQLite;
* S3-compatible persistence;
* hibernation;
* routing;
* RPC;
* WebSockets;
* alarms.

Also explicitly discuss what celld does not attempt to implement from the wider Cloudflare platform.

celld must be labelled an evolving/experimental dependency.

⸻

Module 5 — Run celld locally

Learners run celld in the simplest supported development configuration.

Provide reproducible scripts.

Prefer:

make celld-up
make celld-status
make celld-logs
make celld-down

or the Academy’s existing task-runner convention.

Avoid requiring learners to memorize long command lines.

⸻

Module 6 — Package Hello, Pico!

Adapt the existing Hello, Pico! behavior into a celld-compatible runtime bundle.

The engineering behavior MUST remain recognizably identical.

Expose operations such as:

GET  /state
POST /hello

Example:

{
  "name": "Willem"
}

Response:

{
  "id": "hello-pico",
  "status": "ready",
  "message": "Hello, Willem!",
  "event_count": 1
}

The exact transport format may evolve, but course tests should validate behavior independently of implementation details.

⸻

Module 7 — Durable state

Move PicoState into durable storage.

Teach how the Pico’s logical state maps onto celld’s SQLite-backed persistence.

Repeat calls:

1 → 2 → 3 → 4

Restart celld.

Then verify:

5

This is the first major course milestone.

⸻

Module 8 — Multiple Pico identities

Create multiple instances:

hello-pico/alice
hello-pico/bob
hello-pico/charlie

Demonstrate:

Alice.event_count   = 7
Bob.event_count     = 2
Charlie.event_count = 15

Restart infrastructure and verify isolation and persistence.

Teach that:

same code
+
different identity
=
different Pico

⸻

Module 9 — Events and RPC

Teach Pico-to-Pico interaction.

For example:

Greeter Pico
     │
     │ hello("Bob")
     ▼
Counter Pico

The course should reuse existing Open Engineering event/messaging conventions where available.

Do not invent a second incompatible event format.

⸻

Module 10 — Alarms

Add a scheduled event.

Example:

Hello Pico
    │
    ├── receive event
    │
    ├── persist state
    │
    └── schedule alarm
               │
               ▼
          future event

Use this to demonstrate that a Pico does not need a continuously active process merely to represent future behavior.

⸻

Module 11 — Hibernation

Where supported by the current celld version, demonstrate:

active
  │
  ▼
idle
  │
  ▼
hibernated
  │
incoming event
  ▼
reactivated
  │
  ▼
state restored

The learner should understand the distinction between:

* Pico existence;
* Pico state;
* Pico execution;
* Pico process/resource consumption.

⸻

Module 12 — Containerize celld

Provide a container-based deployment.

Required artifacts should include, where applicable:

Dockerfile
compose.yaml
.env.example
Makefile

Never commit credentials.

The container exercise should also provide the simplest possible local reproducibility path.

⸻

Module 13 — Deploy to Minikube

Reuse the Academy’s existing Minikube course.

Do not repeat Minikube installation instructions unnecessarily.

Deploy:

Minikube
   │
   ├── celld
   └── Hello Pico bundle

Verify the same behavioral tests used locally.

⸻

Module 14 — Crossplane

Reuse the existing Crossplane course.

The desired learner-facing abstraction should be approximately:

apiVersion: pico.open-engineering.io/v1alpha1
kind: Pico
metadata:
  name: hello-pico
spec:
  runtime:
    class: durable
  state:
    persistence: durable
  capabilities:
    - rpc
    - alarms
    - websocket

The exact schema MUST defer to the current Open Engineering Pico conventions.

Crossplane should translate desired engineering state into runtime infrastructure.

Conceptually:

Pico Claim
    │
    ▼
Composite Resource
    │
    ▼
Composition
    │
    ├── celld resources
    ├── Service
    ├── storage
    ├── Secrets
    ├── NetworkPolicy
    └── observability

⸻

12. Storage

Introduce S3-compatible storage only after local persistence has been understood.

The course should support a local S3-compatible implementation where appropriate so the complete exercise can remain self-hosted.

The architecture becomes:

Minikube
 │
 ├── celld-1 ─────┐
 │                │
 ├── celld-2 ─────┼──► S3-compatible storage
 │                │
 └── celld-3 ─────┘

Do not initially require a multi-node deployment.

That should be an advanced exercise.

⸻

13. Distributed Pico exercise

An advanced module should demonstrate runtime relocation/failure.

For example:

Pico A
  │
  ▼
celld node 1

Terminate node 1.

Then demonstrate, where current celld capabilities permit:

Pico A
  │
  ▼
celld node 2
  │
  ▼
restored durable state

Explain the role of ownership coordination and S3-compatible persistence.

Do not claim stronger consistency, availability, failover, or disaster-recovery properties than the tested celld version actually provides.

⸻

14. Manifold integration

Reuse the existing Manifold course/material.

The learner should be able to observe the Pico conceptually as:

Hello Pico
├── identity
├── runtime
├── status
├── version
├── event count
├── last event
├── last activation
├── persistence status
└── runtime location

Keep engineering state separate from runtime telemetry.

The learner should understand:

desired state
observed state
runtime state
historical evidence

as distinct concepts.

⸻

15. Home Assistant integration

Reuse the existing Hello, Pico! → Home Assistant material.

Do not build a new Home Assistant integration from scratch if an existing one can be extended.

Expose useful state such as:

sensor.hello_pico_event_count
sensor.hello_pico_status
sensor.hello_pico_last_run

and an action such as:

Hello Pico

This creates an end-to-end demonstration:

Home Assistant
      │
      ▼
Open Engineering interface
      │
      ▼
Hello Pico
      │
      ▼
celld
      │
      ▼
SQLite

Restart the Pico runtime and demonstrate that Home Assistant subsequently observes the restored state.

⸻

16. Observability

Expose appropriate runtime metrics.

At minimum consider:

pico_invocations_total
pico_errors_total
pico_activation_total
pico_last_activation_timestamp
pico_runtime_status

celld-specific metrics should use an implementation-specific namespace where appropriate.

For example:

celld_*

Do not disguise implementation telemetry as universal Pico semantics.

⸻

17. Evidence

Because Open Engineering treats evidence as a first-class concern, every major lab milestone should produce machine-verifiable evidence.

Examples:

evidence/
├── tests/
├── deployment/
├── persistence/
├── restart/
├── multi-pico/
└── observability/

A successful course run should prove:

Pico deployed
Pico invoked
state changed
state persisted
runtime restarted
state recovered
Pico invoked again
state advanced

Prefer automated assertions over screenshots.

⸻

18. Testing strategy

Tests MUST be layered.

Unit tests

Test Pico behavior independently from celld.

Example:

new Pico
→ event_count == 0
hello()
→ event_count == 1
hello()
→ event_count == 2

Runtime contract tests

Run the same contract against each runtime implementation.

Conceptually:

Pico Runtime Contract
        │
        ├── NativeRuntime
        │       PASS
        │
        └── CelldRuntime
                PASS

This is crucial.

It proves that celld implements Pico semantics rather than redefining them.

Integration tests

Test:

Pico
→ adapter
→ celld
→ SQLite

Persistence tests

Test:

invoke
invoke
restart runtime
invoke

Expected count:

3

Kubernetes tests

Run the same behavioral contract after deployment to Minikube.

⸻

19. Failure exercises

The course should intentionally break things.

Include exercises such as:

Kill the runtime

Expected:

runtime disappears
state survives
runtime returns
Pico continues

Send malformed input

Expected:

error
+
Pico remains healthy

Create two Pico identities

Expected:

state remains isolated

Remove a runtime instance

Expected behavior must be documented and tested.

Make storage unavailable

Observe and explain the actual celld behavior rather than hiding it.

This teaches engineering rather than merely demonstrating a happy path.

⸻

20. Security

Include a dedicated security module.

Cover at least:

* Pico identity;
* authentication;
* authorization;
* network isolation;
* Kubernetes NetworkPolicy;
* secrets;
* storage credentials;
* container privileges;
* Worker isolation;
* untrusted code;
* API exposure;
* supply-chain provenance.

Explicitly distinguish:

Pico identity

from:

human/service authentication identity

They are related but not necessarily identical.

⸻

21. Sandcastle relationship

Where the Academy already teaches Open Engineering Sandcastles, connect the concepts.

A useful mental model is:

Sandcastle
    │
    ▼
controlled experimental environment
    │
    ▼
celld
    │
    ▼
experimental Pico runtime

A Sandcastle can therefore provide a safe environment for evaluating new Pico runtime implementations without promoting them immediately into the stable platform.

Do not make Sandcastle mandatory for the introductory exercises.

⸻

22. Wrangler relationship

Wrangler should be taught as packaging/developer tooling rather than as the Pico abstraction.

The separation should remain:

Pico definition
      │
      ▼
runtime adapter
      │
      ▼
Wrangler-compatible bundle
      │
      ▼
celld

This allows Open Engineering tooling eventually to generate or manage the required runtime artifacts.

⸻

23. Suggested repository structure

Follow existing Academy conventions first.

Where no convention already dictates otherwise, use approximately:

courses/
└── durable-picos-with-celld/
    ├── README.md
    ├── course.yaml
    ├── modules/
    │   ├── 01-hello-pico/
    │   ├── 02-state-and-process/
    │   ├── 03-actors/
    │   ├── 04-celld/
    │   ├── 05-local-runtime/
    │   ├── 06-package-pico/
    │   ├── 07-durable-state/
    │   ├── 08-multiple-picos/
    │   ├── 09-events-rpc/
    │   ├── 10-alarms/
    │   ├── 11-hibernation/
    │   ├── 12-containers/
    │   ├── 13-minikube/
    │   ├── 14-crossplane/
    │   ├── 15-storage/
    │   ├── 16-manifold/
    │   ├── 17-home-assistant/
    │   ├── 18-observability/
    │   └── 19-capstone/
    │
    ├── examples/
    │   └── hello-pico/
    │
    ├── runtime/
    │   └── celld/
    │
    ├── kubernetes/
    ├── crossplane/
    ├── tests/
    ├── evidence/
    ├── compose.yaml
    ├── .env.example
    └── Makefile

Do not duplicate source from another Academy course merely to obtain this layout.

Prefer reusable packages, references, imports, shared examples, or generated course assets.

⸻

24. Course metadata

The course MUST participate in the existing Open Engineering metadata ecosystem.

Use the current schemas and conventions from the appropriate Open Engineering organizations rather than creating a course-local schema.

Metadata should make relationships discoverable, including:

Durable Picos with celld
    │
    ├── builds-on → Hello, Pico!
    ├── uses → Pico
    ├── uses → Wrangler
    ├── uses → celld
    ├── uses → Kubernetes
    ├── uses → Minikube
    ├── uses → Crossplane
    ├── integrates → Manifold
    └── integrates → Home Assistant

These relationships should consequently become visible through the Open Engineering Map where supported.

⸻

25. Pin dependencies

celld is evolving.

The course MUST NOT silently depend on latest.

Pin:

* celld version;
* container image;
* relevant Worker/Wrangler dependencies;
* Kubernetes dependencies where appropriate;
* Crossplane dependencies;
* other reproducibility-critical tooling.

Record these versions in a machine-readable location.

Renovation/upgrades should be deliberate and accompanied by tests.

⸻

26. Compatibility boundary

Create a small compatibility document such as:

CELLD_COMPATIBILITY.md

Record:

celld version
supported features
unsupported features
known limitations
tested platform
tested Kubernetes version
tested architecture
last verification date

This is particularly important because celld is young and evolving.

⸻

27. Capstone

The final exercise should require no new conceptual machinery.

The learner creates:

hello-pico/alice
hello-pico/bob

Then:

Alice → hello × 3
Bob   → hello × 7

Verify:

Alice.event_count == 3
Bob.event_count   == 7

Restart celld.

Verify again.

Then invoke each once.

Expected:

Alice.event_count == 4
Bob.event_count   == 8

Expose the result through Manifold.

Optionally expose it through Home Assistant.

This demonstrates:

* identity;
* actors;
* state isolation;
* persistence;
* runtime independence;
* infrastructure provisioning;
* observation.

⸻

28. Advanced challenge

After the main course, offer:

Build a physical Pico

Reuse the existing Academy material around physical/digital twins.

For example:

AX-12A Servo
      │
      ▼
Servo Pico
      │
      ▼
celld
      │
      ▼
durable desired state

The Pico might retain:

{
  "id": "lamp-head-servo",
  "desired_angle": 15,
  "last_angle": 12,
  "movement_count": 148,
  "status": "ready"
}

Home Assistant issues:

nod

The Pico records the desired behavior and an edge/physical adapter performs the hardware action.

This connects the course directly to the Academy’s existing physical engineering exercises without making physical hardware necessary for completing the core course.

⸻

29. Architecture principle to reinforce

Throughout the course repeat the architectural layering:

WHAT
│
├── Pico
│
▼
HOW
│
├── Runtime SPI
│
├── celld adapter
│
├── celld
│
├── SQLite
│
└── S3
│
▼
WHERE
│
├── container
├── Minikube
└── Kubernetes

The learner should leave understanding that these are independent engineering decisions.

⸻

30. What NOT to do

The implementation MUST NOT:

* redefine Pico as a Durable Object;
* require Cloudflare;
* expose celld configuration throughout the Pico domain model;
* duplicate the Hello, Pico! course;
* duplicate the Kubernetes course;
* duplicate the Crossplane course;
* make Home Assistant mandatory;
* make Manifold a runtime dependency;
* require physical hardware;
* depend on floating latest versions;
* hide experimental celld limitations;
* create a parallel Open Engineering event schema;
* create new metadata conventions where existing conventions apply;
* treat screenshots as sufficient test evidence;
* claim unsupported celld capabilities.

⸻

31. Definition of Done

The course is complete when a fresh learner environment can execute:

Hello, Pico!
      │
      ▼
deploy
      │
      ▼
celld
      │
      ▼
invoke
      │
      ▼
persist
      │
      ▼
restart
      │
      ▼
recover
      │
      ▼
invoke
      │
      ▼
observe

and automated tests prove the behavior.

The implementation must additionally demonstrate:

* at least two independent Pico identities;
* isolated durable state;
* runtime restart;
* state recovery;
* Minikube deployment;
* declarative Crossplane provisioning;
* runtime contract testing;
* evidence generation;
* Open Engineering metadata;
* links to reused Academy courses;
* documented celld compatibility.

⸻

32. Desired final learner insight

The course should culminate in one realization:

A Pico is not a container.
A Pico is not a process.
A Pico is not a Kubernetes Pod.
A Pico is not a Durable Object.
A Pico is not celld.
              Pico
                │
                ▼
        engineering entity
                │
                ▼
           Runtime SPI
          ╱      │      ╲
         ╱       │       ╲
     Native    celld     future
                │
                ▼
          Durable Actor

celld gives Open Engineering a particularly interesting implementation of the Pico runtime model: small, individually addressable, stateful actors whose logical lifetime can be independent of the processes and machines executing them.

The Academy course should teach both how to build that system and, more importantly, why the abstraction boundary matters.

⸻

33. Implementation instruction

The Open Engineering Academy implementation agent should begin by inventorying the existing Academy material before writing new content.

For every planned lesson, classify the material as:

REUSE
EXTEND
REFERENCE
NEW

Prefer them in that order.

In particular, locate the canonical Hello, Pico! implementation and make it the course’s executable starting point.

Then implement the smallest vertical slice first:

existing Hello, Pico!
        ↓
celld adapter
        ↓
local celld
        ↓
durable event_count
        ↓
restart
        ↓
state recovery
        ↓
automated test

Only after this slice passes should the implementation proceed to:

multiple identities
        ↓
alarms / RPC
        ↓
containers
        ↓
Minikube
        ↓
Crossplane
        ↓
Manifold
        ↓
Home Assistant
        ↓
advanced distributed exercises

This first vertical slice is the acceptance gate for adopting celld as an Academy-supported experimental Pico runtime.

The course should therefore result not merely in documentation, but in a working, tested reference implementation of the Open Engineering Pico Runtime SPI using celld.
:::
