# Open Engineering Academy Handout: From Definition to a Running Pico

## Core idea

In the Open Engineering Ecosystem, an Element is not merely documented by its Definition. It is constructed as a traceable realization of that Definition.

For the `Hello, Pico!` example:

```text
Definition -> Realization -> Element -> Validation -> Feedback
```

- **Definition** expresses what `Hello, Pico!` means and the conditions it must satisfy.
- **Realization** expresses how it is constructed, using Sandcastle, Crossplane, and Kubernetes.
- **Element** is the actual Kubernetes Job running on MiniKube.
- **Validation** establishes whether the Element conforms to its Definition.
- **Feedback** can improve future Definitions and realization patterns.

This makes construction inherent to the ecosystem: a Definition carries a structurally expressible path toward its possible realizations.

## OWL-style constructive schema

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

## Teaching interpretation

Sandcastle, Crossplane, and MiniKube are not incidental implementation details. They are declared dependencies of a specific Realization. The Kubernetes Job is therefore a first-class Element in the ecosystem, linked to its Definition, construction path, observed output, and proof of conformance.

A Backstage-like portal can still provide a useful user interface over this information. But it need not be the primary source of truth. The Open Engineering Ecosystem itself holds the connected reference model and the construction logic.