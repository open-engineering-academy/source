# Memo 22: Memo: Introducing the Bot Feature of a Pico Through MausBot

Status: Proposed  
Target: Open Engineering Academy — Pico course  
Subject: Teaching task-oriented AI bots as a feature of a Pico  
Reference implementation: MausBot  

## 1. Purpose

Introduce the concept of a Bot feature of a Pico in the Open Engineering Academy Pico course, using MausBot as a practical reference application.

The objective is to teach learners how an AI bot can provide a task-oriented conversational interface to a Pico, combining an AI model, a defined responsibility, selected tools, contextual information and controlled access to operations.

MausBot should be used as a learning example, not as a mandatory dependency or a replacement for the Open Engineering Pico architecture.

## 2. Context

Open Engineering Picos are modular, independently useful engineering components. A Pico can expose capabilities through well-defined interfaces and integrate with other components in the Open Engineering ecosystem.

A bot provides an additional way for users to interact with those capabilities through natural language.

MausBot offers a practical starting point for exploring this concept. Its project provides a chat-oriented environment for working with AI bots and connecting them to models, tools and external services.

The Academy should use this example to help learners distinguish between:

* An AI model that generates responses.
* A bot that has a defined responsibility and instructions.
* Tools that enable a bot to retrieve information or perform actions.
* A Pico that provides the underlying capabilities and interfaces.
* A user interface through which a human interacts with and supervises the bot.

These concepts are related but are not interchangeable.

## 3. Proposed concept: The Bot feature of a Pico

Introduce the Bot feature as an optional, reusable capability of a Pico.

A bot may combine the following elements:

1. Identity and responsibility: A name, purpose and defined scope.
2. Intelligence: An AI model selected according to the task, cost, latency and privacy requirements.
3. Context: Relevant documentation, metadata and other permitted information.
4. Tools: Explicitly authorised operations and integrations.
5. Memory: Conversation context and, where appropriate, persistent information.
6. Supervision: Policies governing which actions require human approval.
7. Observability: Logs, events and operational feedback appropriate to the security and privacy requirements.

Not every bot needs every capability. The implementation should remain proportionate to the task.

Architectural principle

The Bot feature belongs to the conceptual capabilities of a Pico, but it must not dictate a particular implementation technology.

MausBot demonstrates one possible bot experience. An Open Engineering Pico may instead implement its own bot interface, integrate another agent framework or expose capabilities to several compatible bot clients.

The Academy must not imply that MausBot already implements all Open Engineering Pico conventions or that its internal architecture is identical to the Pico architecture.

## 4. Relationship to the Open Engineering Pico architecture

Use the existing Pico architecture as the foundation for explaining how a bot can interact with the component.
```
Open Engineering concept	Teaching application
Python face	Explore how application logic, orchestration and interfaces can be implemented.
Rust/PyO3 muscles	Explain how native implementations can provide performance-sensitive capabilities where required.
Celld SQLite memory	Explore structured, durable local state and knowledge.
Composio Hands	Demonstrate how authorised external tools and application integrations can extend a bot’s capabilities.
EMQX nervous system	Explain how events and messaging can communicate operational changes between components.
Bot feature	Provide a task-oriented AI interaction layer over selected Pico capabilities.
Open Engineering Operations	Explore how operational dashboards can expose Pico status, bot activity and relevant events.
```
This mapping is conceptual. It does not assert that MausBot natively implements or directly integrates with each of these components.

In particular, a MausBot integration with Composio, Celld, EMQX or a Pico interface must be investigated and implemented explicitly where required.

## 5. Proposed Academy lab: Give Your Pico a Bot

Add a practical lab to the existing Pico course rather than creating a separate MausBot course.

Learning objectives

By completing the lab, learners should be able to:

* Explain the difference between a model, a bot, a tool and a Pico.
* Configure a bot with a clear responsibility.
* Provide a bot with relevant, controlled context.
* Identify the interfaces through which a bot can access Pico capabilities.
* Distinguish between proposing an action and executing it.
* Apply least-privilege access and human approval where appropriate.
* Evaluate whether a bot should use a local model, a hosted model or a combination.
* Document the limitations and security boundaries of the resulting implementation.

Lab phases

Follow the Open Engineering Academy’s seven-phase learning approach for labs, keeping each phase concise and outcome-oriented.

### Phase 1 — Discover

Explore MausBot and identify its relevant capabilities, including bot configuration, model selection, conversation handling and tool integrations.

Outcome: A short description of the bot application and the capabilities relevant to the lab.

### Phase 2 — Understand

Explain the roles of the AI model, bot instructions, context, tools, memory and Pico interfaces.

Outcome: A simple architecture diagram showing the intended interaction between the user, bot, Pico and any external services.

### Phase 3 — Configure

Create a bot called Pico Assistant with the responsibility of explaining one selected Pico and its documented capabilities.

Use the actual configuration options supported by the chosen MausBot version.

Outcome: A configured bot with a documented responsibility and defined scope.

### Phase 4 — Connect

Provide the bot with a safe, read-only example of Pico documentation or metadata.

If a live Pico integration is not available, use a documented mock interface or sample data rather than implying that a connection exists.

Outcome: The bot can retrieve or interpret the permitted information.

### Phase 5 — Exercise

Ask the bot to explain the Pico, identify its interfaces and propose an appropriate operational task.

