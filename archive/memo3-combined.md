# Memo 3 (combined)

The Open Engineering Ecosystem should not be merely a reference system, but a
**generative** one: definitions should naturally lead to realizations. A
definition should not only describe an Element; it should also contain, or
point to, the means to construct it, validate it, evolve it, and relate it to
other Elements. That makes "building" an inherent property of the ecosystem
rather than an external activity.

For the `Hello, Pico!` example:

```text
Definition -> Realization -> Element -> Validation -> Feedback
```

- **Definition** expresses what `Hello, Pico!` means and the conditions it
  must satisfy.
- **Realization** expresses how it is constructed, using Sandcastle,
  Crossplane, and Kubernetes.
- **Element** is the actual Kubernetes Job running on MiniKube.
- **Validation** establishes whether the Element conforms to its Definition.
- **Feedback** can improve future Definitions and realization patterns.

This makes construction inherent to the ecosystem: a Definition carries a
structurally expressible path toward its possible realizations.

> Nothing is fully defined unless its possible realizations are also
> structurally expressible.

If the ecosystem itself can define, generate, relate, validate, and
operationalize Elements, it absorbs part of the role that external portal or
orchestration layers (such as Backstage) often play; it need not be the
primary source of truth.

---

## Architectural principles

An Open Engineering Ecosystem should treat definitions not as static
descriptions, but as **constructive sources**. A definition should make
possible the creation, validation, composition, and evolution of its Elements.
In such a system, realization is explicit, traceable, and testable, and each
realized Element contributes back to the refinement of future definitions.

1. **Definitions must be constructive** — a definition should not stop at
   meaning; it should also expose how a valid Element can come into being.
2. **Realization must be explicit** — the relation between a definition and
   an Element should be modeled directly, not left implicit in documentation
   or human interpretation.
3. **Construction must be traceable** — every realized Element should be
   linked to the definition, inputs, decisions, dependencies, and validations
   that shaped it.
4. **Validation must be intrinsic** — a realization is not complete merely
   because it exists; the ecosystem should be able to test whether it conforms
   to its definition.
5. **Composition must be native** — definitions and Elements should be
   composable, so larger structures can be assembled from smaller,
   already-defined parts.
6. **Evolution must feed back** — experience from realized Elements should
   refine the definitions they came from, so the ecosystem learns over time.
7. **Partial realization must be supported** — the model should recognize that
   Elements often emerge in stages rather than appearing fully formed.
8. **Semantics and operations must stay linked** — what something *is*, how it
   is *built*, and how it is *checked* should remain connected in one coherent
   structure.

---

## Meta-model

### Core classes

| Class          | Meaning                                                      |
|----------------|--------------------------------------------------------------|
| `Definition`   | What something is supposed to be                              |
| `Element`      | The actual realized thing in some state and context           |
| `Realization`  | The act or record of bringing an Element into existence from a Definition |
| `Constraint`   | Conditions that must hold                                     |
| `Validation`   | Checks that test whether the realization is acceptable        |
| `Dependency`   | What must already exist or be available                       |
| `Composition`  | How Elements can be assembled into larger Elements            |
| `Feedback`     | What learned experience flows back into the definitions       |

### Essential relations

- A `Definition` defines the allowable shape of an `Element`.
- An `Element` realizes a `Definition`.
- A `Realization` records how that happened.
- `Validation` determines whether the realization is sound.
- `Feedback` improves the `Definition` afterward.

### Realization patterns

Definitions could carry one or more realization patterns, for example:

- instantiate from template;
- compose from sub-elements;
- derive from upstream reference;
- adapt from prior realization;
- synthesize from rules.

### Lifecycle states

Elements often emerge in stages:

```text
Defined -> Packaged -> Provisioned -> Deployed -> Executed -> Validated
```

---

## Concrete example: `Hello, Pico!`

We do not treat a Pico as only a described thing. We treat the Pico
**definition** as the source from which a runnable Element can be realized,
checked, and operated.

### 1. Definition

A simplified Pico definition:

