# Memo 27: How the Academy OELS registry consumes an upstream-owned Definition

## Status

Proposed. Design memo only — no change to
`scripts/oels_ci_validate.py`, no file under `definitions/`,
`.github/workflows/`, `work/`, `courses/`, `labs/`, `exercises/`, or
`templates/` is modified by this memo. Implementation lands under a
separate task (`Implement memo27: external Definition manifest in the
OELS gate`). A PR is opened against `main` for memo27; it is not
merged.

## Purpose

Close the OELS strict-mode gap recorded in Phase 3 for
`labs/greeting-capsule/solution/capsule.yaml` without the Academy
committing a copy of the upstream capsule contract.

Today the file resolves as a documented gap under memo13 gap #4
semantics: `scripts/oels_ci_validate.py` reports
`UnknownDefinition` for `apiVersion=open-engineering.io/v1alpha1
kind=Capsule`, because `_load_registry` reads only
`definitions/*.yaml` (`scripts/oels_ci_validate.py:120-132`) and no
such file targets `Capsule`. Phase 3 explicitly accepted this gap
rather than vendoring the upstream schema (memo23 §3.2, memo26 §5,
spec note "Decision (Coordinator, 2026-10-22)"). This memo decides
how `--fail-on-gap` can return to zero gaps for `kind: Capsule`
without the Academy owning the contract.

