# Hand resolution — `oe.greeting`

**Shape:** mirrors upstream
`fixtures/scenarios/resolve-greeting.yaml` at pinned commit
`bf071c2c1b57`. **Method:** apply the memo2 rules by hand (no
tool-backed resolver exists yet — memo2 §5 follow-up (b)).

## Scenario (from this lab)

```yaml
description: >
  Pico needs oe.greeting pinned at 0.1.0 (caret). One capsule provides
  oe.greeting at exactly 0.1.0. Resolution succeeds.
pico:
  spec:
    capabilities:
      - oe.greeting@0.1.0
installed:
  - { metadata: { name: greeting, version: "0.1.0" }, spec: { capability: oe.greeting } }
expected:
  outcome: resolved
  resolution:
    - requirement: oe.greeting@0.1.0
      constraint: caret
      provider: { name: greeting, version: "0.1.0" }
```

## Resolution steps (what a conforming resolver would do)

1. **Parse the requirement.** `oe.greeting@0.1.0` splits into the
   capability identifier `oe.greeting` and the version suffix
   `@0.1.0`. Per memo2 §2 D2 the leading `@` without `=` is a
   **caret-style** compatibility constraint.
2. **Grammar check (memo2 §3 D3).** `oe.greeting` matches
   `^[a-z][a-z0-9]*(-[a-z0-9]+)*(\.[a-z][a-z0-9]*(-[a-z0-9]+)*)+$`
   — two segments, both start with a lower-case letter, no illegal
   character. The capsule's `spec.capability` `oe.greeting` matches
   the same pattern. ✔
3. **Enumerate candidate providers.** Among the installed capsules,
   those whose `spec.capability` equals `oe.greeting` are candidates.
   One capsule matches: `greeting` at version `0.1.0`.
4. **Apply the version constraint (memo2 §2 D2 caret, `0.x` rule).**
   For `0.x` versions caret requires the **same minor** and **patch ≥
   Z**. Requirement `0.1.0` → candidate `0.1.0`: same minor (`1`),
   patch `0 ≥ 0`. ✔
5. **Check uniqueness (memo2 §3 D3, §2 amendment).** Exactly one
   candidate survives; >1 would be an explicit `multiple-matching-
   providers` error at v0.1. ✔
6. **Emit the resolution.**

```yaml
outcome: resolved
resolution:
  - requirement: oe.greeting@0.1.0
    constraint: caret
    provider: { name: greeting, version: "0.1.0" }
```

## Observations

- The resolution outcome above is byte-equivalent to the upstream
  `fixtures/scenarios/resolve-greeting.yaml` `expected` block at
  `bf071c2c1b57` (memo2 §5 follow-up (a) worked fixture).
- No local resolver is shipped by this lab (task DoD). The scenario
  is a hand walkthrough of the normative rules from memo2 §§2–3; the
  reference command-line resolver belongs to
  `open-engineering-capsule/source` (memo2 §1 D1 / §4 D4) under
  memo2 §5 follow-up (b), which has not been published yet.
- Had the requirement been bare (`oe.greeting`) the constraint column
  would read `any` and the same provider would still be the single
  match. Had it been exact (`oe.greeting@=0.1.0`) the comparison in
  step 4 would require `version == 0.1.0` strictly, which the single
  candidate also satisfies.

## References

- Upstream `memo1.md` §1, §3 (worked example) at `bf071c2c1b57`.
- Upstream `memo2.md` §1 (D1 ownership), §2 (D2 SemVer / caret /
  `0.x`), §3 (D3 grammar and §2 amendment), §4 (D4 scope), §5
  follow-ups (a) worked fixture and (b) reference validator.
- Upstream `fixtures/scenarios/resolve-greeting.yaml` at
  `bf071c2c1b57`.
