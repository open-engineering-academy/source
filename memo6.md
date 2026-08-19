# Memo 6 — Rust + Python with PyO3

Status

Proposed Open Engineering Academy Course

This memo defines a new Open Engineering Academy course teaching how Rust and Python can be deliberately combined using PyO3 and Maturin.

The implementation agent should be able to use this memo as the specification for creating the complete course.

⸻

1. Course

1.1 Name

Rust + Python — Building Native Python Modules with PyO3

Suggested short identifier:

rust-python-pyo3

Suggested repository/course path:

courses/rust-python-pyo3/

The exact path should follow the conventions already established by Open Engineering Academy.

⸻

2. Purpose

The purpose of this course is not simply to teach the PyO3 API.

It teaches an architectural pattern:

Python describes what should happen; Rust guarantees how fundamental things happen.

Students learn how to divide a system deliberately between:

* Python orchestration;
* Rust domain/kernel implementation;
* PyO3 interoperability;
* Maturin packaging.

By the end of the course, students should understand both how to combine Rust and Python and when doing so is architecturally appropriate.

⸻

3. Motivation

Python is particularly strong for:

* AI and LLM integration;
* agents;
* automation;
* orchestration;
* scripting;
* data processing;
* rapid prototyping;
* infrastructure integrations;
* teaching and experimentation.

Rust is particularly strong for:

* deterministic domain logic;
* parsers;
* validators;
* state machines;
* protocol implementations;
* graph processing;
* computational engines;
* reusable infrastructure components;
* native tooling;
* performance-sensitive operations;
* memory-safe systems programming.

These capabilities are complementary.

The intended architecture is therefore:

                Python
                   │
        AI / agents / workflows
                   │
                   │
                 PyO3
                   │
                   ▼
            ┌─────────────┐
            │  Rust Core  │
            ├─────────────┤
            │ identifiers │
            │ manifests   │
            │ validation  │
            │ rules       │
            │ events      │
            │ state       │
            │ parsers     │
            │ algorithms  │
            └─────────────┘

Rust should not replace Python.

Python should not duplicate functionality implemented canonically in Rust.

The boundary should be intentional.

⸻

4. Learning Outcomes

After completing the course, a learner should be able to:

1. Explain why Rust and Python are complementary.
2. Explain what PyO3 provides.
3. Explain the role of Maturin.
4. Create a Rust library.
5. Expose Rust functions to Python.
6. Expose Rust structs as Python classes.
7. Transfer strings, numbers, collections and structured data across the boundary.
8. Translate Rust errors into useful Python exceptions.
9. Design APIs that minimize unnecessary Python/Rust boundary crossings.
10. Package Rust code as a Python module.
11. Build Python wheels with Maturin.
12. Test the Rust implementation independently.
13. Test the Python-facing API.
14. benchmark an implementation where appropriate.
15. Identify functionality that should remain Python.
16. Identify functionality that is a good candidate for Rust.
17. Understand the implications of asynchronous interoperability.
18. design a small domain kernel in Rust.
19. Consume that kernel as an ordinary Python package.
20. Recognize opportunities for reusing the same Rust implementation through CLI, WASM and native interfaces.

⸻

5. Prerequisites

Learners should have basic familiarity with:

* Python;
* command-line tools;
* Git;
* basic programming concepts.

Prior Rust knowledge is useful but should not be mandatory.

The course should introduce the Rust concepts required to complete the exercises rather than becoming a complete Rust language course.

Required tooling should include:

git
python
uv or equivalent Python environment tooling
rustup
cargo
maturin

The implementation should prefer current stable releases.

Version numbers should not be unnecessarily hard-coded into educational prose when doing so would make the course quickly obsolete.

⸻

6. Core Technologies

The course should use:

* Rust
* Python
* PyO3
* Maturin
* Cargo
* pytest
* standard Rust testing

Optional advanced sections may introduce:

* serde
* serde_json
* Tokio
* pyo3-async-runtimes
* WebAssembly

