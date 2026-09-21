# Memo 18: External Agents for Picos

Status

Proposed

Purpose

Define how external AI agents can work with Open Engineering Picos without becoming part of the Pico itself.

The primary example considered by this memo is Viktor, an AI employee platform capable of executing tasks through applications, tools and computer environments.

The architectural principle is:

A Pico provides durable identity, capabilities, memory, connectivity and execution. An external Agent provides intelligence and task orchestration.

This separation allows a Pico to be operated by different agents without coupling the Pico to a particular AI model, vendor or agent platform.

⸻

1. Context

An Open Engineering Pico is an autonomous software entity composed of cooperating technologies.

The current Pico architecture includes:

* Python — Face
* Rust — Muscles
* Celld — Memory
* Composio — Hands
* EMQX — Nervous System
* A2A — Pico-to-Pico communication
* Event & Telemetry
* Security

The architecture should not assume that the intelligence controlling a Pico must be implemented inside the Pico.

Instead, the Pico should expose well-defined capabilities that can be invoked by agents.

This creates a distinction between:

Pico
  =
Identity + Capabilities + Memory + Execution + Connectivity

and:

Agent
  =
Reasoning + Planning + Task Orchestration

An agent can therefore operate one or more Picos.

⸻

2. The External Agent Principle

An external agent is an AI system that can discover and invoke Pico capabilities.

Examples may include:

* Viktor
* cloud-based LLM agents
* locally hosted LLM agents
* OpenAI-based agents
* Anthropic-based agents
* other MCP-compatible agents
* human operators

The Pico must not depend on any particular agent.

The relationship should therefore be:

                    External Agent
                         │
                         │ MCP / API
                         ▼
                    ┌───────────┐
                    │   Pico    │
                    └─────┬─────┘
                          │
          ┌───────────────┼────────────────┐
          ▼               ▼                ▼
       Memory          Tools            Events
        Celld         Composio           EMQX

The agent asks the Pico to perform work.

The Pico determines how that work is executed using its own capabilities.

⸻

3. Viktor as an External Agent

Viktor is a particularly interesting candidate for integration because its platform provides AI-driven task execution and an MCP interface.

References:

* Viktor: https://viktor.com/
* Viktor documentation: https://docs.viktor.ai/
* Viktor MCP documentation: https://docs.viktor.ai/docs/create-apps/mcp/
* Viktor Public API: https://viktor.com/docs/public-api

Viktor should be treated as an optional external agent, not as a required Pico component.

The architecture should therefore be:

                 ┌──────────────────┐
                 │      Viktor      │
                 │ External Agent   │
                 └────────┬─────────┘
                          │
                         MCP
                          │
                 ┌────────▼─────────┐
                 │       Pico       │
                 │                  │
                 │ Python           │
                 │ Rust             │
                 │ Celld            │
                 │ Composio         │
                 │ EMQX             │
                 └──────────────────┘

The Pico remains independent of Viktor.

⸻

4. MCP as the Agent–Pico Interface

Model Context Protocol (MCP) provides a natural interface through which an external agent can discover and invoke capabilities.

A Pico can expose selected capabilities as MCP tools.

For example:

Pico
 │
 ├── inspect()
 ├── remember()
 ├── execute()
 ├── query()
 ├── emit_event()
 ├── discover()
 └── communicate()

An agent can discover these capabilities and decide when to use them.

The important architectural rule is:

Expose capabilities, not implementation details.

An external agent should not need to know whether a capability is implemented in Python, Rust, Celld, Composio or another component.

For example:

Agent
  │
  │ "inspect DNS configuration"
  ▼
Pico MCP capability
  │
  ▼
Rust/Python implementation
  │
  ▼
Result

The implementation remains an internal concern of the Pico.

⸻

5. Pico as a Durable Execution Entity

The Pico should remain useful even when no external agent is connected.

This means that a Pico should retain:

* identity
* configuration
* capabilities
* memory
* event subscriptions
* security policies
* telemetry
* relationships with other Picos

An agent may temporarily connect to the Pico, perform work and disconnect.

        Agent A
           │
           ▼
       ┌───────┐
       │ Pico  │
       └───────┘
           ▲
           │
        Agent B

The Pico therefore has a lifecycle independent from the lifecycle of an agent.

⸻

6. Multiple Agents

A Pico should not be designed around a single permanent agent.

Different agents may be appropriate for different tasks.

For example:

                 ┌── Local Qwen
                 │
                 ├── Cloud LLM
                 │
                 ├── Viktor
                 │
Pico ◄───────────┼── Other Agent
                 │
                 └── Human

This is especially important for cost, privacy, availability and capability.

