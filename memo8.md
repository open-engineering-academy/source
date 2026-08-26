# Memo 8 — Giving Picos Hands

Project: Open Engineering Picos  
Domain: Pico Architecture  
Status: Proposal  
Version: 1.0  
Date: 2026-08-26  

⸻

## Purpose

This memo proposes introducing Hands as a first-class capability of an Open Engineering Pico.

A Pico can reason, observe, remember, communicate, and make decisions. To affect systems outside itself, however, it also needs a controlled mechanism for taking action.

We call this capability:

`Pico Hands`

The initial external Hands provider should be Composio, while the Pico architecture must remain independent of Composio or any other particular tool provider.

The resulting principle is:

A Composer equips a Pico with Hands. The Pico decides when to use them. The Hands perform the action.

This capability should also become part of the Open Engineering Academy’s teaching model for Picos.

⸻

## Context

Open Engineering already treats a Pico as more than a conventional application or service.

A Pico is a small autonomous engineering entity with identity, behaviour, rules, state, communication, and runtime capabilities.

As Picos become increasingly agentic, they also need to interact with systems such as:

* GitHub
* Gmail
* Slack
* issue trackers
* cloud services
* APIs
* Kubernetes
* Crossplane
* local filesystems
* command-line tools
* MQTT
* Home Assistant
* hardware
* robotics

These interactions should not be implemented as arbitrary integrations embedded throughout Pico business logic.

They represent a distinct architectural responsibility:

acting upon the world.

⸻

## The Pico Metaphor

The existing Pico character provides a useful way to communicate the architecture.

A Pico can conceptually have:
```
Pico
│
├── Identity
│
├── Mind
│   ├── reasoning
│   ├── rules
│   ├── memory
│   └── decision making
│
├── Senses
│   ├── observations
│   ├── events
│   └── triggers
│
├── Voice
│   ├── messaging
│   ├── reporting
│   └── communication
│
└── Hands
    ├── tool discovery
    ├── authorization
    ├── authentication
    └── execution
```
This gives the Pico character an architectural vocabulary:

| Metaphor | Responsibility |  
| Identity | Who am I? |  
| Senses | What is happening? |  
| Mind | What does this mean and what should I do? |  
| Voice | What should I communicate? |  
| Hands | What should I change or execute? |  

The distinction between Mind and Hands is particularly important.

The Mind determines:

Should I do this?

The Hands determine:

How do I do this?

⸻

## Architectural Principle

Picos MUST NOT be architecturally dependent upon Composio.

Instead, Open Engineering should define the abstract capability:

Pico Hands

Composio becomes one implementation of that capability:
```
Pico
 │
 ▼
Hands
 │
 ├── ComposioHands
 ├── LocalHands
 ├── KubernetesHands
 └── PhysicalHands
```
This follows the Open Engineering principle of separating Definition from Implementation.

⸻

## Hands Providers

A Pico may have one or more Hands providers.

Composio Hands

Composio should initially provide access to external SaaS and API-based systems.

Examples include:
```
ComposioHands
├── GitHub
├── Gmail
├── Slack
├── Linear
├── Notion
├── Google services
└── other supported integrations
```
Composio provides capabilities such as:

* tool discovery
* tool schemas
* external account connections
* OAuth handling
* credential lifecycle management
* tool execution
* agent-oriented integrations

Composio documentation:

* https://docs.composio.dev/
* https://docs.composio.dev/docs/authentication
* https://docs.composio.dev/reference/api-reference/tools

Composio should therefore be regarded as the initial external Hands provider for Picos.

⸻

## Local Hands

Some Pico actions do not require an external SaaS integration.

A local Hands provider could expose controlled operations such as:
```
LocalHands
├── filesystem
├── process execution
├── Python
├── Rust
├── SQL
└── local APIs
```
These capabilities require especially strong sandboxing and authorization.

A Pico MUST NOT automatically gain unrestricted host access simply because it has Local Hands.

⸻

## Kubernetes Hands

Picos operating within Open Engineering infrastructure may require Kubernetes-native capabilities.

