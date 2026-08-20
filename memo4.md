# Memo 4 — Pico-to-Pico Identity in Pico Engine 1.6

Project: Open Engineering Picos  
Domain: Pico Identity / Trust / Messaging  
Status: Architecture Reference  
Date: 2026-08-12  
Source: Phil Windley, Pico-to-Pico Identity Arrives, Technometria, 12 August 2026  
Pico Engine: 1.6  

Source article: Pico-to-Pico Identity Arrives — Technometria  

⸻

## Purpose

This memo records the Pico-to-Pico identity architecture introduced with Pico Engine 1.6 and describes its significance for Open Engineering Picos.

Version 1.6 represents an important architectural milestone: a Pico is no longer identified merely by an address or channel on a particular Pico Engine. Every Pico now receives its own cryptographic identity.

The architecture combines:

* did:webvh for a Pico’s public and potentially portable identity;
* did:peer for private pairwise relationship identities;
* DIDComm for encrypted communication between Picos;
* subscriptions for establishing Pico-to-Pico relationships;
* existing Pico channel policies for authorization.

This establishes the foundations for portable Picos, portable Pico meshes, decentralized trust between meshes, and eventually verifiable credentials and identity-aware authorization. (technometria.com)

⸻

## Context

Pico Engine 1.5 introduced two of three identity planes:

1. Human → Pico mesh
    * Passkey/WebAuthn authentication.
2. Pico → Pico
    * Cryptographic Pico identity and mutual relationships.
3. Third party → Pico mesh
    * OAuth-based access for applications and webhooks.

Version 1.5 implemented the first and third planes. Pico Engine 1.6 implements the missing Pico-to-Pico plane. (technometria.com)

This separation is important.

Authentication of a human, authorization of an external application, and identity between autonomous Picos are distinct architectural problems and should remain distinct within Open Engineering.

⸻

## Pico Engine 1.6

The central change in Pico Engine 1.6 is simple to state:

Every Pico now has its own cryptographic identity.

More importantly, that identity is intended to be able to travel with the Pico rather than merely identifying where the Pico currently happens to execute.

Previously, a channel identifier could answer:

How do I communicate with this Pico on this engine?

It could not provide a durable answer to:

Which Pico is this?

Pico Engine 1.6 introduces DIDs as the answer to the second question. (technometria.com)

⸻

## Two DIDs, Two Responsibilities

Every Pico uses two kinds of Decentralized Identifiers.
```
Pico
│
├── did:webvh
│   └── Public / portable Pico identity
│
└── did:peer
    ├── Relationship A
    ├── Relationship B
    └── Relationship C
```
The distinction is deliberate.

A Pico should not expose one universal identifier for every relationship it participates in.

Instead, the architecture separates identity from relationship identity.

⸻

## did:webvh — The Pico Passport

Every Pico receives a did:webvh when it is created.

The Pico Engine publishes the corresponding DID document at a stable URL so that another participant can resolve the identity.

Conceptually, the did:webvh is the Pico’s:

passport

It is the identity a Pico can present when introducing itself to another Pico that does not yet know it.

Its responsibilities include:

* public identification;
* DID resolution;
* cryptographic introduction;
* establishing new relationships;
* forming the basis for Pico portability.

The did:webvh is therefore primarily an introduction identity, not the identifier that should be reused for every subsequent interaction. (technometria.com)

⸻

## did:peer — The Relationship Identity

Once two Picos decide to establish a relationship, they create pairwise did:peer identities.

A new pair is created for each relationship.

For example:
```
Pico A
  did:webvh:A
Pico B
  did:webvh:B
Introduction
     │
     ▼
Subscription
  A → did:peer:A-B
  B → did:peer:B-A
```
These peer DIDs are private to that relationship.

A useful analogy from the architecture is:
```
did:webvh = passport
did:peer  = private address given to one relationship
```
This provides significant isolation.

If a relationship is compromised, its peer DID can be rotated, removed, or recreated without changing the Pico’s other relationships.

Thus:
```
Pico
 ├── Relationship A → did:peer:...
 ├── Relationship B → did:peer:...
 └── Relationship C → did:peer:...
```
Relationship B can be replaced without affecting A or C. (technometria.com)

⸻

## Subscriptions Become Cryptographic Relationships

