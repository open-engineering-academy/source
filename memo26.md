# Memo 26: Minimal capsule contract proposal (v0.1)

**Target Repository:** `open-engineering-capsules/source`

## Status

Proposal only. Produces `memo26.md` at this repository's root; nothing
under `definitions/`, `bin/pico`, `courses/`, `labs/`, the OELS gate,
or any CI workflow is changed. The capsule contract described below is
addressed to `open-engineering-capsules/source` (the definitions org
for capsules, symbol `Cl`) and is not an Academy artefact. Every YAML
block in this memo is labelled **illustrative; not valid until adopted
upstream** and has no on-disk consumer in this repository.

## Purpose

Memo 23 (§3.2, §9 step 2) forbids inventing a course-specific capsule
format and requires the canonical capsule contract to live upstream.
Memo 24 §2.1 records that `open-engineering-capsules/source` today
contains only `README.md` and a generated-placeholder `metadata.yaml`
(`lifecycle: proposed`), with no schema, no conventions, no example,
and no composition rule, so no such contract currently exists. Memo 24
§4 records that this is the single upstream prerequisite that blocks
Memo 23 Modules 2–4.

This memo proposes the smallest possible capsule definition contract
(v0.1) that would let Modules 2–4 be taught, so the owning repository
can adopt, amend, or reject it before the Academy depends on it. The
Academy will not ship a capsule format of its own regardless of the
outcome.

## 1. Required field set (minimal)

Exactly one new `kind: Capsule` target shape is proposed. Required
fields are limited to the four groups Modules 2–4 cannot be taught
without:

| Required field | Memo 23 §3.2 item | Why required at v0.1 |
|---|---|---|
| `apiVersion`, `kind`, `metadata.name`, `metadata.version` | Identity and version | Module 2 (Define a capsule) cannot address a capsule or pin a version without them. |
| `spec.capability` | Capability and purpose (capability name) | Module 4 (Compose a Pico) must bind a Pico's declared capability requirement to exactly one capsule by name. |
| `spec.inputs`, `spec.outputs` | Inputs and outputs | Module 3 (Implement and test a capsule) tests a capsule against its contract; a contract with no inputs/outputs is not testable. |
| `spec.dependencies` | Dependencies and capability requirements | Module 4's "dependency resolution" and §5 rule 3 (Explicit dependencies) require declared capability dependencies; may be the empty list `[]`. |

Everything else listed in Memo 23 §3.2 is **optional** at v0.1, each
with a one-line rationale for why it is not required to teach
Modules 2–4:

- `spec.purpose` (free-text) — optional: documentation, not needed to
  validate or compose.
- `spec.interfaces`, `spec.events` — optional: Module 3 can test a
  capability through `spec.inputs`/`spec.outputs` alone; richer
  interface or event surfaces are additive.
- `spec.config`, `spec.secrets` — optional: §5 rule 8 (Secure
  configuration) applies when a capsule needs configuration or
  secrets; many capsules (e.g. the Module 3 greeting) need neither.
- `spec.lifecycle` — optional: §5 rule 1 (Minimal core) keeps
  lifecycle on the Pico runtime, not inside every capsule.
- `spec.compatibility` — optional: §5 rule 6 (Compatibility checks)
  can be satisfied by `metadata.version` alone at v0.1; richer
  constraints are a v0.2 concern.
- `spec.health`, `spec.tests` — optional: §5 rule 10 (Observable
  operation) and the test discipline in Module 3 can be met by the
  capsule implementation without a schema slot in v0.1.
- `spec.permissions`, `spec.resources` — optional: §5 rule 8 and
  Module 6 operational concerns apply when a capsule needs them;
  the Module 3 greeting needs neither.

v0.1 deliberately picks the smallest field set that keeps Modules 2–4
teachable. The owning repository may promote any optional field to
required before adopting v0.1.

## 2. Binding a Pico to a capsule (no schema change)

A Pico declares which capsule capabilities it needs through the
**existing** `spec.capabilities: [string]` field on the Pico shape.
`definitions/pico.yaml` (Memo 17) already requires `spec.capabilities`
on every OE-shaped Pico, with items of type `string` and no further
constraint — see lines 54–57 of `definitions/pico.yaml`:

```
capabilities:
  type: array
  items:
    type: string
```

This memo proposes that each item in that array name a capsule by
`metadata.name`, optionally pinned with an `@<version>` suffix:

- `greeting` — any version of the `greeting` capsule.
- `greeting@0.1.0` — the `0.1.0` version specifically.

No required field of `definitions/pico.yaml` changes. No new required
field is added. `spec.additionalProperties: true` on the Pico `spec`
block is already set, so a future, upstream-owned `spec.composition`
block for richer binding (if the owning repository wants one) can be
introduced without a Definition change. The Academy will not add such
a block locally.

## 3. Worked example (illustrative; not valid until adopted upstream)

The two blocks below together re-express the current `labs/hello-pico`
lab (`id: rule.hello`, `kind: greeting`, `value: "Hello, Pico!"`) as a
single `greeting` capsule and a minimal Pico composing it. They have
no on-disk consumer in this repository and no file under
`definitions/` matches them.

