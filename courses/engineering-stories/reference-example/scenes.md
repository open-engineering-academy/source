# Scenes — The Story in Beat-Sized Pieces

A scene is the unit the listener experiences and the worker the producer
renders. Every scene has a **purpose**, a **location**, **participating
characters**, and — most importantly — an **educational outcome**: *what should
the learner understand after hearing this scene?*

## Narrative arc

The scenes trace a deliberate dramatic structure — not documentation read aloud:

```
Introduction  →  A developer wants an environment.
Question      →  How can one request become a whole running system?
Discovery     →  Menu, order, recipe, components.
Increasing complexity → The kitchen prepares each component.
Challenge     →  The dish must be re-checked to match the order exactly.
Climax        →  The abstraction is why it works: one request, many components.
Resolution    →  The metaphor reconnects to Crossplane.
Technical takeaway → The developer never talks to providers directly.
```

## Scene plan

### SCENE 01 — THE FRONT OF HOUSE
- **Purpose:** Introduce the Customer and the request.
- **Location:** Restaurant entrance / foyer.
- **Characters:** Customer, Server.
- **Ambience:** Soft restaurant noise.
- **Educational outcome:** The developer asks for a *composite* environment, not
  the individual pieces.

### SCENE 02 — ORDER PLACED
- **Purpose:** Show that the request becomes a concrete order ticket (XRC → XR).
- **Location:** The service counter.
- **Characters:** Customer, Server.
- **Ambience:** Ticket printer.
- **Educational outcome:** A claim creates a composite resource — the request
  becomes a concrete instance.

### SCENE 03 — THE KITCHEN
- **Purpose:** Show the Chef matching the order to a recipe (Composition).
- **Location:** Busy restaurant kitchen.
- **Characters:** Chef, Apprentice.
- **Ambience:** Kitchen activity; ticket printer.
- **Educational outcome:** An XR is matched to a Composition — the recipe says how
  it is built.

### SCENE 04 — PREPARING THE COMPONENTS
- **Purpose:** Show the recipe generating the individual prepared components.
- **Location:** Kitchen prep stations.
- **Characters:** Chef, Apprentice, Kitchen staff.
- **Ambience:** Preparation sounds (chopping, pans, oven).
- **Educational outcome:** A Composition generates many Managed Resources;
  composed means *many into one*.

### SCENE 05 — THE KITCHEN CAPABILITY
- **Purpose:** Show how the real components are actually realized.
- **Location:** Appliances / far side of kitchen.
- **Characters:** Kitchen staff, Chef.
- **Ambience:** Appliances running.
- **Educational outcome:** Providers realize the Managed Resources in the real
  world; the developer does not talk to them directly.

### SCENE 06 — PERFECTING THE DISH
- **Purpose:** Show reconciliation — checking and re-checking until the dish
  matches the order.
- **Location:** Chef's pass / plating area.
- **Characters:** Chef, Manager.
- **Ambience:** Service bell, kitchen alarm.
- **Educational outcome:** Reconciliation continuously converges desired and
  observed state; failure triggers action.

### SCENE 07 — SERVED AND CONNECTED
- **Purpose:** Reconnect the metaphor to Crossplane and land the takeaway.
- **Location:** Table / front of house.
- **Characters:** Customer, Server, Chef.
- **Ambience:** Service bell (success), then quiet.
- **Educational outcome:** The developer receives the composite environment; the
  abstraction is *why* one request becomes a working whole.

## What every scene must answer

Write each scene so that, afterwards, the learner can answer:

> *What did I learn about the technical model from this scene?*

If a scene cannot answer that clearly, tighten it — or cut it.