The upstream contract repository `open-engineering-capsules/source`
at pinned SHA `bf071c2c1b57` publishes `capsule.schema.json` (a
plain JSON Schema Draft 2020-12 document, verified via
`gh api repos/open-engineering-capsules/source/contents/capsule.schema.json?ref=bf071c2c1b57`
on 2026-10-23) and 26 fixtures under `fixtures/`, but **no** OE
`kind: Definition` wrapper. Both `open-engineering-capsules/source`
and `open-engineering-capsule/source` are private; the default
`GITHUB_TOKEN` cannot read either (GitHub Actions docs: "the
`GITHUB_TOKEN` can only access resources within the workflow's
repository"; see References).

## Options compared

### Option A — External-definitions manifest, fetched at CI time

Add one tracked file, `definitions/external.yaml`. It lists target
`apiVersion`/`kind`, repo, pinned SHA, and the path to the schema
inside that repo. `scripts/oels_ci_validate.py` reads it, fetches
each listed schema at run time into `build/definitions/` (pruned by
`PRUNED_DIR_NAMES` — see `scripts/oels_ci_validate.py:85-88`), and
registers an in-memory `Definition` using the existing
`oels_metadata_validator.load_definition` contract
(`work/oels_metadata_validator.py:61-94`). Nothing under
`build/definitions/` is committed. If the fetch fails (missing
secret, network error, HTTP 404), the file is treated as today:
`UnknownDefinition` is still emitted but is **not** promoted to a
failure, and the memo27 fallback message is appended so operators
can tell "no secret" apart from "upstream contract broken".

- Decides nothing upstream owns.
- No `definitions/capsule.yaml`, no copy of the schema, no copy of
  any fixture under the Academy source tree.
- `gap=0` under `--fail-on-gap` in CI as long as the secret is
  present; today's accepted gap remains the honest fallback when it
  is not (fork PRs do not see repository secrets — GitHub Actions
  secrets docs, see References).

### Option B — Ask the contract repo to publish an OE `kind: Definition`

Upstream publishes `definitions/capsule.yaml`
(`kind: Definition`, `spec.target.{apiVersion,kind}`,
`spec.schema`) that wraps `capsule.schema.json`. The Academy still
fetches it at run time through the same manifest + registration
path as Option A — the only change is that the Academy no longer
performs the wrap step, upstream does. Both repos stay private, so
the token story is identical to Option A.

- Correct in principle: the owner of the contract owns the
  Definition.
- Requires an upstream decision and release before memo27's
  implementation can land here. Not necessary for the Academy to
  achieve `gap=0`; a wrap-in-the-validator step is sufficient and
  reversible once upstream publishes.
- Can be filed as a follow-up without blocking memo27.

### Option C — Keep the accepted gap until the repos are public

Status quo. The Academy keeps running the default-mode gate at
`gap=1` for `labs/greeting-capsule/solution/capsule.yaml` and does
not run `--fail-on-gap` in CI.

- Zero code change, zero secret surface.
- Blocks the "zero gaps" criterion in Phase 3 and in the Phase 4
  acceptance criteria for Track 2 of the spec.
- Not actionable: no upstream decision will make the repositories
  public on a known timeline.

## Recommendation

Adopt **Option A**. The user has confirmed that a cross-repo read
secret for Academy CI will be provided; the only concrete blocker
to Option A — a missing secret — is addressed. Option A keeps the
Academy on the memo23 §3.2 / memo26 §5 rule (no capsule format of
its own, no fork or shadow of the upstream contract), produces
`gap=0` under `--fail-on-gap` whenever the secret is present, and
degrades to today's documented behaviour when it is not.

Option B is filed as a follow-up: ask
`open-engineering-capsules/source` to publish
`definitions/capsule.yaml` once the reference validator (memo2
follow-up (b), spec Track 1) is in place. When that lands, the
Academy fetch simply picks up the Definition instead of wrapping
the raw schema; the manifest schema and the fetch/fallback
machinery do not change.

Option C is rejected: it closes the Phase 4 Track 2 acceptance
criterion by denying the problem.

## External-definitions manifest schema

Exactly one new tracked file, `definitions/external.yaml`. Shape
(illustrative; adopted by this memo but not yet on disk):

```yaml
# definitions/external.yaml — memo27 (Proposed)
# One entry per OE target (apiVersion+kind) for which the Academy
# consumes a schema it does not own. The validator fetches each
# listed schema at run time into build/definitions/ and wraps it as
# an in-memory Definition (never committed, never a copy under
# definitions/).
apiVersion: open-engineering.io/v1alpha1
kind: ExternalDefinitions
metadata:
  name: external
  description: >
    Externally-owned OE Definitions consumed by the Academy OELS
    registry at CI time. Documented by memo27.
spec:
  entries:
    - target:
        apiVersion: open-engineering.io/v1alpha1
        kind: Capsule
      repo: open-engineering-capsules/source
      ref: bf071c2c1b57                 # pinned 40-char or short SHA
      schema: capsule.schema.json        # path inside the repo
      definition:                        # optional; see "Wrap vs adopt"
        name: capsule-external           # metadata.name used in the wrap
```

Field rules (binding for the implementation task):

- `spec.entries[].target.{apiVersion,kind}` — the OE target the
  entry claims; `apiVersion` MUST begin with `open-engineering.io/`
  (same prefix rule as `load_definition`,
  `work/oels_metadata_validator.py:65-68`).
- `spec.entries[].repo` — `<owner>/<name>` on github.com. No URL,
  no `ref=` suffix — the ref is a separate field.
- `spec.entries[].ref` — a git ref. In practice a commit SHA (short
  or full); the manifest MUST pin, not float.
- `spec.entries[].schema` — path inside the pinned repo. The file
  SHOULD be a JSON Schema (either `.json` or a YAML-encoded JSON
  Schema). When it is already an OE `kind: Definition` (Option B),
  the fetched document is passed straight to `load_definition`
  without a wrap step (see "Wrap vs adopt" below).
- `spec.entries[].definition` — optional. When present, overrides
  the synthesised `metadata.name`. Default:
  `<target.kind lower-cased>-external`.

The entry schema is deliberately a single `kind: ExternalDefinitions`
document, not a free-form list, so OELS classifies the file as a
non-OE Academy artefact today (unknown `kind`, no Capsule-shaped
instance) and classifies it as an OE Definition instance only after
Option B lands upstream. Nothing in the memo asks OELS to validate
the manifest itself; the validator parses it as plain YAML.

## Wrap vs adopt (what the validator does with a fetched file)

- **Adopt** path: if the fetched document has
  `kind: Definition` and `spec.target.{apiVersion,kind}` matching
  `entries[].target`, it is handed to `load_definition` as-is.
  This is the Option B steady state.
- **Wrap** path (Option A today): the validator loads the fetched
  JSON Schema into memory and synthesises an in-memory mapping:

  ```yaml
  apiVersion: open-engineering.io/v1alpha1
  kind: Definition
  metadata:
    name: <definition.name or <target.kind lower>-external>
  spec:
    target:
      apiVersion: <target.apiVersion>
      kind: <target.kind>
    schema: <fetched schema as a dict>
  ```

  That mapping is passed to `load_definition`, which populates
  `Definition.schema` and the registry (`by_target`) exactly as it
  does for an on-disk Definition today
  (`work/oels_metadata_validator.py:86-94`).

**Known limitation of the wrap path.** `walk_object`
(`work/oels_metadata_validator_walk.py:42-120`) is structural: it
honours `type`, `required`, `enum`, and the boolean
`additionalProperties`, and silently ignores `$ref`, `$defs`,
`const`, `pattern`, `minLength`, `oneOf`, `allOf`, and
schema-object `additionalProperties`. The upstream
`capsule.schema.json` uses `const`, `$defs`/`$ref` (for `semver`,
`capabilityIdentifier`, `capabilityRequirement`), and object-shaped
`additionalProperties` on `spec.inputs`/`spec.outputs`. The wrap
path therefore gives a **structural** check (apiVersion/kind
present, required fields present, correct top-level types) and is
a strict subset of the upstream reference validator's semantics.
This matches the Phase 3 posture (teach the normative validator in
the lab via `jsonschema`; the OELS gate's job is classification
and shape, not re-implementing the normative validator). Any
tightening of `walk_object` to understand `const`/`$ref`/pattern
is tracked separately from memo27.

## Validator behaviour, totals, and gap reporting

What changes in `scripts/oels_ci_validate.py` under Option A, with
the secret present:

- `_load_registry` reads `definitions/*.yaml` as today and
  additionally reads `definitions/external.yaml`. For each
  `spec.entries[]` it fetches the pinned file into
  `build/definitions/<repo>/<ref>/<schema basename>` and registers
  the wrapped Definition. The `definitions/external.yaml` file
  itself is skipped by the existing `definitions/*.yaml` scan
  because its `kind` is not `Definition` (fails `load_definition`
  today); the implementation MUST either filter it out by name or
  rely on `_load_registry` reading the manifest before the glob.
- `_handle_native_oe` behaviour is unchanged
  (`scripts/oels_ci_validate.py:254-269`). For
  `labs/greeting-capsule/solution/capsule.yaml` the registry now
  returns a hit on `(open-engineering.io/v1alpha1, Capsule)`, so
  the file moves from `unsupported_or_gap` to `native_oe` and runs
  through `walk_object` — producing zero diagnostics for the
  current lab fixture (structural check only; see "Wrap vs adopt"
  above).

Reported totals move from today's baseline (adapter=26, native-oe=1,
non-oe=60, excluded=213, gap=1) to **adapter=26, native-oe=2,
non-oe=60, excluded=213 (+N for `build/definitions/**` which is
pruned), gap=0**. `scripts/oels_ci_validate.py --fail-on-gap`
returns exit 0.