Picos that are not related through the parent/child hierarchy communicate using subscriptions.

A subscription is a pairwise relationship represented on both sides.

In Pico Engine 1.6, a Pico can initiate a subscription using the recipient’s did:webvh.

Conceptually:
```
Pico A
   │
   │ recipient did:webvh
   ▼
Resolve Pico B identity
   │
   ▼
Introduction handshake
   │
   ▼
Create peer DIDs
   │
   ▼
Establish subscription
   │
   ▼
Encrypted relationship
```
Once the relationship exists, events and queries use that peer relationship rather than repeatedly relying on the public identity. (technometria.com)

⸻

## DIDComm

Cross-mesh and cross-engine Pico communication now uses DIDComm.

This is a particularly important architectural development.

Two Picos may exist:
```
Mesh A                          Mesh B
┌──────────────────┐          ┌──────────────────┐
│ Pico Engine A    │          │ Pico Engine B    │
│                  │          │                  │
│   Pico A         │ DIDComm  │   Pico B         │
│   did:peer:A ───────────────►│   did:peer:B     │
│                  │ encrypted│                  │
└──────────────────┘          └──────────────────┘
```
When communication occurs within the same mesh, the engine can keep the traffic local.

When communication crosses meshes or engines, DIDComm provides encrypted communication using the peer relationship. (technometria.com)

⸻

## Identity Does Not Replace Authorization

A particularly useful design decision is that the new DID infrastructure does not replace the existing Pico channel authorization model.

The responsibilities remain separate.
```
DID
 │
 └── Who is the other party?
Channel / ECI policy
 │
 └── What may that party do?
```
A subscription’s peer DID acts as its channel identity, while existing channel policy determines what that relationship may do.

This gives Open Engineering an important architectural principle:

Identity establishes who; policy establishes what.

The Pico Engine therefore gains cryptographic identity without requiring its authorization model to be rewritten at the same time. (technometria.com)

⸻

## Parent/Child Communication

Not every Pico relationship requires a DID.

Legacy ECIs remain relevant.

Parent and child Picos continue communicating over their family channels using ECIs.

This gives two useful relationship classes:
```
Pico relationships
├── Family relationship
│   ├── parent
│   └── child
│
│   Identity/addressing:
│   ECI
│
└── External relationship
    └── subscription
    Identity:
    did:webvh → introduction
    did:peer  → established relationship
```
A full DID-based introduction would be unnecessary overhead for relationships already established structurally within a Pico family. (technometria.com)

⸻

## Trust Between Previously Unrelated Picos

One of the most significant consequences of the architecture is that Picos belonging to different meshes can establish relationships without requiring a central federation.

For example:
```
Alice's Mesh                       Bob's Mesh
┌───────────────┐                 ┌───────────────┐
│ Pico A        │                 │ Pico B        │
│               │                 │               │
│ did:webvh:A   │                 │ did:webvh:B   │
└───────┬───────┘                 └───────┬───────┘
        │                                 │
        └──────── introduction ───────────┘
                       │
                       ▼
                subscription
                       │
                       ▼
               peer DID relationship
```
Neither mesh needs:

* a shared identity provider;
* a central broker;
* a preconfigured federation agreement;
* a shared Pico Engine.

The parties can resolve identities, agree to establish a relationship, and create pairwise identities.

This supports the Pico principle that:

The relationship is the unit of trust.

Pico Engine 1.6 makes that relationship cryptographic and increasingly portable. (technometria.com)

⸻

## Why did:webvh + did:peer?

The article explicitly considers KERI as an alternative.

KERI has attractive properties, particularly self-certifying identifiers and key-event histories that do not depend upon a web-hosted identity document.

For Pico Engine 1.6, however, the architecture prioritizes not merely identification but what happens immediately afterwards:

communication.

Picos exchange events and queries.

DIDComm already provides the encrypted messaging model needed for those interactions, and did:peer is naturally suited to private pairwise DIDComm relationships.

The resulting combination is therefore:
```
did:webvh
    │
    │ discovery / introduction
    ▼
did:peer
    │
    │ private relationship
    ▼
DIDComm
    │
    │ encrypted communication
    ▼
Pico events + queries
```
KERI remains architecturally interesting and could potentially be reconsidered if stronger portability requirements make the URL dependency of did:webvh problematic. (technometria.com)

