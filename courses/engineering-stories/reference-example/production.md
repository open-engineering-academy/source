# Production — How We Render It

The screenplay is an **intermediate representation**. This file documents one
concrete renderer for it: an AI audio production workflow that turns the
screenplay into a finished audio artifact.

Remember the course's architectural principle: the *renderer is not the subject
of the course*. We document it here because learners need at least one working
production path, but the methodology in this example does not depend on any one
vendor.

## Capabilities we require of a producer

Declare the production **capabilities** as neutral requirements first, so the
course never hard-codes a dependency on one service:

```yaml
capabilities:
  multi_voice: true      # distinct character voices
  narration: true        # a separate narrator voice
  sound_effects: true    # scripted SFX events
  ambience: true         # background environment beds per scene
  scene_control: true    # place voices/SFX/ambience per scene
  audio_export: true     # export a finished audio file
```

A provider is then *evaluated against these requirements*, rather than assumed.

## Known-good provider: Wondercraft

**Wondercraft** is the initially **validated provider** used by the reference
implementation. It satisfies the capability list above and offers a
script-based, scene-oriented workflow that matches our screenplay format.

Workflow:

1. **Import the screenplay** — copy each scene's dialogue and narration into the
   producer's script, one speaker per line.
2. **Assign voices** — bind each character (Customer, Server, Chef, Apprentice,
   Manager, Narrator) to a distinct AI voice. Keep each character's voice
   consistent across scenes.
3. **Add ambience per scene** — set an environment bed (restaurant, kitchen,
   front of house) per scene.
4. **Insert sound effects** — place SFX events exactly where the screenplay
   calls for them (ticket printer, recipe book, service bell, alarm).
5. **Preview and adjust pacing** — extend the pauses before the closing
   narration of each scene so the listener has time to absorb the outcome.
6. **Export** — produce the final audio artifact (e.g. `audio-play.mp3`).

## Renders are one of many

The screenplay should remain usable by other renderers without modification:

- another AI audio system,
- human voice actors,
- a conventional studio production,
- (future) an automated Open Engineering Composer that generates a first
  screenplay draft from structured engineering knowledge.

## Licensing and free-tier caveats

- Share the audio artifact where repository policy and licensing permit, and
  otherwise link to the published artifact.
- Free tiers of commercial services may introduce **watermarks,
  advertisements, generation limits, or restricted exports**, and these
  conditions can change over time.
- Do not treat current pricing as stable course content — requirements and
  capabilities are what the course documents, not today's prices.

## What the renderer may and may not "fix"

- The renderer may fix **pronunciation and pacing** (a rendering concern).
- The renderer may **not** fix the architecture, the metaphor, or the story.
  Those are decided upstream, in the model — see `evaluation.md`. A bad
  pronunciation belongs in rendering; a wrong explanation does not.
