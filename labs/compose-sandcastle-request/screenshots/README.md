# Screenshot targets — Compose a Sandcastle request

Three terminal moments in
[`walkthrough.qmd`](../walkthrough.qmd) are the intended screenshot
targets for this lab. No image files ship yet; when captures land
they should live in this directory under the filenames below and
match the described regions and alt text.

## `01-compose-task.png`

- **Source step:** Walkthrough Step 2.
- **Region:** `compose.sh`'s stdout — the final two lines beginning
  `compose: wrote ...engineering-task.yaml` and `compose: the
  composition wrote no code and touched no repository.`, followed by
  the `cat` of the emitted `engineering-task.yaml`.
- **Alt text:** "Terminal showing compose.sh emitting an
  EngineeringTask from the XR and the emitted YAML."

## `02-agent-run.png`

- **Source step:** Walkthrough Step 3.
- **Region:** the `[agent] ...` lines from `sandcastle-run.sh`,
  including `greeting requested by task = Hallo, Pico!` and the
  final `sandcastle-run: done. sandbox destroyed; durable artifacts
  under ...` line.
- **Alt text:** "Terminal showing the task-driven agent's inner
  loop and the driver disposing of the sandbox."

## `03-verify-ok.png`

- **Source step:** Walkthrough Step 5.
- **Region:** the final `verify: OK — branch=... greeting=... task=...
  sandbox=disposed` line from `verify.sh`.
- **Alt text:** "Terminal showing `verify.sh` printing `verify: OK`
  for the compose-sandcastle-request lab."
