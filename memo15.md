# Memo 15: Portable OELS distribution and editor path

## Status

Implemented as documentation plus a resolver, capability check, and one
LSP fixture under the ignored `work/` tree. No absolute sibling path is
committed, no dependency is added to the academy, no CI gate is
introduced, and no course content or Quarto publishing pipeline is
altered.

## Purpose

Follow-up to `memo13.md` (inventory) and `memo14.md` (metadata migration).
Give every academy author a reproducible way to obtain and launch the
pinned Open Engineering Language Server (OELS) locally, from any
LSP-capable editor, without hardcoding a specific developer's checkout
path anywhere in the repository.

## Pinned OELS source and build invocation

- **Canonical source:** <https://github.com/open-engineering-language-server/source/>.
- **Pinned commit (memo15 baseline):** `6016c77007d3f84f4aaac25b30952599ba0f05af`
  (short: `6016c77`, message: `Add pnpm lockfile`). All statements about
  supported behavior below refer to this SHA.
- **Runtime prerequisite:** Node.js ≥ 20 (the OELS package declares
  `engines.node >= 20`). Use of the system Node or a per-developer
  version manager is a developer decision; the academy does not ship a
  Node install.
- **Reproducible build (per developer, one time per pin):**
  ```
  git clone https://github.com/open-engineering-language-server/source.git oels
  cd oels
  git checkout 6016c77007d3f84f4aaac25b30952599ba0f05af
  corepack enable && corepack prepare pnpm@12.4.1 --activate
  pnpm install --frozen-lockfile
  pnpm --filter @open-engineering/lsp exec tsc -b
  ```
  Result: an executable bin shim at
  `packages/lsp/bin/open-engineering-lsp.mjs` and a built
  `packages/lsp/dist/standalone.js`. Neither path is committed to the
  academy repository.
- **Rebuild trigger:** whenever this memo advances the pinned SHA, or
  the OELS `package.json` version changes upstream, developers rerun the
  build. There is no cached artifact in this repository.

## Portable binary resolution

The pinned OELS server always launches over stdio. The resolver enforces
one binary-lookup contract that VS Code, Neovim, Zed, Helix, agent
clients, and the availability check all share:

1. If `OELS_SERVER_PATH` is set:
   - if it points at an executable file, use it verbatim
     (typical: `.../packages/lsp/bin/open-engineering-lsp.mjs`);
   - else if it ends in `.mjs`/`.js` and is readable, launch it as
     `node <path>` (Node ≥ 20 must be on `PATH`);
   - else fail with a clear diagnostic.
2. Otherwise, if `open-engineering-lsp` is on `PATH` (published npm
   binary, homebrew formula, or a per-developer shim), use it.
3. Otherwise, fail with an actionable message.

`OELS_SERVER_PATH` is set in each developer's shell profile or launcher
environment. It is **never** committed to `_quarto.yml`, per-course
config, editor settings, CI, or any tracked memo other than as
placeholder documentation.

Reference resolver: [`work/oels/resolve-oels.sh`](work/oels/resolve-oels.sh)
(ignored; every editor client and script defers to it so all consumers
agree on resolution semantics). Exit codes: `0` prints the resolved
command, `2` prints one diagnostic to stderr.

## Editor-neutral LSP semantics

OELS speaks LSP over stdio. The academy contract for every client:

- Launch: `<resolved command> --stdio`.
- Workspace root: the LSP client sends `workspaceFolders` (or
  `rootUri`) at `initialize`. Opening the academy repository folder or
  a single course folder is sufficient; no per-course override is
  needed. OELS derives its workspace root from that folder and looks
  for `<workspace-root>/definitions/` (top-level only, non-recursive).
- Language IDs to associate with the client: `open-engineering`,
  `yaml`, `json`. OELS decides whether to treat a document as an OE
  resource from its content (per the five rules in
  `templates/README.qmd § What OELS treats as an OE resource`), not
  from the languageId.
- Server capabilities exposed by the pinned build: `textDocumentSync`
  (incremental), `completionProvider`, `hoverProvider`,
  `definitionProvider`, `referencesProvider`, `documentSymbolProvider`,
  `workspaceSymbolProvider`. Server info: `open-engineering-lsp`
  version `0.0.0`.
- Diagnostics: OELS publishes `textDocument/publishDiagnostics` after
  `initialize` and on every `didOpen`/`didChange`, per the memo14
  diagnostic contract. Clients must handle empty-diagnostic re-publishes
  to clear previously-reported problems.

### Optional VS Code client (example only, not committed)

Any developer using VS Code MAY drop this into their **user**
`settings.json` (never a committed `.vscode/settings.json`):

```jsonc
{
  // Preferred: leave empty when a bundled or on-PATH binary is
  // available. Fall back to a per-developer env var:
  //   "openEngineering.server.path": "${env:OELS_SERVER_PATH}"
  "openEngineering.server.path": "",
  "openEngineering.trace.server": "off"
}
```

The VS Code client shipped from the OELS repository (`packages/vscode`)
is an optional convenience client. Zed, Neovim, Helix, and future
agent/CLI consumers reach the same semantics through the same stdio
entrypoint; the academy places no VS Code-specific requirement on
authors.

## Safe capability/availability check

Reference check: [`work/oels/check-oels.py`](work/oels/check-oels.py)
(ignored; stdlib-only Python). It:

1. Resolves the command via `resolve-oels.sh`.
2. Spawns the OELS server over stdio.
3. Runs the LSP `initialize` handshake against a configurable workspace
   root and reports server name/version and advertised capabilities.
