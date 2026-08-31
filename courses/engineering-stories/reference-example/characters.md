# Characters — Responsibilities in Disguise

Characters are **not** arbitrary decoration. Each one represents a
responsibility in the system, and each line of dialogue is an explanation of a
system interaction. That is what makes the story teach rather than merely
entertain.

For the Crossplane restaurant we need exactly enough characters to carry every
responsibility in `concept.md` — but no more.

## The cast

| Character | Represents | Responsibility in the story | Typical line |
| --- | --- | --- | --- |
| Customer | Developer | Requests a composite environment | "I would like one application environment." |
| Server | Claim (XRC) | Carries the request to the kitchen as an order ticket | "Right away. Your order is placed." |
| Chef | Crossplane + Composition | Receives the order, selects the recipe, composes the dish | "Certainly. I'll use the recipe for that order." |
| Apprentice | Composition → Managed Resources | Helps assemble the prepared components for the dish | "Shall I prepare the components, Chef?" |
| Kitchen staff / appliances | Provider | Realize the prepared components in the real world | "[SFX: kitchen activity]" / "The oven is on." |
| Manager | Reconciliation | Keeps checking the dish until it matches the order perfectly | "The dish is not quite right. Adjust." |

### Roles vs. things

Notice that a character may represent a *role or process* (Chef = the engine and
its recipe selection) rather than a single object. What matters is that the
listener can attach a name to each responsibility and follow the conversation
from responsibility to responsibility.

## Dialogue as system interaction

Dialogue should *carry* the explanation. Compare:

- **Narration:** "The developer creates a composite resource." (tells)
- **Dialogue:** "One application environment, please." → "Certainly — I'll use
  the recipe associated with that order." (shows the responsibility hand-off)

Prefer dialogue for the *relationships* and *state transitions* that matter most;
reserve narration for connective tissue that has no character voice.

## Constraints

- Every character must trace back to the mapping in `metaphor.md`.
- No character should be introduced purely for comic effect without a
  responsibility behind it.
- Keep the cast small (here: five voices). A listener cannot track more than a
  handful of audio-only characters.
- Voice identity matters: in audio, each character needs a *distinct voice*, so
  the cast size is bounded by the production's available distinct voices.