⸻

## Portability

Pico Engine 1.6 should not be interpreted as completing Pico portability.

It provides an essential prerequisite.

Currently, the Pico Engine’s base URL remains part of the Pico’s did:webvh.

Therefore moving:
```
Pico
Engine A
   │
   ▼
Engine B
```
does not yet mean its identity can automatically move unchanged.

Nevertheless, the difficult architectural foundation now exists:
```
Portable Pico
     │
     ├── cryptographic identity       ✓
     ├── pairwise relationships       ✓
     ├── encrypted communication      ✓
     │
     ├── fully portable did:webvh     future
     ├── portable key management      future
     └── credential portability       future
```
This is a significant step toward meshes that are owned independently of the engines on which they happen to run. (technometria.com)

⸻

## Remaining Work

Phil Windley identifies several areas that remain incomplete.

Full Identity Portability

The did:webvh currently contains an engine-dependent URL.

A future architecture needs to allow Pico migration without breaking identity resolution.

Verifiable Credentials

Picos can now cryptographically establish:

who they are.

They cannot yet provide signed claims describing:

what they are;

or:

what authority they possess.

Verifiable Credentials are therefore a natural next layer.

Key Management

DID private keys currently reside in the Pico Engine’s own storage.

Longer term, these should move toward facilities such as:

* operating-system key vaults;
* hardware-backed key storage;
* secure enclaves;
* external key-management systems.

Key rotation and recovery also need further development.

A particularly important design objective follows:

Losing a cryptographic key should not mean losing the Pico.

Identity-Aware Authorization

Authorization currently remains primarily channel based.

A future authorization system could make decisions based upon the authenticated identity behind the channel.

Conceptually:
```
Current
Channel
   │
   ▼
Policy
   │
   ▼
Permit / Deny
Future
Authenticated Pico Identity
        │
        ├── credentials
        ├── relationship
        ├── requested action
        ├── resource
        └── context
                │
                ▼
        Authorization Engine
                │
                ▼
          Permit / Deny
```
This could become especially significant for Open Engineering’s agentic systems. (technometria.com)

⸻

## Implications for Open Engineering

Pico Engine 1.6 should influence the Open Engineering Pico architecture rather than being treated merely as a Pico Engine implementation detail.

In particular, Open Engineering should distinguish the following concepts.
```
Pico
│
├── Identity
│   └── did:webvh
│
├── Relationships
│   └── did:peer
│
├── Communication
│   └── DIDComm
│
├── Addressing
│   └── ECI / channels
│
├── Authorization
│   └── channel policy
│
└── Future claims
    └── Verifiable Credentials
```
These should remain separate concepts in Open Engineering definitions, conventions, parsers, rules and implementations.

⸻

## Implications for Pico Definitions

The Open Engineering definition of a Pico should now account for cryptographic identity.

Conceptually, a Pico definition may eventually contain:
```
identity:
  type: did
  public:
    method: webvh
relationships:
  identity:
    method: peer
messaging:
  protocol: didcomm
authorization:
  mechanism: channel-policy
```
This example is illustrative rather than a proposed final schema.

The important architectural point is that identity should become a first-class property of a Pico rather than an implementation-specific extension.

⸻

## Implications for Pico Rules

Rules and rulesets should be able to reason about:

* the identity of another Pico;
* establishment of subscriptions;
* acceptance or rejection of introductions;
* relationship lifecycle;
* relationship-specific authorization;
* key rotation;
* relationship termination;
* credentials when those become available.

This means Pico rules can increasingly express trust relationships, not merely event-processing behavior.

⸻

## Implications for Pico Parsers

Open Engineering Pico parsers should preserve the distinction between:
```
Identity
Relationship
Address
Authorization
Messaging
```
A parser should not treat a DID merely as another form of ECI.

They serve different semantic purposes.

An ECI primarily identifies a communication channel.

A DID identifies a cryptographic actor or relationship.

That distinction should survive translation between Open Engineering definitions and Pico Engine/Manifold representations.

⸻

## Implications for Manifold

The next stated goal for the Pico Engine identity implementation is exercising these capabilities through Manifold.

This is directly relevant to Open Engineering’s use of Manifold as a Pico runtime environment.