4. Sends `textDocument/didOpen` for one deterministic fixture
   (`work/oels-contract/fixtures/lsp/malformed-name.yaml`, root
   `apiVersion: open-engineering.io/v1alpha1`, `kind: Course`,
   `metadata.name: BadName.WithDots`) and asserts that at least one
   `textDocument/publishDiagnostics` for that URI is received.
5. Requests `shutdown`, sends `exit`, and terminates.

Invocation:
```
export OELS_SERVER_PATH=/path/to/oels/packages/lsp/bin/open-engineering-lsp.mjs
python3 work/oels/check-oels.py --workspace courses/pico
```

Exit codes: `0` on success, `2` on resolution failure, `3` on missing
`initialize` response, `4` on missing `publishDiagnostics`, `5` on
zero diagnostics for the fixture. All error output is a single line to
stderr; the check never opens a socket, contacts the network, or reads
credentials.

## Supported vs not supported (as of pinned SHA `6016c77`)

Supported today:
- Standalone stdio LSP server via `--stdio`.
- `initialize` with a workspace root plus `initialized`, `didOpen`,
  `didChange`, `didClose`, `shutdown`, `exit` lifecycle.
- Diagnostics for OE-shaped resources per the memo14 code set
  (`MalformedResource`, `MalformedIdentifier`, `UnknownDefinition`,
  `MissingRequiredProperty`, `UnknownProperty`, `IncorrectType`,
  `InvalidEnumValue`).
- Completion, hover, definition, references, document symbols, and
  workspace symbols (per exposed server capabilities).
- Workspace resource discovery of `.yaml`/`.yml`/`.json` under the
  supplied root, with `node_modules`, `.git`, `dist`, `build`, and
  dotfile directories pruned.
- Definition discovery at `<workspace-root>/definitions/` (top-level
  only, non-recursive).

Not supported today (deliberate exclusions or upstream gaps):
- Any transport other than stdio. `--node-ipc`, `--socket`, `--pipe`
  cause the standalone entrypoint to exit with code `2`.
- No published npm binary or homebrew formula exists yet; PATH-based
  resolution requires a developer-managed shim until upstream ships a
  release. The resolver's PATH branch is future-proofing, not the
  current default.
- No published semantic version. The server advertises `serverInfo`
  version `0.0.0`; the academy pin is the git SHA above.
- No cross-document reference resolution against real academy `id`
  graphs (memo14 documents this same gap for the metadata adapter).
- No repository-wide `<repo-root>/definitions/` directory has been
  added to the academy yet; `UnknownDefinition` on OE-shaped files is
  therefore the expected behavior against the academy root.
- No `.ttl`, `.md`, `.qmd`, `.html`, or Quarto-generated output is
  scanned. OELS diagnostics never affect `quarto render`.
- No credentials, network calls, hosted service, or Kubernetes-mediated
  runtime are involved in basic authoring.

## Verification commands

Run from the academy repository root:

```
# Resolver: prints one command, or exits 2 with a clear message.
work/oels/resolve-oels.sh

# End-to-end handshake plus one diagnostic against a course workspace.
export OELS_SERVER_PATH=/path/to/oels/packages/lsp/bin/open-engineering-lsp.mjs
python3 work/oels/check-oels.py --workspace courses/pico --timeout 45
# Expected final line: "check-oels: OK"

# No committed sibling absolute path anywhere in tracked files.
grep -RIn "geographical-tuna" . \
  ':!work' ':!node_modules' ':!.git' ':!_site' ':!_freeze' ':!.quarto'
```

Recorded evidence for the pinned SHA on the author's machine:
- Resolver returned `.../packages/lsp/bin/open-engineering-lsp.mjs` when
  `OELS_SERVER_PATH` was set to that shim; exited `2` with the expected
  diagnostic in the unset and bogus-path cases; produced `node <path>`
  when the shim was made non-executable and re-supplied as an `.mjs`.
- `python3 work/oels/check-oels.py --workspace courses/pico` completed
  with `check-oels: OK`, reporting `serverInfo=open-engineering-lsp
  version=0.0.0` and capabilities `[completionProvider,
  definitionProvider, documentSymbolProvider, hoverProvider,
  referencesProvider, textDocumentSync, workspaceSymbolProvider]`, and
  received exactly one diagnostic for the fixture URI.
- `git status --short` was clean before and after all runs; the
  `work/` tree and the fixture are covered by the existing `/work/`
  ignore rule (same rule already used by the memo14 adapter).
- Full-repository-root scans against the pinned build did not complete
  within a 30 s handshake timeout on the author's machine; running the
  check against a single course workspace (as documented above) is the
  recommended verification path today. The full-root scan cost is a
  pinned-build characteristic to revisit when OELS gains configurable
  resource-walk pruning upstream.

## What is deliberately not changed

- No `metadata.yaml`, `.qmd`, `_quarto.yml`, GitHub Actions workflow,
  Quarto configuration, dependency manifest, or generated output is
  touched by this memo.
- The sibling OELS workspace path used by the current developer for
  local testing is intentionally absent from every tracked file. It
  appears only inside the developer's own environment.
- No new npm/pnpm/Homebrew dependency is added to the academy; the
  reproducible build clones and builds OELS outside this repository.
- No CI gate is introduced. Gating publication on OELS diagnostics is
  the responsibility of the separate `Make OELS validation part of
  course and academy CI` task.
- The Quarto publishing pipeline, learner-facing behavior, and existing
  course/lab verifiers are unchanged.