These should only be introduced when they serve a concrete learning objective.

⸻

7. Course Philosophy

This course must avoid becoming:

“Rewrite Python in Rust because Rust is faster.”

Performance is only one reason for introducing Rust.

The learner should instead understand five potential motivations:

Correctness
Safety
Canonical semantics
Portability
Performance

The strongest architectural argument is often canonical semantics.

For example, a system should preferably avoid separately implementing an identifier parser in:

Python
TypeScript
Kotlin
CLI code

when one canonical implementation can potentially be reused as:

                    Rust
                     │
       ┌─────────────┼─────────────┐
       │             │             │
      PyO3          WASM          CLI
       │             │             │
       ▼             ▼             ▼
    Python        Browser       Terminal

This concept should recur throughout the course.

⸻

8. Course Structure

The course should be organized into progressive modules.

Each module should contain:

* explanation;
* architecture context;
* runnable example;
* exercise;
* automated verification;
* short reflection;
* links to authoritative documentation.

Avoid exercises whose only purpose is typing code from the lesson.

Exercises should demonstrate an engineering concept.

⸻

9. Module 1 — Why Rust + Python?

Introduce the architectural problem.

Begin with a hypothetical Python system containing:

def normalize_identifier(value: str) -> str:
    return value.strip().lower()

Explain that this is perfectly acceptable.

Do not imply it should automatically become Rust.

Introduce situations where the implementation becomes important enough to centralize:

* increasingly complicated parsing;
* validation rules;
* shared semantics;
* performance;
* use by multiple runtimes;
* security-sensitive transformations.

Introduce the principle:

Use Rust when the implementation itself becomes part of the platform contract.

Exercise:

Classify several components as:

Python
Rust candidate
Depends

Examples should include:

* LLM prompt orchestration;
* identifier parser;
* MQTT integration;
* graph traversal;
* REST API orchestration;
* manifest validator;
* agent workflow;
* state-machine engine.

The answer should emphasize reasoning rather than treating the classification as absolute.

⸻

10. Module 2 — The Rust Library

Create the initial project.

For example:

rust-python-pyo3/
├── Cargo.toml
├── pyproject.toml
├── src/
│   └── lib.rs
├── python/
├── tests/
└── README.md

Introduce only the Rust concepts necessary for the course:

* functions;
* structs;
* enums;
* Result;
* ownership at a conceptual level;
* modules;
* Cargo.

Initial Rust implementation:

pub fn normalize_identifier(value: &str) -> String {
    value.trim().to_lowercase()
}

Create a native Rust test before Python is introduced.

This establishes an important principle:

The domain implementation exists independently of its Python binding.

⸻

11. Module 3 — First PyO3 Binding

Introduce PyO3.

Convert the Rust function into a Python-accessible function.

Conceptually:

use pyo3::prelude::*;
#[pyfunction]
fn normalize_identifier(value: &str) -> String {
    value.trim().to_lowercase()
}
#[pymodule]
fn open_engineering_core(
    m: &Bound<'_, PyModule>
) -> PyResult<()> {
    m.add_function(
        wrap_pyfunction!(normalize_identifier, m)?
    )?;
    Ok(())
}

The precise implementation should be adjusted to the current stable PyO3 API when the course is created or maintained.

From Python:

from open_engineering_core import normalize_identifier
identifier = normalize_identifier("  OE.PICO.LAMP  ")
assert identifier == "oe.pico.lamp"

The learner should understand what has happened:

Python
   │
   │ function call
   ▼
PyO3
   │
   ▼
Rust

⸻

12. Module 4 — Maturin

Introduce Maturin as the packaging/build bridge.

The learner should be able to execute the appropriate development workflow, conceptually:

maturin develop

and subsequently:

import open_engineering_core

Explain:

* native extensions;
* Python wheels;
* development builds;
* release builds;
* platform-specific artifacts.