An Open Engineering environment could therefore route work according to:

* task complexity
* required tools
* cost
* latency
* privacy requirements
* availability
* security policy
* local/cloud preference
* human approval requirements

The Pico remains the stable execution target.

⸻

7. Local and Cloud Intelligence

This architecture also supports hybrid AI.

Instead of making every Pico dependent on an expensive cloud model:

Pico → Cloud LLM

the architecture can become:

                   ┌── Local LLM
                   │
                   ├── Cloud LLM
                   │
Pico ◄── Agent ────┼── Viktor
                   │
                   ├── Other Agent
                   │
                   └── Human

This allows Open Engineering to experiment with different intelligence providers without redesigning the Pico.

It also supports the principle:

Intelligence is replaceable; Pico identity and capabilities are durable.

⸻

8. Agents Should Not Own Pico Identity

The identity of a Pico belongs to the Pico.

An external agent must authenticate itself to the Pico rather than impersonating the Pico.

Conceptually:

Pico identity
      │
      ├── accepts Agent A
      ├── accepts Agent B
      └── accepts Human

Each interaction should therefore be attributable to:

* the Pico
* the agent
* the requested capability
* the authorization context
* the resulting action
* relevant telemetry

This becomes particularly important when multiple Picos collaborate.

⸻

9. Security Boundary

External agents introduce a security boundary.

An agent must not automatically receive unrestricted access to every Pico capability.

Pico capabilities should therefore be classified and authorized.

For example:

                    Pico
                     │
          ┌──────────┼──────────┐
          ▼          ▼          ▼
       Read-only   Action     Sensitive
       tools       tools       tools
          │          │           │
          ▼          ▼           ▼
        Agent     Approval     Restricted

A Pico may require human approval for sensitive actions.

Authorization should be capability-based rather than based purely on the identity of the agent vendor.

For example:

Agent: Viktor
Capability: execute_dns_change
Authorization: denied

or:

Agent: Viktor
Capability: inspect_dns
Authorization: allowed

This keeps security inside the Pico architecture rather than delegating trust entirely to an external agent.

⸻

10. Composio and External Agents

Composio remains the Hands of the Pico.

Viktor should not replace Composio.

The distinction is:

Agent
  │
  │ decides what should happen
  ▼
Pico
  │
  │ delegates external action
  ▼
Composio
  │
  │ executes external tool operation
  ▼
External System

For example:

Viktor:
"Create a GitHub issue describing this problem."
        ↓
Pico:
"GitHub issue creation is required."
        ↓
Composio:
"Execute GitHub issue creation."
        ↓
GitHub

This preserves the architectural separation between reasoning and hands.

⸻

11. EMQX and External Agents

EMQX remains the Pico’s Nervous System.

It can be used for event-driven communication between Picos and potentially between agents and Picos.

For example:

Agent
  │
  ▼
Pico A
  │
  │ event
  ▼
EMQX
  │
  ▼
Pico B

This means an agent does not necessarily need to maintain a direct connection to every Pico.

The agent can initiate work while Picos communicate asynchronously through the event infrastructure.

This becomes increasingly important as the number of Picos grows.

⸻

12. A2A and External Agents

A2A should remain conceptually distinct from MCP.

A useful division is:

MCP

Agent ↔ Pico capability interaction

A2A

Pico ↔ Pico agent/entity communication

For example:

Viktor
   │
   │ MCP
   ▼
Pico A
   │
   │ A2A
   ▼
Pico B
   │
   │ A2A
   ▼
Pico C

This allows an external agent to initiate work while the Picos coordinate among themselves.

⸻

13. Example: Viktor Investigates a Pico Problem

Consider a Pico responsible for DNS infrastructure.

The user asks Viktor:

"Investigate why DNS resolution is failing."

The interaction could become:

User
 │
 ▼
Viktor
 │
 │ MCP
 ▼
DNS Pico
 │
 ├── inspect configuration
 │
 ├── query telemetry
 │
 ├── retrieve memory
 │
 └── inspect related Picos
 │
 ▼
Diagnosis
 │
 ▼
Viktor
 │
 ▼
User

If a corrective action is required:

Viktor
  │
  ▼
Pico
  │
  ├── authorization check
  │
  ├── human approval?
  │
  └── Composio / Rust / Python
          │
          ▼
       Action

The agent performs the reasoning.

The Pico enforces its capabilities, memory, security and execution rules.

⸻

14. Example: Coding Agent

The same architecture can be applied to Open Engineering software development.

An external coding agent could ask a Pico to:

inspect_repository()
run_tests()
inspect_logs()
create_branch()
run_refactoring()
create_pull_request()