For example:
```
KubernetesHands
├── Kubernetes API
├── Crossplane
├── FluxCD
├── Custom Resources
└── Open Engineering runtime APIs
```
This is particularly relevant to the existing Pico deployment model involving:
```
Pico
  ↓
Crossplane
  ↓
Kubernetes
  ↓
Manifold / runtime environment
```
Hands provide the action boundary through which the Pico requests changes to its runtime environment.

⸻

## Physical Hands

The abstraction should deliberately extend beyond software.

A Pico may eventually operate physical systems.

Examples include:
```
PhysicalHands
├── MQTT
├── GPIO
├── serial
├── Dynamixel
├── sensors/actuators
├── robotics
└── Home Assistant
```
A Pico could therefore use exactly the same conceptual architecture to:

* create a GitHub issue;
* send an email;
* deploy a Kubernetes resource;
* publish an MQTT message;
* turn on a light;
* move a servo.

The action mechanism changes.

The Pico model does not.

⸻

## Composer Responsibility

This proposal also clarifies the relationship between Composers and Picos.

A Composer should not itself be considered the owner of the Hands.

Instead:

A Composer equips a Pico with capabilities.

Conceptually:
```
Composer
    │
    │ composes
    ▼
Pico
├── Identity
├── Mind
├── Senses
├── Voice
└── Hands
     │
     ├── ComposioHands
     ├── KubernetesHands
     └── ...
```
The Composer may determine:

* which Hands providers are available;
* which toolkits are enabled;
* which capabilities are permitted;
* which policies apply;
* which credentials may be referenced;
* which runtime configuration is required.

The resulting Pico then uses those capabilities during execution.

⸻

## Responsibility Separation

The architecture should maintain the following separation:
```
Composer
   │
   │ What capabilities should this Pico have?
   ▼
Pico
   │
   │ Should I perform this action?
   ▼
Policy / Rules / Identity
   │
   │ Am I allowed?
   ▼
Hands
   │
   │ How can the action be performed?
   ▼
Provider
   │
   │ Execute
   ▼
External World
```
For Composio:
```
Pico
  │
  ▼
Pico Hands
  │
  ▼
ComposioHands
  │
  ▼
Composio Session
  │
  ▼
Connected Account
  │
  ▼
External Service
```
⸻

## Identity Before Action

Hands MUST integrate with Pico identity.

The fundamental security rule should be:

No Hand acts without identity and authorization context.

A conceptual action request might look like:
```
actor:
  pico: pico.example
principal:
  type: user
  id: user.example
action:
  provider: composio
  tool: GMAIL_SEND_EMAIL
authorization:
  capability: gmail.send
```
The Pico is therefore not merely saying:

Send this email.

It is saying:
```
I am Pico X.
I am acting within this identity context.
My rules permit this capability.
My Hands provider can perform it.
Execute the requested action.
```
⸻

## Authorization Boundary

Authentication and authorization MUST remain conceptually separate.

Composio may answer:

Can this connected account authenticate to Gmail?

Open Engineering must answer:

Is this Pico permitted to send this email?

Therefore:
```
Open Engineering
      │
      ├── Identity
      ├── Rules
      ├── Policy
      ├── Capability authorization
      └── Evidence
             │
             ▼
          Hands
             │
             ▼
          Composio
             │
             ▼
       External System
```
A valid credential MUST NOT imply authorization.

⸻

## Capability Model

Hands should expose capabilities, not merely provider-specific tool names.

For example:
```
github.issue.create
github.issue.read
email.read
email.send
messaging.post
kubernetes.resource.read
kubernetes.resource.apply
mqtt.publish
servo.position.set
```
A provider can map these capabilities onto implementation-specific operations.

For example:
```
email.send
     │
     ▼
ComposioHands
     │
     ▼
GMAIL_SEND_EMAIL
```
This keeps Pico rules independent from Composio’s API vocabulary.

⸻

## Proposed Hands Interface

The first implementation should remain deliberately small.