With the secret absent (fork PRs, learners without org access, air-
gapped checkouts), the behaviour degrades gracefully:

- The fetch returns HTTP 404 or 401. The validator records a single
  structured warning per entry (e.g.
  `external-definitions: capsule fetch skipped: no cross-repo
  credentials (set CAPSULES_CONTRACT_READ_TOKEN or clone upstream
  locally)`), does **not** register a Definition for that target,
  and does not fail.
- The affected files still classify as today — one
  `UnknownDefinition` gap per Capsule file under the existing
  memo13 gap #4 message. The gap list gains a one-line pointer to
  the manifest so operators know why: `gap: <path>:
  [UnknownDefinition] no Definition for apiVersion=... kind=...
  (external manifest entry present but fetch skipped; see
  definitions/external.yaml and memo27)`.
- `--fail-on-gap` still fails if invoked in that environment,
  which is correct: the strict mode is only meaningful when the
  cross-repo contract is actually available.

Default-mode CI (`python3 scripts/oels_ci_validate.py` without
`--fail-on-gap`) stays green in every environment, matching
Phase 3's accepted-gap posture.

## Secret and least-privilege token scope

Proposed secret name: **`CAPSULES_CONTRACT_READ_TOKEN`**. This
matches the naming of the existing `PAGES_TOKEN` /
`GH_PAGES_CLONE_TOKEN` secrets in
`.github/workflows/build-and-publish.yml` and names the single
upstream repository it reads.

Proposed token type: a **fine-grained personal access token**
scoped to exactly one repository
(`open-engineering-capsules/source`) with the single permission
**Repository → Contents: Read**. That is the minimum GitHub
requires for the `GET /repos/{owner}/{repo}/contents/{path}`
endpoint used by both `curl` (via `raw.githubusercontent.com` with
an `Authorization: Bearer` header, when the repo is private) and
`gh api .../contents/{path}?ref=<sha>` (used today in
`labs/greeting-capsule/solution/fetch-upstream.sh`).

