# Screenplay — The Intermediate Representation

The screenplay is the **audio-first, scene-oriented** representation that sits
between the technical knowledge and the rendered audio. It must be renderable by
an AI audio producer, human actors, or conventional studio work — and it must be
useful *independently* of the renderer.

Two rules govern this file:

1. **If the listener cannot hear it, it does not exist.** Every important action
   must reach the ear through at least one of: dialogue, narration, sound
   effect, ambience, or music. (Contrast with a *visual* screenplay, where
   staging can show actions that the ear would otherwise miss.)
2. **Sound is semantic.** Sound effects are not decoration; each one represents
   an event or state in the technical model.

## Sound vocabulary (semantic sound design)

| Event / state (from `concept.md`) | Sound |
| --- | --- |
| Claim submitted / XR created | Ticket printer |
| Composition selected | Recipe book opening |
| Managed resources created | Kitchen preparation sounds |
| Provider operation | Appliance / kitchen activity |
| Successful reconciliation | Service bell |
| Reconciliation failure | Kitchen alarm or interruption |

---

## SCENE 01 — THE FRONT OF HOUSE

**AMBIENCE:** Soft restaurant noise; chairs; light clatter.
**NARRATOR:** It is a busy evening at the Crossplane Restaurant, and a new guest
has just arrived.

**CUSTOMER:** (warm, clear) Excuse me. I'd like an application environment,
please.

**SERVER:** Of course. An application environment — one moment while I check the
menu.

**SFX:** Menu pages turning.

**SERVER:** We have exactly what you need. Right this way.

**NARRATOR:** The customer has asked for a *composite* thing — one environment —
not for a pile of separate pieces.

---

## SCENE 02 — ORDER PLACED

**LOCATION:** Service counter.
**AMBIENCE:** Counter sounds; distant kitchen.
**SFX:** Ticket printer ratcheting.

**SERVER:** Your order for one application environment is placed.

**SFX:** Ticket torn from the rail.

**NARRATOR:** That order ticket is now the customer's *actual request* — the
concrete instance of what was asked for.

**SERVER:** It's on its way to the kitchen, Chef will take it from here.

---

## SCENE 03 — THE KITCHEN

**LOCATION:** Busy restaurant kitchen.
**AMBIENCE:** Hustle; pans; tickets.
**SFX:** Ticket printer.

**CHEF:** Apprentice! New order!

**APPRENTICE:** What did they ask for, Chef?

**CHEF:** One application environment.

**APPRENTICE:** And how do we know how to build it?

**SFX:** Recipe book opening.

**CHEF:** We follow the recipe. Every application environment has a recipe — it
tells us exactly which components go in, and in what order.

**NARRATOR:** The chef matched the order to its recipe. That is the same as an
engine matching a composite resource to its Composition.

---

## SCENE 04 — PREPARING THE COMPONENTS

**LOCATION:** Kitchen prep stations.
**AMBIENCE:** Chopping; pans; oven door.
**SFX:** Preparation sounds build.

**APPRENTICE:** One application environment — that's networking, compute,
storage, and a few more. Shall I prepare them all, Chef?

**CHEF:** Yes. Prepare each component exactly as the recipe says.

**SFX:** Multiple prep sounds layered — many hands working.

**NARRATOR:** The recipe doesn't make one thing. It *composes* several prepared
components — many resources, all brought together into one dish.

**CHEF:** (proud) One order. Many components. That's the whole trick.

---

## SCENE 05 — THE KITCHEN CAPABILITY

**LOCATION:** Appliances / far side of the kitchen.
**AMBIENCE:** Ovens, vents, appliances running.

**APPRENTICE:** Chef, the pots are on — the oven's going, the vents are up. The
components are becoming real.

**SFX:** Appliance hum and clatter.

**CHEF:** Good. The kitchen itself makes these real. That's not the customer's
business — they only ever see the finished dish.

**NARRATOR:** Real ingredients are produced by the kitchen's own capabilities.
In Crossplane, providers are those capabilities — they realize the managed
resources out in the real world. The developer never talks to them directly.

---

## SCENE 06 — PERFECTING THE DISH

**LOCATION:** Chef's pass / plating area.
**AMBIENCE:** Busy pass; plates.

**MANAGER:** Chef — the order says one application environment. The plate has
networking, and storage, but the compute isn't right yet.

**SFX:** Kitchen alarm — a short, corrective chime.

**CHEF:** Then we adjust. Service isn't done until the dish matches the order.

**SFX:** Prep sounds resume; correction work.

**NARRATOR:** The staff keep checking the dish against the order and fixing any
difference. This is reconciliation — reality is continuously pulled back to the
desired state, not just once at the start.

**SFX:** Service bell, richer.

**MANAGER:** Now it matches. Every component, exactly right.

---

## SCENE 07 — SERVED AND CONNECTED

**LOCATION:** Table / front of house.
**AMBIENCE:** Restaurant settling; quieter.
**SFX:** Service bell (success); plate set down.

**SERVER:** One application environment, as ordered. Is everything to your
satisfaction?

**CUSTOMER:** It's exactly what I asked for. But tell me — I never saw any of
how it was made.

**CHEF:** (darkly cheerful) You weren't supposed to. You order the dish; the
kitchen makes it real. That's the point.

**NARRATOR:** One order, a recipe, a kitchen full of capabilities, and an
endless watchful perfection of the dish. That is Crossplane: the developer
requests the composite environment, and the platform composes, realizes, and
reconciles it — so the developer never has to assemble the infrastructure by
hand.

**SFX:** Final service bell; warm kitchen fade-out.

---

## Production notes for the renderer

- Keep voices distinct: Customer (warm), Server (bright), Chef (steady,
  commanding), Apprentice (young, quick), Manager (calm, precise).
- Use the sound vocabulary faithfully — the ticket printer, the recipe book, the
  prep layer, the appliance hum, the service bell, and the alarm each mark a
  specific technical event.
- Every scene ends on a note that helps the listener answer the scene's
  educational outcome. Do not rush the narration lines that close scenes 03–06.