- **Name**: `hello-pico`
- **Purpose**: a minimal executable Element that demonstrates a complete
  realization path from definition to operation.
- **Semantic intent**: when executed, it produces the response `Hello, Pico!`.
- **Constraints**: must run as a Kubernetes Job; must complete successfully;
  must emit exactly `Hello, Pico!`.
- **Realization pattern**: package via Sandcastle -> provision/bind via
  Crossplane -> deploy as a Kubernetes Job.
- **Lifecycle states**: Defined -> Packaged -> Provisioned -> Deployed ->
  Executed -> Validated.

### 2. Realization

The Realization is the constructive bridge between idea and running thing.
Instead of saying "someone deployed a Job," the ecosystem can say:

> This Job is a realization of the `hello-pico` definition, produced by this
> realization path, under these constraints, with this validation evidence.

### 3. Element

The Element is the actual thing that exists at runtime — in this case, a
Kubernetes Job running on MiniKube. It is not just an operational artifact; it
is a typed realization within the ecosystem.

### 4. Role of the toolchain

| Component   | Role                                                  |
|-------------|-------------------------------------------------------|
| Sandcastle  | Helps realize the executable form                     |
| Crossplane  | Helps realize the infrastructural context             |
| Kubernetes  | Hosts the runnable Element                            |
| MiniKube    | Concrete local execution context                      |

### 5. Validation criteria

- The Job is accepted by the Kubernetes API.
- The Job starts successfully.
- The container completes successfully.
- The logs / output contain exactly `Hello, Pico!`.
- The realization is marked conformant.

### 6. Teaching narrative

> A Pico is not merely described in the Open Engineering Ecosystem; it is
> defined in a way that supports realization.
>
> In the `Hello, Pico!` example, the Pico definition states not only what the
> Pico means, but also how it may be validly realized. The definition includes
> its semantic intent, its constraints, its realization pattern, and its
> validation rules.
>
> The realization begins by constructing the executable form through
> Sandcastle. It then uses Crossplane to establish or bind the required runtime
> resources. The result is materialized as a Kubernetes Job running on
> MiniKube. When the Job executes and produces the output `Hello, Pico!`, the
> ecosystem can recognize this not simply as a successful run, but as a valid
> realized Element of the original Pico definition.

**One-sentence teaching principle**

> A Pico definition is complete only when it can guide the creation,
> deployment, and validation of a runnable Pico Element.

**Compact teaching line**

> A `Hello, Pico!` Element is valid not merely because it runs, but because its
> realization, dependencies, constraints, and validation evidence satisfy the
> ecosystem's shapes.

---

## OWL-style constructive schema

OWL expresses the constructive semantics of the ecosystem (what kinds of
things exist and how they relate). SHACL expresses the operational quality
gate for realized Elements (what a valid engineering record must contain).

```turtle
@prefix oee: <https://openengineering.example/ontology#> .
@prefix ex:  <https://academy.openengineering.example/pico#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

oee:Definition a owl:Class .
oee:Realization a owl:Class .
oee:Element a owl:Class .
oee:Constraint a owl:Class .
oee:Validation a owl:Class .
oee:Dependency a owl:Class .
oee:Feedback a owl:Class .

oee:realizes a owl:ObjectProperty ;
  rdfs:domain oee:Realization ; rdfs:range oee:Definition .

oee:produces a owl:ObjectProperty ;
  rdfs:domain oee:Realization ; rdfs:range oee:Element .

oee:conformsTo a owl:ObjectProperty ;
  rdfs:domain oee:Element ; rdfs:range oee:Definition .

oee:usesDependency a owl:ObjectProperty ;
  rdfs:domain oee:Realization ; rdfs:range oee:Dependency .

oee:checks a owl:ObjectProperty ;
  rdfs:domain oee:Validation ; rdfs:range oee:Element .

oee:validatesConstraint a owl:ObjectProperty ;
  rdfs:domain oee:Validation ; rdfs:range oee:Constraint .

oee:hasObservedOutput a owl:DatatypeProperty ;
  rdfs:domain oee:Element ; rdfs:range xsd:string .

oee:validationResult a owl:DatatypeProperty ;
  rdfs:domain oee:Validation ; rdfs:range xsd:string .
```