Conceptually:
```
class Hands:
    def capabilities(self) -> list[Capability]:
        ...
    def can(self, capability: str) -> bool:
        ...
    def execute(
        self,
        capability: str,
        arguments: dict,
        context: ExecutionContext,
    ) -> Result:
        ...
```
Provider implementations might include:
```
class ComposioHands(Hands):
    ...
class KubernetesHands(Hands):
    ...
class LocalHands(Hands):
    ...
class MQTTHands(Hands):
    ...
```
The precise language-level API should be established separately from this architectural proposal.

⸻

## Execution Lifecycle

Every Hands operation should follow a standard lifecycle.
```
Observe
   │
   ▼
Investigate
   │
   ▼
Decide
   │
   ▼
Request Action
   │
   ▼
Identify Actor
   │
   ▼
Authorize Capability
   │
   ▼
Select Hand
   │
   ▼
Select Provider
   │
   ▼
Execute
   │
   ▼
Observe Result
   │
   ▼
Record Evidence
   │
   ▼
Emit Event
```
This aligns Hands with existing Open Engineering primitives rather than introducing a parallel agent framework.

⸻

## Evidence

Every significant Hand action SHOULD generate evidence.

For example:
```
execution:
  id: 01K...
actor:
  pico: pico.example
capability:
  email.send
provider:
  composio
tool:
  GMAIL_SEND_EMAIL
requested_at: ...
authorized_at: ...
executed_at: ...
status: succeeded
```
Sensitive values, credentials, access tokens, message contents, and secrets MUST NOT automatically be included in evidence.

Evidence should describe the execution sufficiently for auditing without becoming a credential or data leakage mechanism.

⸻

## Events

Hands operations should produce events.

Examples:
```
pico.hand.requested
pico.hand.authorized
pico.hand.denied
pico.hand.executing
pico.hand.succeeded
pico.hand.failed
```
These events allow other Open Engineering components to observe Pico behaviour without coupling themselves to Composio or another provider.

⸻

## Rules

Hands should integrate directly with Pico rulesets.

Example:
```
rules:
  - capability: email.send
    effect: allow
  - capability: github.issue.create
    effect: allow
  - capability: kubernetes.resource.delete
    effect: deny
```
More sophisticated rules could later constrain:

* destinations;
* repositories;
* namespaces;
* time windows;
* environments;
* resource types;
* monetary limits;
* required approvals;
* rate limits.

For example:
```
capability: kubernetes.resource.apply
constraints:
  namespaces:
    - pico-*
  environments:
    - development
    - test
```
This turns Hands into governed execution, rather than unrestricted tool calling.

⸻

## Human Approval

Some Hands operations should support approval gates.

For example:
```
Pico decides action
       │
       ▼
Rules evaluate
       │
       ▼
Approval required?
   │           │
  no          yes
   │           │
   │        Human
   │        approval
   │           │
   └─────┬─────┘
         ▼
       Hands
         │
         ▼
      Execute
```
Potential examples include:

* sending external communications;
* deleting resources;
* production deployments;
* financial actions;
* destructive filesystem operations;
* security changes.

The Hands architecture should therefore support future human-in-the-loop execution without requiring providers themselves to implement the policy.

⸻

## Composio Implementation

The initial implementation should introduce a ComposioHands provider.

Its responsibilities should include:

1. establish or obtain a Composio session;
2. discover permitted tools;
3. map Pico capabilities onto Composio tools;
4. determine whether the required connected account exists;
5. request authentication when necessary;
6. execute the selected tool;
7. normalize the result into a Pico result;
8. emit execution events;
9. produce execution evidence.

Conceptually:
```
Pico
 │
 │ email.send
 ▼
Hands
 │
 │ resolve capability
 ▼
ComposioHands
 │
 │ GMAIL_SEND_EMAIL
 ▼
Composio
 │
 ▼
Gmail
 │
 ▼
Result
 │
 ▼
Pico Evidence + Event
```
⸻

## Provider Independence

No Pico rule should need to say:

Use Composio.

Instead it should say:

Perform email.send.

The runtime can determine that:
```
email.send
     │
     ▼
ComposioHands
     │
     ▼
GMAIL_SEND_EMAIL
```
A future implementation might instead resolve:
```
email.send
     │
     ▼
NativeGoogleHands
```
without requiring Pico behaviour or rules to change.