Capsule definition — **illustrative; not valid until adopted
upstream** by `open-engineering-capsules/source`:

```yaml
apiVersion: open-engineering.io/v1alpha1
kind: Capsule
metadata:
  name: greeting
  version: 0.1.0
spec:
  capability: greeting
  inputs:
    value:
      type: string
      required: true
  outputs:
    greeting:
      type: string
  dependencies: []
```

Minimal Pico composing it — **illustrative; not valid until adopted
upstream**:

```yaml
apiVersion: open-engineering.io/v1alpha1
kind: Pico
metadata:
  name: hello-pico
spec:
  type: greeter
  capabilities:
    - greeting@0.1.0
  implementation: {}
  state: {}
  events: {}
```

The Pico block uses only required fields of `definitions/pico.yaml`
(`type`, `capabilities`, `implementation`, `state`, `events`), binds
one capsule by name and version through `spec.capabilities`, and
needs no local schema change. Equivalence with today's lab is at the
capability level only: today's `bin/pico compose` consumes the flat
Rule shape (`id`/`kind`/`value`), not either block above (see §4).

## 4. Open questions for the owning repository

The owning repository (`open-engineering-capsules/source`) must decide
each of the following before Memo 23 Modules 2–4 can be authored. The
Academy does not take any of these decisions.

1. **Composition validator ownership.** Which repository owns the
   validator that resolves a Pico's `spec.capabilities` entries
   against installed capsule definitions, checks required inputs,
   and reports missing or incompatible capsules? Candidates:
   `open-engineering-capsules/source` (ships the validator with the
   contract), `open-engineering-picos/source` (ships it with the Pico
   runtime), or a new tool. Memo 24 §2.4 records that today's
   `bin/pico compose` is a Rules→artifact code generator and is not a
   capability composer.
2. **Version compatibility rule.** How are `metadata.version` values
   compared when a Pico pins `capsule@<version>`? SemVer-strict,
   SemVer with ranges, exact-match-only, or deferred to v0.2? v0.1
   leaves this unspecified and relies on exact-match until the owning
   repository decides.
3. **Relationship to pico-conventions `capability.schema.json`.**
   Memo 24 §2.2 records that
   `open-engineering-conventions/pico-conventions/memo2.md` proposes
   (but does not commit) a `capability.schema.json`. The owning
   repository must decide whether the capsule contract's
   `spec.capability` field references names drawn from that schema
   (once committed), ships its own capability vocabulary, or treats
   capability names as opaque strings at v0.1.
4. **`bin/pico compose` scope.** Memo 24 §5 bullet 3 asks whether
   `bin/pico compose` stays a Rules→artifact generator and a *second*
   composer concept is introduced for capability composition, or
   whether `compose` is reinterpreted/extended to validate a Pico's
   capsule bindings. This decision belongs upstream per Memo 23 §3.2;
   the Academy will follow whichever is chosen.

## 5. What this proposal does not change

- No production interface is changed. `definitions/pico.yaml`,
  `bin/pico`, every file under `definitions/`, `courses/`, `labs/`,
  `.github/workflows/`, `_quarto.yml`, every per-course `_quarto.yml`,
  and every `metadata.yaml` remain exactly as they are on `HEAD`
  before this memo. The OELS CI gate's behaviour and `--fail-on-gap`
  strict mode are untouched.
- No file is added under `definitions/`. No new `kind` is introduced
  into the Academy's Definition registry. The Pico Definition from
  Memo 17 is the sole OE-shaped Definition owned here.
- The Academy will not ship a capsule format of its own. If
  `open-engineering-capsules/source` adopts v0.1, amends it, or
  publishes a different shape, the Academy will consume whatever is
  published; it will not fork or shadow the upstream contract per
  Memo 23 §3.2.

## Verification

- Every Open Engineering URL cited below is one of the four already
  verified HTTP 200 in Memo 24 § References on 2026-10-16. No private
  repository URL is included (per Memo 24 § References, private
  repositories are referenced as `gh api` endpoints in Memo 24 §1,
  not as clickable URLs here).
- Both fenced `yaml` blocks in §3 above parse with
  `python3 -c "import sys,yaml; yaml.safe_load(sys.stdin)"` → exit
  `0` (confirmed before this file was written).
- `git status --short` after writing this memo shows only
  `?? memo26.md`; no file under `definitions/`, `bin/`, `courses/`,
  `labs/`, `.github/`, or `work/` is modified or added.
- No `git push`, no fork, no PR, no issue is created anywhere by
  this memo.

## References

- Open Engineering Capsules organization: https://github.com/open-engineering-capsules
- Open Engineering Capsule organization: https://github.com/open-engineering-capsule
- Open Engineering Picos organization: https://github.com/open-engineering-picos
- Open Engineering Conventions organization: https://github.com/open-engineering-conventions
- Local files cited: `memo17.md`, `memo23.md`, `memo24.md`,
  `memo25.md`, `definitions/pico.yaml`, `bin/pico`,
  `labs/hello-pico/`.