The learner should understand that downstream Python code should not need special knowledge about Cargo.

To Python consumers, this should behave like a Python package.

⸻

13. Module 5 — Types Across the Boundary

Progress beyond simple functions.

Introduce a Rust type such as:

struct Identifier {
    namespace: String,
    kind: String,
    value: String,
}

Eventually expose it as something conceptually equivalent to:

identifier = Identifier(
    namespace="open-engineering",
    kind="pico",
    value="lamp"
)

Teach:

* constructors;
* properties;
* methods;
* strings;
* integers;
* booleans;
* optional values;
* lists;
* dictionaries where appropriate.

Discuss the distinction between:

Rust domain representation

and:

Python-facing API representation

They do not always need to be identical.

⸻

14. Module 6 — Strong Domain Types

Refactor the simplistic identifier.

Instead of treating everything as strings, introduce domain types.

Conceptually:

struct Identifier {
    namespace: Namespace,
    kind: EntityKind,
    id: EntityId,
}

Explain why invalid states should ideally be difficult or impossible to construct.

Introduce parsing:

string
   │
   ▼
parser
   │
   ├── valid ─────► Identifier
   │
   └── invalid ───► Error

This module should demonstrate one of Rust’s primary benefits for Open Engineering-style platforms:

encoding invariants in the type system.

⸻

15. Module 7 — Errors

Teach proper error handling across PyO3.

Rust:

Result<T, E>

should become useful Python exceptions rather than:

* panics;
* opaque error strings;
* crashes.

For example:

try:
    Identifier.parse("invalid")
except InvalidIdentifierError:
    ...

Explain that the boundary forms part of the public API.

Errors therefore require deliberate design.

⸻

16. Module 8 — Structured Data

Introduce structured inputs.

For example:

manifest = {
    "kind": "pico",
    "name": "lamp",
    "version": "1.0"
}
result = validate_manifest(manifest)

Discuss several approaches:

* direct Python structures;
* typed PyO3 objects;
* JSON;
* serde-backed structures.

Teach learners to avoid blindly translating every Python dictionary into Rust internal state.

Validation should occur at a clearly defined boundary.

⸻

17. Module 9 — Boundary Design

This is a critical module.

Teach why this:

result = engine.evaluate_model(model)

is generally preferable to:

for item in model:
    engine.evaluate_field(item.x)
    engine.evaluate_field(item.y)
    engine.evaluate_field(item.z)

The first creates a coarse-grained boundary.

The second can create excessive language crossings.

Introduce:

Python
      │
      │ one meaningful operation
      ▼
┌──────────────────────┐
│        Rust          │
│                      │
│ parse                │
│ validate             │
│ calculate            │
│ evaluate             │
│ construct result     │
└──────────────────────┘
      │
      ▼
Python result

Teach API design rather than simply FFI syntax.

⸻

18. Module 10 — Testing

Require two layers of testing.

Rust tests

Test the canonical implementation directly.

For example:

cargo test

Python tests

Test the exposed contract:

pytest

The architecture becomes:

             Rust core
             ▲       ▲
             │       │
        Rust tests   PyO3
                     │
                     ▼
                  Python API
                     ▲
                     │
                  pytest

Students should understand why both are valuable.

⸻

19. Module 11 — Performance

Introduce benchmarking carefully.

The lesson should explicitly demonstrate that:

Rust does not automatically make an application faster.

Potential costs include:

* object conversion;
* allocation;
* serialization;
* FFI transitions;
* Python GIL interactions.

Benchmark an operation that is sufficiently computational to demonstrate the distinction.

Compare:

pure Python

against:

Python → Rust

Then deliberately create a pathological example involving many tiny boundary calls.

This teaches learners to measure rather than assume.

⸻

20. Module 12 — Concurrency and the GIL

Introduce the Python Global Interpreter Lock only to the depth required for correct PyO3 engineering.

Explain when Rust computation can operate independently of Python.

Discuss:

* CPU-heavy work;
* long-running native operations;
* Python object access;
* safe concurrency.

This should remain practical rather than becoming a complete Python runtime internals course.

⸻

21. Module 13 — Async Interoperability

Introduce asynchronous boundaries.

Explain that:

Python asyncio

and:

Rust async / Tokio

are different runtime environments.

Introduce pyo3-async-runtimes or its current recommended equivalent.

Do not encourage async merely because it exists.

The learner should understand when a synchronous coarse-grained Rust API is simpler and preferable.

⸻

22. Module 14 — What Should Stay Python?

This module is mandatory.

Provide examples such as:

agent.ask(...)
llm.generate(...)
mqtt.publish(...)
home_assistant.call_service(...)
workflow.execute(...)

Explain why these may remain Python.

Typical reasons:

* network latency dominates;
* rapid experimentation matters;
* Python ecosystem integration is valuable;
* implementation changes frequently;
* performance is irrelevant;
* orchestration is easier to understand in Python.

Teach:

Do not introduce Rust merely to eliminate Python.

⸻

23. Module 15 — Capstone: Mini Open Engineering Kernel

The learner now creates a small domain kernel.

Suggested structure:

open-engineering-kernel/
├── Cargo.toml
├── pyproject.toml
├── src/
│   ├── lib.rs
│   ├── identifier.rs
│   ├── manifest.rs
│   ├── rule.rs
│   └── error.rs
├── python/
├── tests/
│   ├── rust/
│   └── python/
└── README.md

The exact layout may be adapted to Cargo/Python conventions.

⸻

24. Capstone Requirement 1 — Identifier

Implement an Identifier.

It should:

* parse;
* validate;
* normalize;
* serialize;
* reject invalid input.

Example Python usage:

from open_engineering_kernel import Identifier
identifier = Identifier.parse(
    "open-engineering.pico.lamp"
)
print(identifier.namespace)
print(identifier.kind)
print(identifier.name)

The precise identifier grammar used in the Academy should follow the existing Open Engineering identifier conventions rather than inventing a competing standard.

⸻

25. Capstone Requirement 2 — Manifest

Implement manifest validation.

Conceptually:

from open_engineering_kernel import validate_manifest
result = validate_manifest({
    "kind": "pico",
    "name": "lamp",
})

The validation implementation belongs to Rust.

Python orchestrates its use.

⸻

26. Capstone Requirement 3 — Rule

Implement a deliberately small rule engine.

For example:

result = evaluate_rule(
    rule,
    observation
)

The exercise should demonstrate that deterministic evaluation can live in Rust while Python controls the larger workflow.

⸻

27. Capstone Architecture

The final architecture should resemble:

Python application
       │
       ├── AI
       ├── agents
       ├── automation
       ├── workflow
       │
       ▼
   Python API
       │
      PyO3
       │
       ▼
┌───────────────────────────┐
│    Open Engineering       │
│       Mini Kernel         │
│                           │
│ Identifier                │
│ Manifest                  │
│ Rule                      │
│ Validation                │
└───────────────────────────┘
            │
            ▼
           Rust

⸻

28. Packaging Exercise

The learner should build a Python wheel.

Conceptually:

maturin build --release

The resulting artifact should be installable into a clean Python environment.

The course verification should test:

build
  ↓
wheel
  ↓
fresh environment
  ↓
pip install
  ↓
import
  ↓
execute

This is important.

The course should not stop after maturin develop.

⸻

29. CI

Provide a CI example.

The pipeline should perform at least:

format
   ↓
lint
   ↓
Rust tests
   ↓
build Python extension
   ↓
Python tests
   ↓
wheel build

Where appropriate:

cargo fmt --check
cargo clippy
cargo test
pytest
maturin build

The implementation should use the CI conventions established elsewhere in Open Engineering rather than creating unnecessary competing infrastructure.

⸻

30. Containers

Where useful, provide a development container or Docker-based verification environment.

However, learners should understand an important distinction:

PyO3 produces native artifacts.

Containers do not eliminate the need to understand target platforms.

Explain concepts including:

Linux wheel
macOS wheel
Windows wheel
CPU architecture
Python version
ABI

without overwhelming beginners.

⸻

31. Multi-Platform Extension

Conclude the technical portion by showing the strategic consequence of putting canonical logic in Rust.

The mini-kernel could eventually become:

                   Rust Kernel
                       │
          ┌────────────┼────────────┐
          │            │            │
        PyO3          CLI          WASM
          │            │            │
          ▼            ▼            ▼
       Python       Terminal      Browser

The learner does not need to implement every target.

The purpose is architectural understanding.

⸻

32. Relationship to Pico

The course should explicitly prepare learners for a later course such as:

Pico Engine with Rust + PyO3

That course could implement:

                 Pico Engine
                     │
                  Rust
                     │
       ┌─────────────┼──────────────┐
       │             │              │
     PyO3           WASM          native
       │             │              │
       ▼             ▼              ▼
    Python         Browser       Runtime
 simulation      digital twin

Potential Rust responsibilities could include:

* Pico identity;
* state;
* events;
* commands;
* state transitions;
* validation;
* simulation;
* deterministic behavior.

Python could provide:

* AI;
* agents;
* orchestration;
* training scenarios;
* experimentation;
* external integrations.

This should remain a preview rather than expanding the present course’s scope.

⸻

33. Relationship to Existing Academy Courses

The implementation agent must inspect existing Open Engineering Academy courses before creating the course.

Reuse established conventions for:

* directory layout;
* lesson structure;
* exercises;
* validation;
* course metadata;
* navigation;
* diagrams;
* terminology;
* CI;
* containers;
* documentation.

Where relevant, reference existing courses rather than duplicating their teaching.

In particular, reuse existing material for topics already taught elsewhere, including areas such as:

* Python fundamentals;
* Kubernetes;
* Minikube;
* Crossplane;
* Pico;
* Git;
* container fundamentals.

The PyO3 course should teach the language boundary and architectural pattern, not reproduce unrelated courses.

⸻

34. Open Engineering Architecture

This course introduces a potentially important Open Engineering implementation pattern.

The long-term conceptual layering should be presented as:

┌────────────────────────────────────────────┐
│                EXPERIENCE                  │
│                                            │
│ Svelte / Kotlin / Python applications      │
└─────────────────────┬──────────────────────┘
                      │
┌─────────────────────▼──────────────────────┐
│              ORCHESTRATION                 │
│                                            │
│ Python                                     │
│ AI · Agents · Automation · Workflows       │
└─────────────────────┬──────────────────────┘
                      │
                    PyO3
                      │
┌─────────────────────▼──────────────────────┐
│                  KERNEL                    │
│                                            │
│ Rust                                       │
│                                            │
│ Identifiers                                │
│ Definitions                                │
│ Parsers                                    │
│ Rules                                      │
│ Events                                     │
│ Graphs                                     │
│ State Machines                             │
│ Simulation                                 │
└────────────────────────────────────────────┘

This course does not declare that every Open Engineering primitive must immediately be rewritten in Rust.

Instead it establishes the pattern and provides evidence through a working implementation.

Adoption elsewhere should be incremental.

⸻

35. Design Principle: One Semantic Core

An important architectural principle introduced by the course is:

One semantic core, multiple interfaces.

Where practical, avoid:

Python parser
JavaScript parser
Kotlin parser
CLI parser

with subtly different behavior.

Prefer:

                    Rust Core
                        │
          ┌─────────────┼─────────────┐
          │             │             │
        PyO3           WASM          CLI
          │             │             │
       Python       Web runtime    Terminal

This reduces semantic drift.

⸻

36. Design Principle: Coarse Boundaries

Bindings should expose meaningful domain operations.

Prefer:

result = engine.evaluate_model(model)

over thousands of calls resembling:

engine.evaluate_field(...)

Design the Rust/Python interface as an API boundary.

Do not treat PyO3 as transparent syntax sugar.

⸻

37. Design Principle: Independent Kernel

The Rust implementation must remain independently testable.

Avoid placing all domain behavior directly inside functions annotated only for Python.

Prefer conceptually:

Rust domain library
       │
       ├──── Rust tests
       │
       └──── PyO3 adapter
                  │
                  ▼
                Python

This preserves future possibilities such as:

* CLI;
* WASM;
* services;
* embedded use;
* other language bindings.

⸻

38. Design Principle: Thin PyO3 Layer

PyO3 should primarily be an adapter.

Avoid:

Python
   │
huge PyO3-specific domain implementation
   │
Rust

Prefer:

Python
   │
thin PyO3 adapter
   │
Rust domain API
   │
Rust implementation

This distinction should be visible in the capstone source structure.

⸻

39. Assessment

The course should verify understanding rather than only successful compilation.

Assessment should include:

Knowledge

The learner can explain:

* what PyO3 does;
* what Maturin does;
* why Rust might be introduced;
* why Python may remain preferable;
* what makes a good FFI boundary.

Implementation

The learner can:

* create a Rust library;
* bind it with PyO3;
* import it from Python;
* expose domain types;
* handle errors;
* test both sides;
* package a wheel.

Architecture

Given several system components, the learner can justify whether each belongs in:

Python
Rust
either

⸻

40. Definition of Done

The course is complete when a learner can clone the course materials and, following the documented path:

1. prepare the development environment;
2. compile the initial Rust library;
3. run Rust tests;
4. expose a Rust function through PyO3;
5. import it from Python;
6. expose a Rust domain object;
7. handle Rust errors as Python exceptions;
8. implement the mini-kernel;
9. run Python tests;
10. build a Python wheel;
11. install the wheel in a clean environment;
12. successfully execute the capstone Python application;
13. explain why the chosen Python/Rust boundary exists.

All exercises must be reproducible.

All required source files must be present.

There should be no unexplained manual steps required to make the final project work.

⸻

41. References

The implementation should use authoritative upstream documentation as its primary technical reference.

PyO3:

https://pyo3.rs/

PyO3 source:

https://github.com/PyO3/pyo3

Maturin:

https://www.maturin.rs/

Maturin source:

https://github.com/PyO3/maturin

Rust:

https://www.rust-lang.org/

The Rust Book:

https://doc.rust-lang.org/book/

Python:

https://www.python.org/

For asynchronous integration, consult the current PyO3 ecosystem recommendation at implementation time rather than permanently coupling the course to an outdated runtime adapter.

⸻

42. Follow-On Course

Once this course exists and has proven the architecture, create a separate course proposal for:

Pico Engine — Building a Digital Twin Runtime with Rust and PyO3

That course should reuse this course rather than reteaching PyO3.

The progression would therefore become:

Rust fundamentals
       +
Python fundamentals
       │
       ▼
Rust + Python with PyO3
       │
       ▼
Open Engineering Mini Kernel
       │
       ▼
Pico Engine with Rust + PyO3
       │
       ├──── Python simulation
       ├──── WASM digital twin
       └──── native runtime

This creates a learning path from language interoperability to a genuine Open Engineering runtime.

⸻

43. Final Direction

Open Engineering should not adopt Rust merely because it is fast, modern, or fashionable.

The strategic opportunity is more specific:

Rust can provide canonical, deterministic executable semantics while Python remains the flexible orchestration and AI environment.

PyO3 provides the bridge that allows those two responsibilities to coexist without forcing users of the Python ecosystem to abandon Python.

The resulting principle for the Academy and potentially the wider Open Engineering ecosystem is:

Python describes what should happen. Rust guarantees how fundamental things happen.

And the implementation principle underneath it is:

One semantic core, multiple interfaces.

This course should demonstrate both principles with working software rather than teaching them only as theory.