This abstraction is essential to keeping Open Engineering open.

⸻

## Relationship to MCP

Hands and MCP should not be treated as synonyms.

MCP may be one mechanism through which tools become discoverable or executable.

The hierarchy should remain:
```
Pico
 ↓
Hands
 ↓
Provider / Protocol
 ├── Composio
 ├── MCP
 ├── REST
 ├── Kubernetes
 ├── MQTT
 └── local execution
```
Hands are the Pico capability abstraction.

MCP is an integration mechanism.

Composio is a provider/platform.

These concerns should remain separate.

⸻

## Pico Definition

The Pico definition should eventually be capable of expressing its Hands requirements.

Conceptually:
```
apiVersion: open-engineering.io/v1alpha1
kind: Pico
metadata:
  name: hello-pico
spec:
  hands:
    - name: external
      provider: composio
      capabilities:
        - github.issue.read
        - github.issue.create
    - name: cluster
      provider: kubernetes
      capabilities:
        - kubernetes.resource.read
```
This example is illustrative.

The definitive schema should be developed through the appropriate Open Engineering Definition and schema repositories.

⸻

## Composer Definition

A Composer could equip a Pico with its Hands:
```
pico:
  hands:
    external:
      provider: composio
      capabilities:
        - email.send
        - github.issue.create
    cluster:
      provider: kubernetes
      capabilities:
        - kubernetes.resource.read
```
This expresses:

The Composer determines what the Pico is equipped to do.

It does not determine when those capabilities should be exercised.

That remains Pico behaviour.

⸻

## Open Engineering Academy

The Open Engineering Academy Pico material should be updated to introduce Hands as a fundamental Pico concept.

The teaching progression should make the distinction tangible.

A learner could first create:

Hello, Pico!

Then give the Pico:
```
Identity
   +
Mind
   +
Senses
   +
Voice
   +
Hands
```
The Academy should explicitly teach:

A Pico without Hands can understand the world.

A Pico with Hands can change it.

⸻

## Suggested Academy Lab Progression

The existing Pico course can progressively give the learner’s Pico capabilities.

### Phase 1 — Meet the Pico

Create:

Hello, Pico!

Learn:

* what a Pico is;
* Pico identity;
* Pico state;
* Pico lifecycle.

### Phase 2 — Give the Pico Senses

Allow it to observe an event.

Learn:

* observations;
* events;
* triggers.

### Phase 3 — Give the Pico a Mind

Allow it to evaluate what it observed.

Learn:

* rules;
* investigation;
* reasoning;
* decisions.

### Phase 4 — Give the Pico a Voice

Allow it to communicate the decision.

Learn:

* messaging;
* reporting;
* events.

### Phase 5 — Give the Pico Hands

Allow it to perform an external action.

For example:
```
Pico observes condition
        ↓
Pico evaluates rule
        ↓
Pico decides action
        ↓
Hands
        ↓
Composio
        ↓
GitHub
        ↓
Create Issue
```
The first Academy Hands exercise should preferably use a reversible, low-risk action such as creating a GitHub issue.

Phase 6 — Give the Pico Different Hands

Demonstrate provider independence.

For example:
```
Pico
├── Composio Hand → GitHub
├── Kubernetes Hand → Crossplane
└── MQTT Hand → Home Assistant
```
This demonstrates that Hands are an architectural capability rather than a Composio feature.

⸻

## Physical Pico Demonstration

A later Academy lab could make the metaphor literal.

For example:
```
Observation
     ↓
Pico
     ↓
Rule
     ↓
Decision
     ↓
Physical Hand
     ↓
MQTT
     ↓
Home Assistant
     ↓
Device
```
Or:
```
Pico
 ↓
PhysicalHands
 ↓
Dynamixel
 ↓
Servo
 ↓
Movement
```
This provides a bridge between software engineering, AI agents, IoT, robotics, and the physical Pico character.

⸻

## Documentation Language

Open Engineering documentation should adopt consistent terminology.

Preferred wording:

Hands are the action capability of a Pico.

A Composer equips a Pico with Hands.

A Pico uses its Hands to affect external systems.

Composio is the primary external Hands provider.