## SHACL operational quality gate

```turtle
@prefix oee: <https://openengineering.example/ontology#> .
@prefix ex:  <https://academy.openengineering.example/pico#> .
@prefix sh:  <http://www.w3.org/ns/shacl#> .

ex:HelloPicoElementShape a sh:NodeShape ;
  sh:targetClass oee:Element ;

  sh:property [
    sh:path oee:conformsTo ;
    sh:minCount 1 ;
    sh:maxCount 1 ;
    sh:hasValue ex:hello-pico-definition ;
  ] ;

  sh:property [
    sh:path oee:hasObservedOutput ;
    sh:minCount 1 ;
    sh:hasValue "Hello, Pico!" ;
  ] .

ex:HelloPicoValidationShape a sh:NodeShape ;
  sh:targetNode ex:hello-pico-job-001 ;

  sh:property [
    sh:path [ sh:inversePath oee:checks ] ;
    sh:minCount 3 ;
  ] .
```

## `Hello, Pico!` instance data

```turtle
@prefix oee: <https://openengineering.example/ontology#> .
@prefix ex:  <https://academy.openengineering.example/pico#> .

ex:hello-pico-definition a oee:Definition ;
  oee:name "Hello, Pico!" ;
  oee:semanticIntent "Emit the exact text Hello, Pico! once." ;
  oee:hasConstraint ex:exact-output, ex:kubernetes-job, ex:successful-completion .

ex:exact-output a oee:Constraint ;
  oee:rule "Observed output equals Hello, Pico!" .

ex:kubernetes-job a oee:Constraint ;
  oee:rule "The Element is materialized as a Kubernetes Job." .

ex:successful-completion a oee:Constraint ;
  oee:rule "The Job reaches successful completion." .

ex:hello-pico-realization-v1 a oee:Realization ;
  oee:realizes ex:hello-pico-definition ;
  oee:usesDependency ex:sandcastle, ex:crossplane, ex:minikube ;
  oee:produces ex:hello-pico-job-001 .

ex:sandcastle a oee:Dependency ;
  oee:name "Sandcastle" ;
  oee:purpose "Package the Pico realization." .

ex:crossplane a oee:Dependency ;
  oee:name "Crossplane" ;
  oee:purpose "Declare and bind the required infrastructure and platform resources." .

ex:minikube a oee:Dependency ;
  oee:name "MiniKube" ;
  oee:purpose "Provide the local Kubernetes runtime." .

ex:hello-pico-job-001 a oee:Element ;
  oee:conformsTo ex:hello-pico-definition ;
  oee:hasObservedOutput "Hello, Pico!" ;
  oee:hasState "Completed" .

ex:output-validation a oee:Validation ;
  oee:checks ex:hello-pico-job-001 ;
  oee:validatesConstraint ex:exact-output ;
  oee:validationResult "passed" .

ex:job-form-validation a oee:Validation ;
  oee:checks ex:hello-pico-job-001 ;
  oee:validatesConstraint ex:kubernetes-job ;
  oee:validationResult "passed" .

ex:completion-validation a oee:Validation ;
  oee:checks ex:hello-pico-job-001 ;
  oee:validatesConstraint ex:successful-completion ;
  oee:validationResult "passed" .
```

---

## Teaching interpretation

Sandcastle, Crossplane, and MiniKube are not incidental implementation
details. They are declared dependencies of a specific Realization. The
Kubernetes Job is therefore a first-class Element in the ecosystem, linked to
its Definition, construction path, observed output, and proof of conformance.

A Backstage-like portal can still provide a useful user interface over this
information, but it need not be the primary source of truth. The Open
Engineering Ecosystem itself holds the connected reference model and the
construction logic.

OWL captures the semantic structure; SHACL (or rules) capture operational
completeness and conformance checking.