The Pico can decide which implementation technology performs each operation.

For example:

Agent
  │
  ▼
Development Pico
  │
  ├── Python
  ├── Rust
  ├── Celld
  ├── Composio
  └── EMQX

This creates a potentially useful bridge between the Pico architecture and Open Engineering’s AI-assisted software engineering workflows.

⸻

15. Implementation Direction

The first implementation should be deliberately small.

Phase 1 — Pico MCP Server

Create an MCP interface for a Pico exposing a small number of safe capabilities.

For example:

pico.describe
pico.status
pico.memory.search
pico.event.publish

Phase 2 — Agent Integration

Connect an MCP-capable external agent.

Viktor can be used as one experimental client.

Phase 3 — Capability Authorization

Introduce explicit capability permissions.

Phase 4 — Event Integration

Connect agent-triggered work to EMQX.

Phase 5 — Pico-to-Pico Collaboration

Allow a Pico accessed by an external agent to delegate work to other Picos through A2A.

Phase 6 — Agent Interchangeability

Test the same Pico with multiple agents.

The implementation should demonstrate that replacing Viktor with another agent does not require changing the Pico.

⸻

16. Architectural Rule

The following rule should become part of the Open Engineering Pico conventions:

External agents may provide intelligence and orchestration to a Pico, but the Pico must remain independently identifiable, capability-oriented, secure and operationally independent of any particular agent provider.

A second rule follows:

Agents consume Pico capabilities; they should not depend on Pico implementation details.

And a third:

Composio remains the Hands of the Pico; an external agent does not replace the Pico’s Hands.

⸻

17. Open Engineering Academy

This concept should become part of the Open Engineering Academy Pico course.

The course should introduce the distinction after explaining the internal Pico components.

Suggested learning sequence:

Pico
 │
 ├── Face       → Python
 ├── Muscles    → Rust
 ├── Memory     → Celld
 ├── Hands      → Composio
 ├── Nervous    → EMQX
 ├── Identity   → Pico identity
 ├── A2A        → Pico-to-Pico
 └── Agent      → External intelligence

The learner should understand that the Agent is not another body part.

It is an external intelligence that can operate the Pico.

A useful teaching analogy is:

The Pico is the creature. The Agent is the intelligence temporarily working with the creature.

⸻

18. Academy Practical Exercise

The course should eventually include a practical exercise:

Exercise: Connect an External Agent to a Pico

1. Start a Pico.
2. Expose a small set of Pico capabilities through MCP.
3. Connect an MCP-capable agent.
4. Ask the agent to inspect the Pico.
5. Ask the agent to perform a permitted action.
6. Inspect the resulting telemetry.
7. Disconnect the agent.
8. Connect another agent.
9. Repeat the same operation.
10. Verify that the Pico identity and capabilities remain unchanged.

The learner should observe:

Agent changes
      ↓
Pico remains
      ↓
Capabilities remain
      ↓
Identity remains
      ↓
Memory remains

This demonstrates the architectural separation directly.

⸻

19. References

Viktor

* https://viktor.com/
* https://docs.viktor.ai/
* https://docs.viktor.ai/docs/create-apps/mcp/
* https://viktor.com/docs/public-api

Model Context Protocol

* https://modelcontextprotocol.io/

Open Engineering

* https://open-engineering.io/
* https://open-engineering.io/courses/rust-python-pyo3/

Related Pico technologies

* Composio: https://composio.dev/
* EMQX: https://www.emqx.com/
* A2A Protocol: https://a2a-protocol.org/

⸻

20. Desired Outcome

Open Engineering Picos should become agent-agnostic durable software entities.

An external agent such as Viktor should be able to discover and use Pico capabilities without becoming part of the Pico implementation.

The resulting architecture is:

                     HUMAN
                       │
                       ▼
              ┌────────────────┐
              │ EXTERNAL AGENT │
              │                │
              │ Viktor / LLM / │
              │ Local Agent    │
              └───────┬────────┘
                      │
                    MCP
                      │
                      ▼
              ┌───────────────┐
              │     PICO      │
              │               │
              │ Face          │
              │ Muscles       │
              │ Memory        │
              │ Hands         │
              │ Nervous       │
              │ Identity      │
              │ Security      │
              └───────┬───────┘
                      │
               ┌──────┴──────┐
               ▼             ▼
             A2A           EMQX
               │             │
               ▼             ▼
            Other Picos    Events

The long-term objective is therefore:

Build Picos once, then allow many different forms of intelligence to operate them.

This makes the Pico architecture independent of any single AI provider and creates a foundation for interchangeable cloud agents, local agents and human operators.