Cited GitHub documentation (verified 2026-10-23):

- "Fine-grained personal access tokens … only have access to the
  repositories or organizations that they explicitly are granted
  access to." — GitHub blog, *Introducing fine-grained personal
  access tokens for GitHub*
  (https://github.blog/security/application-security/introducing-fine-grained-personal-access-tokens-for-github/).
- `GET /repos/{owner}/{repo}/contents/{path}` requires
  `Repository contents: read` under "Permissions required for
  fine-grained personal access tokens" — GitHub REST authentication
  docs
  (https://docs.github.com/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens).
- "The `GITHUB_TOKEN` can only access resources within the
  workflow's repository. If you need to access additional
  resources, such as resources in an organization or in another
  repository, you can use a GitHub App." — *Making authenticated
  API requests with a GitHub App in a GitHub Actions workflow*
  (https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/making-authenticated-api-requests-with-a-github-app-in-a-github-actions-workflow).
- "With the exception of `GITHUB_TOKEN`, secrets are not passed to
  the runner when a workflow is triggered from a forked
  repository." — *Using secrets in GitHub Actions*
  (https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets).
  This is why the fallback is required by memo27, not optional.
- "Compromised runners" lists cross-repository options in
  descending order of preference: `GITHUB_TOKEN` → deploy keys →
  GitHub App tokens → fine-grained PATs for a dedicated
  machine/organisation account — *Compromised runners*
  (https://docs.github.com/en/actions/concepts/security/compromised-runners).

A GitHub App installation with Contents: Read on the single
upstream repository is a strictly better long-term fit (no human
owner, no expiry tied to one person); memo27 recommends the
fine-grained PAT only because the Academy already consumes
`GITHUB_TOKEN`-style secrets in `build-and-publish.yml` and does
not yet have an organisation GitHub App. The implementation task
MAY substitute a GitHub App installation token at the same scope
without any manifest-schema change — the secret name becomes the
only CI-visible change.

### Workflow wiring

`.github/workflows/build-and-publish.yml`'s existing *Run OELS
validation across all nine course roots* step gains one `env` entry
(`CAPSULES_CONTRACT_READ_TOKEN: ${{ secrets.CAPSULES_CONTRACT_READ_TOKEN }}`)
and no other change. The validator reads the token from the
environment and falls back to unauthenticated requests (which
return 404 on private repos) when it is empty, exactly as the
Secrets-not-passed-from-forks fallback above requires. Nothing in
the publish, Quarto, or git-pages steps is touched.

## Pin-bump procedure

Bumping the pinned upstream SHA is a one-line edit to
`spec.entries[].ref` in `definitions/external.yaml`. The reviewer
MUST:

1. Confirm the new ref exists upstream via
   `gh api repos/open-engineering-capsules/source/commits/<ref>`.
2. Confirm the schema path still resolves at that ref via
   `gh api "repos/.../contents/<schema path>?ref=<new ref>"`.
3. Run `python3 scripts/oels_ci_validate.py --fail-on-gap` once
   with the token present and once with it unset, to verify both
   the strict and fallback paths.
4. Record the before/after totals in the PR description.

No fixture is committed; no `build/` artefact is committed. The
same procedure is used when memo27's follow-up Option B lands
upstream — the only field that typically needs to change is `ref`
(and, once upstream publishes `definitions/capsule.yaml`, the
`schema:` field moves to that path).

## Offline / fallback behaviour

Four degraded environments must stay green in default mode and
produce predictable output:

| Environment | Fetch result | Registry | Gate (default) | Gate (`--fail-on-gap`) |
|---|---|---|---|---|
| CI with secret | 200 OK | wrap registered | OK, `gap=0` | OK, `gap=0` |
| CI without secret (fork PR) | 401/404 | not registered, warning logged | OK, Capsule file in gap list | FAIL on gap (expected) |
| Learner laptop, no token | 401/404 | not registered, warning logged | OK, gap list | FAIL on gap (expected) |
| Fully offline (no network) | network error | not registered, warning logged | OK, gap list | FAIL on gap (expected) |

Operators who want a reproducible strict run without the token can
clone `open-engineering-capsules/source` locally and set
`OELS_EXTERNAL_CACHE=<path>` (optional implementation hook) to
point the validator at an already-fetched tree under
`<cache>/<repo>/<ref>/<schema>`. This is a convenience and is not
required for memo27's acceptance.

## What no option vendors

No option — A, B, or C — commits any upstream file inside this
repository. Specifically, no option:

- adds `definitions/capsule.yaml`, `definitions/capsule.schema.json`,
  or any file whose byte content comes from
  `open-engineering-capsules/source`;
- adds any file under `fixtures/`, `work/`, `courses/`, `labs/`
  (outside the already-untracked `labs/greeting-capsule/build/`
  which `_walk_resources` prunes), or `templates/` that mirrors an
  upstream artefact;
- introduces a second capsule format in the Academy (memo23 §3.2);
- forks or shadows the upstream contract (memo26 §5).

The only file added by the implementation task is one tracked
manifest (`definitions/external.yaml`) that is itself empty of
upstream content — it names repos, refs, and paths.

## Verification

- `gh api repos/open-engineering-capsules/source/contents?ref=bf071c2c1b57`
  → lists `README.md`, `capsule.schema.json`, `fixtures/`,
  `follow-ups/`, `memo1.md`, `memo2.md`, `metadata.yaml`. No
  `definitions/` directory and no `kind: Definition` document
  exist upstream; the memo's claim that Option B is a follow-up and
  not an available choice today is grounded (2026-10-23).
- `gh api "repos/open-engineering-capsules/source/contents/capsule.schema.json?ref=bf071c2c1b57" --jq .content | base64 -d`
  → returns the JSON Schema document whose shape is cited in
  "Known limitation of the wrap path" above (uses `const`,
  `$defs`/`$ref`, object-shaped `additionalProperties`).
- Code symbols referenced on `origin/main` (`e014663`): `_load_registry`
  (`scripts/oels_ci_validate.py:120-132`), `_handle_native_oe`
  (`scripts/oels_ci_validate.py:254-269`), `PRUNED_DIR_NAMES`
  (`scripts/oels_ci_validate.py:85-88`), `load_definition`
  (`work/oels_metadata_validator.py:61-94`), `Registry.register`
  (`work/oels_metadata_validator.py:50-58`), `walk_object`
  (`work/oels_metadata_validator_walk.py:42-120`). All verified by
  direct `view` on this branch.
- Existing files cited: `definitions/README.md`, `definitions/pico.yaml`,
  `.github/workflows/build-and-publish.yml`,
  `labs/greeting-capsule/solution/capsule.yaml`,
  `labs/greeting-capsule/solution/fetch-upstream.sh`,
  `labs/greeting-capsule/walkthrough.qmd`. All present on
  `origin/main`.
- GitHub documentation URLs listed under "Secret and least-
  privilege token scope" each returned HTTP 200 via a web search
  on 2026-10-23 (fine-grained PAT blog post, REST authentication
  permissions reference, GitHub Actions GitHub App cross-repo
  guide, secrets guide, compromised runners guide).
- `python3 -c 'import yaml,sys; yaml.safe_load(sys.stdin)' <<<"$(sed -n "/^```yaml$/,/^```$/p" memo27.md | sed "/^```/d")"`
  → OK (every fenced YAML block in this memo parses).
- No file outside `memo27.md` is modified by this task
  (`git status --short` shows only `?? memo27.md` before `git add`).

## References

- `memo13.md` §"Migration gaps" item 4; §"Semantic classification"
  bucket "Unsupported/gap".
- `memo14.md` — adapter contract and classification matrix.
- `memo15.md` — OELS behaviour the CI gate mirrors.
- `memo16.md` — final course-artifact migration; adapter/registry
  invariants.
- `memo17.md` — pattern for adding a new Definition (Pico) without
  editing on-disk resources.
- `memo23.md` §3.2 — "The exact schema belongs in the relevant
  definitions repository … Avoid inventing a second,
  course-specific capsule format."
- `memo24.md` §4 — single upstream prerequisite that blocked
  Modules 2–4.
- `memo26.md` §5 — "If `open-engineering-capsules/source` adopts
  v0.1 … the Academy will consume whatever is published; it will
  not fork or shadow the upstream contract per Memo 23 §3.2."
- Spec note, Phase 3 Decision (2026-10-22) — accepted-gap posture
  for the Capsule file and the "do not copy the schema" rule.
- `open-engineering-capsules/source` at `bf071c2c1b57`:
  https://github.com/open-engineering-capsules/source/commit/bf071c2c1b57
  (private; access via `gh api`).
- GitHub docs cited inline under "Secret and least-privilege
  token scope".