A future Open Engineering composition could therefore look approximately like:
```
Open Engineering Pico Definition
              │
              ▼
       Pico Composition
              │
              ▼
         Crossplane
              │
              ▼
          Kubernetes
              │
              ▼
          Manifold
              │
              ▼
        Pico Engine 1.6+
              │
              ├── did:webvh
              │
              ├── did:peer
              │
              ├── DIDComm
              │
              └── channel policy
```
Identity therefore becomes part of the runtime realization of a declaratively composed Pico.

⸻

## Implications for Open Engineering Identity

This development also suggests an important distinction between an Open Engineering Identifier and a cryptographic runtime identity.

They should not necessarily be collapsed into the same identifier.

For example:
```
Open Engineering Identity
OE Identifier
    │
    │ semantic / catalog identity
    ▼
oep.pico.example.01
        +
Pico Runtime Identity
    │
    │ cryptographic identity
    ▼
did:webvh:...
        +
Relationship Identity
    │
    │ private pairwise identity
    ▼
did:peer:...
```
These answer different questions:

| Identifier | Question |  
| Open Engineering Identifier | What Open Engineering element is this? |  
| did:webvh | Which cryptographic Pico is this? |  
| did:peer | Which private relationship is this? |  
| ECI | Through which Pico channel may communication occur? | 

This separation should be preserved.

⸻

## Strategic Direction

Pico Engine 1.6 moves Picos closer to a model in which they are genuine autonomous actors rather than objects hosted by a particular server.

The progression can be understood as:
```
Addressable Pico
      │
      ▼
Identifiable Pico
      │
      ▼
Cryptographically identifiable Pico
      │
      ▼
Relationship-aware Pico
      │
      ▼
Portable Pico
      │
      ▼
Credential-bearing Pico
      │
      ▼
Identity-aware autonomous actor
```
Pico Engine 1.6 reaches an important point in this progression: cryptographic identity plus private cryptographic relationships.

⸻

## Open Engineering Recommendation

Open Engineering Picos should adopt the Pico Engine 1.6 identity architecture as a first-class concern in its Pico model.

Specifically:

1. Treat Pico identity separately from Pico addressing.
2. Model did:webvh as the Pico’s public cryptographic identity.
3. Model did:peer as relationship-specific identity.
4. Treat subscriptions as first-class trust relationships.
5. Treat DIDComm as the transport/security mechanism for cross-mesh Pico communication.
6. Preserve channel policy as a separate authorization concern.
7. Keep Open Engineering Identifiers separate from runtime DIDs.
8. Prepare the Pico model for Verifiable Credentials.
9. Prepare for identity-aware authorization.
10. Avoid assumptions that bind a Pico permanently to a particular Pico Engine.

This is especially important for the Open Engineering goal of declaratively composing Picos and deploying them into environments such as Manifold.

The desired end state should not merely be:

Deploy this Pico.

It should increasingly become:

Compose this Pico, establish its identity, deploy it, establish its relationships, authorize its interactions, and allow it to move without losing who it is.

That is a substantially stronger abstraction.

⸻

## Architectural Principle

The Pico Engine 1.6 architecture can be summarized with five complementary concepts:
```
Identity says who the Pico is.
Relationships say who it knows.
DIDComm protects how they communicate.
Channels define where interaction occurs.
Policy determines what the relationship may do.
```
Together these turn Pico-to-Pico communication from simple message routing into an identity-aware trust architecture.

⸻

## References

* Phil Windley — Pico-to-Pico Identity Arrives — primary source, published 12 August 2026.
* Phil Windley — Identity for the Pico Engine — background on Pico Engine 1.5 and the three identity planes.
* PicoLabs Identity System documentation — Pico Engine identity architecture and implementation documentation.

⸻

## Conclusion

Pico Engine 1.6 introduces the missing identity layer required for Picos to behave as independent actors across Pico meshes and engines.

The combination of:
```
did:webvh
   +
did:peer
   +
DIDComm
   +
Subscriptions
   +
Channel Policy
```
creates a coherent architecture for cryptographic Pico relationships.

For Open Engineering Picos, this should be treated as a foundational capability rather than an optional security feature.

It provides the basis for a future in which a Pico is defined independently, cryptographically identifiable, relationship-aware, securely connected, policy governed, and ultimately portable between execution environments without losing its identity.