Identity and policy determine whether a Hand may act.

Providers determine how the action is executed.

The statement currently used in Open Engineering Composers:

“Composio supplies the external hands of the agent.”

should therefore evolve toward:

“Composers can equip Picos with Hands. Composio is the primary external Hands provider, allowing a Pico to discover, authenticate and execute actions across external systems.”

⸻

## Implementation Plan

### Phase 1 — Definition

Define:
```
Hands
Capability
HandsProvider
ActionRequest
ActionResult
ExecutionContext
```
Establish naming and schemas within the appropriate Open Engineering definition repositories.

⸻

### Phase 2 — Pico Runtime Interface

Introduce the provider-neutral Hands interface.

Implement:
```
capabilities()
can()
execute()
```
Add normalized execution results.

⸻

### Phase 3 — Composio Provider

Implement:

ComposioHands

Support initially:

* session creation;
* connected accounts;
* tool discovery;
* capability mapping;
* execution;
* normalized results.

Start with a deliberately small integration such as GitHub.

⸻

### Phase 4 — Governance

Integrate:

* Pico identity;
* Pico rules;
* authorization;
* evidence;
* events;
* approval gates.

No production-capable Hand should bypass this layer.

⸻

### Phase 5 — Additional Providers

Implement representative providers:
```
KubernetesHands
LocalHands
MQTTHands
```
This validates that the abstraction is genuinely provider-independent.

⸻

### Phase 6 — Composer Integration

Allow Composers to equip Picos with:

* Hands providers;
* capabilities;
* configuration;
* policies.

⸻

### Phase 7 — Academy

Update the Open Engineering Academy Pico course.

Add:

Give your Pico Hands

as a core stage of learning how a Pico progresses from an observable entity to an agent capable of governed action.

⸻

## Design Rules

The implementation SHOULD follow these rules:

1. Hands are a Pico capability, not a Composio capability.
2. Composio is a provider of Hands.
3. Pico behaviour depends on capabilities, not provider-specific tool names.
4. Authentication does not imply authorization.
5. Identity accompanies every governed action.
6. Rules determine whether an action may occur.
7. Hands executions generate events and evidence.
8. Credentials never become part of Pico reasoning context unnecessarily.
9. Destructive actions can require approval.
10. Multiple Hands providers can coexist within one Pico.
11. Local and physical execution receive the same governance model as SaaS actions.
12. The Pico architecture remains portable if Composio is replaced.

⸻

## Architectural Outcome

With Hands, the Pico model becomes substantially more complete.
```
                         PICO
                    ┌────────────┐
                    │  Identity  │
                    └─────┬──────┘
                          │
             ┌────────────┼────────────┐
             │            │            │
             ▼            ▼            ▼
          Senses         Mind         Voice
             │            │            │
             │       understand        │
             │         decide          │
             │            │            │
             └────────────┼────────────┘
                          │
                          ▼
                        Hands
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
           Composio   Kubernetes    Physical
              │           │           │
              ▼           ▼           ▼
             SaaS       Runtime      World
```
The Pico can now be explained simply:

Its Senses let it observe.

Its Mind lets it understand and decide.

Its Voice lets it communicate.

Its Hands let it act.

And surrounding all of those:

Its Identity, Rules, and Evidence make those actions accountable.

⸻

## Decision

Adopt Hands as a first-class Open Engineering Pico capability.

Use Composio as the initial primary external Hands provider, while maintaining a provider-neutral Hands abstraction.

Update Open Engineering Composers so that Composers equip Picos with Hands, rather than treating Composio as the hands of the Composer itself.

Update the Open Engineering Academy Pico course to teach Hands alongside Identity, Senses, Mind, and Voice, culminating in a Pico that can safely and visibly affect both digital and physical systems.

⸻

## Summary

The distinction can be captured in four questions:
```
Identity  → Who am I?
Senses    → What is happening?
Mind      → What should I do?
Hands     → How do I do it?
```
With the Composer above them:

Composer → What should this Pico be equipped to do?

And the governing principle:
```
The Composer equips.
The Pico decides.
The Hands act.
Open Engineering governs.
```