Test whether its responses are grounded in the supplied documentation and whether it correctly identifies missing information.

Outcome: A set of example interactions and an evaluation of their accuracy.

### Phase 6 — Supervise

Ask the bot to prepare a proposed operation without granting unnecessary execution permissions.

Where the selected integration supports approval workflows, inspect and approve or reject an action. Otherwise, simulate the approval boundary in the lab and document the limitation.

Outcome: A documented action flow showing where human oversight occurs.

### Phase 7 — Reflect

Evaluate the implementation against its objectives, including usability, reliability, permissions, privacy and operational requirements.

Record what worked, what remains unsupported and what would be needed to integrate the bot with a real Pico.

Outcome: A concise lab report and a proposed next step.

## 6. Security, privacy and operational requirements

The lab must teach that a conversational interface does not remove the need for conventional security controls.

Apply the following principles:

* Begin with sample data and read-only access.
* Grant only the permissions required for the exercise.
* Never expose production credentials or secrets in prompts, bot instructions or example files.
* Treat retrieved documents and tool output as data, not as trusted instructions.
* Distinguish model-provider processing from local execution.
* Verify where prompts, files, logs and conversation history are stored and processed.
* Do not assume that a local-first application necessarily performs every AI operation locally.
* Require appropriate authorisation for actions that modify external systems.
* Test approval behaviour for the actual model and tool configuration rather than assuming that approval is universally enforced.
* Record errors, denied actions and other operational events without unnecessarily collecting sensitive information.

Production integrations should use explicit authentication, authorisation, auditing and failure handling.

## 7. Integration roadmap

Treat integration as an incremental progression.

### Level 1 — Demonstration

Run MausBot as a standalone application and configure a bot that explains a Pico using sample documentation.

No live Pico operations are required.

### Level 2 — Read-only Pico integration

Investigate a documented Pico API, metadata interface or other supported integration mechanism.

Allow the bot to retrieve permitted status and configuration information.

### Level 3 — Supervised operations

Allow the bot to prepare operational requests. Introduce explicit authorisation and human approval before executing actions that modify state.

### Level 4 — Ecosystem integration

Evaluate whether the bot can interact with Open Engineering Operations dashboards, Composio Hands and EMQX-based messaging through documented interfaces.

Implement adapters where needed, keeping the Pico’s core capabilities independent of MausBot.

### Level 5 — Reusable Bot capability

Extract the lessons from the integration into reusable Open Engineering conventions, interfaces and implementation guidance.

Evaluate alternative bot clients and agent frameworks to avoid coupling the Pico architecture to a single application.

These levels are a proposed roadmap, not a claim that the integrations already exist.

## 8. Acceptance criteria

The Academy lab is ready for publication when:

* MausBot is introduced as a reference implementation rather than a required Pico dependency.
* The distinction between an AI model, a bot, a tool and a Pico is explained.
* Learners can complete the introductory exercise using sample data.
* The exercise includes a clear responsibility and access boundary for the bot.
* Human approval is demonstrated where supported or explicitly simulated and documented otherwise.
* The lab identifies the relevant Open Engineering Pico components without claiming unverified integrations.
* Security, privacy and model-provider considerations are covered.
* The lab concludes with a documented outcome and a suggested next step.
* The external references have been checked against the MausBot version used in the course.

## 9. Deliverables

The proposed course contribution consists of:

1. A short lesson introducing the Bot feature of a Pico.
2. A conceptual architecture diagram.
3. The seven-phase Give Your Pico a Bot lab.
4. A sample bot configuration or equivalent reproducible setup instructions.
5. A set of test prompts and expected evaluation criteria.
6. A security and supervision checklist.
7. A brief assessment and reflection exercise.
8. A roadmap for optional Pico integration.

## 10. References

### MausBot

* Website: https://mausbot.com/
* Project source and documentation: Start from the official website and follow its current source-code and documentation links.
* Bot memory article: https://mausbot.com/blog/what-your-bot-remembers

Before publishing the lab, verify the current repository URL, licence, supported model providers, tool integration mechanisms and approval behaviour against the actual version being taught. Do not assume that an advertised feature is available in every deployment or configuration.

### Open Engineering

* Open Engineering: https://open-engineering.io/
* Open Engineering Picos: https://github.com/open-engineering-picos
* Open Engineering Operations: https://github.com/open-engineering-operations
* Open Engineering Academy: https://github.com/open-engineering-academy

Repository URLs should be verified before linking them in published course materials.

### Related technologies

* Composio: https://composio.dev/
* EMQX: https://www.emqx.com/
* SQLite: https://sqlite.org/

Use the official documentation for each selected integration to establish its actual capabilities, authentication requirements and operational constraints.

## 11. Recommendation

Adopt MausBot as an optional, hands-on reference application in the Open Engineering Academy Pico course.

The educational objective is not to make every Pico depend on MausBot. It is to teach learners how a Pico can expose a Bot feature that combines intelligence, responsibility, context, tools, memory and controlled operations.

By starting with a standalone demonstration and progressing toward explicitly designed integrations, the Academy can teach the concept today while preserving the independence, modularity and interoperability of the Open Engineering ecosystem.

Proposed guiding principle:

A Pico may offer a Bot feature through which people interact with its capabilities using natural language, while the Pico retains responsibility for its interfaces, permissions and operational boundaries.
