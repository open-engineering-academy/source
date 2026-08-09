Yes. In fact, I think Pico + Crossplane + [Sandcastle](%5Bhttps://github.com/mattpocock/sandcastle)]([https://github.com/mattpocock/sandcastle](https://github.com/mattpocock/sandcastle)) form a surprisingly coherent three-layer architecture for Open Engineering.

The key is not to make them overlap. Give each a distinct responsibility:

Crossplane declares and composes the world.Sandcastle safely changes the world.Picos inhabit and react to the world.

The three responsibilities

Crossplane⁠￼ is the declarative control plane. An XRD defines a custom API, an XR represents a request against that API, and a Composition determines the resources that should exist to satisfy it. Crossplane v2 is especially interesting here because Compositions can compose arbitrary Kubernetes resources and third-party CRDs, not just traditional Crossplane managed resources.

Sandcastle⁠￼ is the bounded engineering/work environment. It orchestrates coding agents inside isolated sandboxes, handles branches and commits, and supports interchangeable sandbox providers including Docker, Podman, Vercel, and custom providers.

A Pico is the long-lived reactive actor/entity. It has identity and state, receives events, evaluates rules, changes state and emits events/actions.

That produces a very clean separation:

Layer Question TechnologyIntent / Composition What should exist? CrossplaneEngineering / Construction How can an agent safely build/change it? SandcastleRuntime / Behaviour What does the resulting entity do? Pico

The particularly interesting synergy

I would not model Sandcastle merely as something that happens to be used by developers.

I’d make a Sandcastle a first-class Open Engineering resource that Crossplane can request.

Conceptually:

Engineer / AI / GitOps│▼┌─────────────────────┐│ Crossplane ││ ││ XRD → XR → Compose │└──────────┬──────────┘││ requests▼┌─────────────────────┐│ Sandcastle ││ ││ isolated workspace ││ repo + branch ││ tools + permissions ││ engineering agent │└──────────┬──────────┘││ builds/tests▼┌─────────────────────┐│ Pico artifact ││ ││ rulesets ││ configuration ││ metadata │└──────────┬──────────┘││ deployed▼┌─────────────────────┐│ Pico Runtime ││ ││ events → rules ││ state → actions │└─────────────────────┘

This makes the name Sandcastle particularly appropriate in the Open Engineering ontology: it is temporary, isolated, reproducible and disposable. The resulting engineering artifacts are durable; the castle used to construct them does not need to be.

Example: HelloWorldPico

Imagine the engineer submits something conceptually like:

apiVersion: open-engineering.io/v1alpha1kind: Picometadata:name: hello-worldspec:rules:- hello-worldruntime:type: manifold

Crossplane receives the XR.

Its Composition could determine that satisfying this request requires:

Pico│├── Pico definition├── Ruleset references├── Runtime configuration├── Manifold resources├── Kubernetes resources└── EngineeringTask│▼Sandcastle

The important part is that Crossplane doesn’t need to write the Pico code.

Instead, a composition can cause an engineering task to exist.

The Sandcastle layer then gives an AI engineering agent a constrained environment containing only what that task needs—for example the Pico conventions, rule conventions, parser contracts, target repository and tests.

Sandcastle already has exactly the primitives that make this attractive: sandbox-provider abstraction, agent abstraction, branch handling, commits and iteration.

The agent can then:

clone↓inspect conventions↓generate Pico↓generate ruleset↓validate↓test↓commit↓PR / artifact

The Sandcastle disappears.

The resulting declarative artifacts go through GitOps and eventually Crossplane reconciles the desired runtime state.

Then the Pico begins doing something quite different.

event↓Pico↓ruleset↓decision↓state transition↓event/action

So there are actually two reconciliation loops operating at different scales.

Crossplane reconciliation

desired infrastructure/system state↓observe↓desired ─── compare ─── actual│▼reconcile

Pico event loop

event↓observe context/state↓evaluate rules↓transition↓emit events/actions

That’s an important architectural distinction.

Crossplane reconciles resources.

Picos react to events.

And Sandcastle sits outside both loops:

Sandcastle performs bounded engineering work that can alter the declarations feeding those loops.

This fits your Definition → Implementation distinction very nicely

There’s another consequence for the repository model we’ve been developing.

You can preserve the plural/singular pattern:

open-engineering-picos││ definitions▼open-engineering-pico││ implementations▼runtime

and:

open-engineering-sandcastles││ blueprints / definitions▼open-engineering-sandcastle││ instantiated configuration▼sandbox provider

Crossplane becomes one of the mechanisms that turns those definitions into instantiated resources.

That gives us a more general pattern:

DEFINITION│▼COMPOSITION│▼CONSTRUCTION│▼IMPLEMENTATION│▼EXECUTION

mapped onto the technologies:

Open Engineering definitions│▼Crossplane│▼Sandcastle│▼Git artifacts│▼Crossplane│▼Manifold/Pico

Notice Crossplane appears twice conceptually, because its reconciliation doesn’t stop after construction. That’s desirable: Sandcastle is transient; Crossplane remains responsible for desired state.

One thing I would avoid

I would not run every Pico inside its own Sandcastle.

That muddles the abstraction.

Sandcastle’s isolation boundary is designed around coding agents doing potentially risky engineering work—its own documentation describes the sandbox as the isolation boundary around an agent.

A Pico is a runtime entity. Its normal execution environment belongs in Manifold/Pico Engine/Kubernetes or whatever runtime abstraction we establish.

So:

❌ Pico└── Sandcastle└── runtime

Instead:

```
         Crossplane
         /        \
        /          \
       ▼            ▼
Sandcastle       Runtime
    │               │
```

engineering Pico│ │└── artifact ───┘

And that suggests an even broader Open Engineering principle:

Use Sandcastles for bounded creation and experimentation; use Crossplane for declarative composition and reconciliation; use Picos for persistent reactive behaviour.

I think this is stronger than treating these as three useful technologies that happen to coexist. They correspond to three genuinely different phases of engineering: compose → construct → behave, with Git/artifacts forming the durable boundary between construction and runtime.

That is probably worth codifying explicitly in the Open Engineering architecture, because it also tells us exactly where open-engineering-sandcastles, open-engineering-sandcastle, open-engineering-picos, open-engineering-pico, Crossplane, Kubernetes and Manifold belong relative to one another.