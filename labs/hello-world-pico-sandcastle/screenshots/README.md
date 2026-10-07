# Screenshot targets — Hello World Pico Sandcastle

This file names the concrete terminal moments in the lab
[`walkthrough.qmd`](../walkthrough.qmd) that make good screenshots and
where their image files should land. It is contributor-facing: the
walkthrough itself renders without any of these images, but each named
target keeps the surface **screenshot-ready** so future contributors
know exactly what to capture.

Each entry names:

- **File** — the intended PNG filename under `screenshots/`.
- **Walkthrough step** — which step the screenshot illustrates.
- **What to capture** — the specific terminal region the shot should
  contain.
- **Suggested alt text** — accessible caption text for when the image
  is later embedded into the walkthrough.

## Targets

### 1. `01-driver-tail.png`

- Walkthrough step: Step 2 — Run the Sandcastle.
- What to capture: the last ~8 lines of `sandcastle-run.sh` output,
  showing the three `[agent]` lines (`validate: OK`, `compose: …
  Hello, Pico!`, `commit: adding rules/hello.yaml on branch
  sandcastle/hello-world-pico`) followed by the driver's final
  `sandcastle-run: done. sandbox destroyed; …` line.
- Suggested alt text: "Terminal output showing the Sandcastle
  agent's inner-loop lines followed by the driver's sandbox-teardown
  line."

### 2. `02-durable-branch.png`

- Walkthrough step: Step 3 — Confirm the durable branch.
- What to capture: the output of the two `git -C …` commands — the
  single-line commit log for `sandcastle/hello-world-pico` and the
  three-field `rules/hello.yaml` (`id`, `kind`, `value`) as printed
  by `git show`.
- Suggested alt text: "Terminal output showing one commit on the
  sandcastle/hello-world-pico branch and the three-field
  rules/hello.yaml file it added."

### 3. `03-verify-ok.png`

- Walkthrough step: Step 5 — Run the automatable verification.
- What to capture: the final line of `verify.sh` beginning with
  `verify: OK — branch=…` and the shell prompt returning to `$ ` on
  the next line to make the exit-0 status visible.
- Suggested alt text: "Terminal output showing verify.sh finishing
  with a verify: OK line for the sandcastle/hello-world-pico branch."

## Conventions

- Capture from a plain terminal at a readable font size; crop tightly
  to the relevant lines.
- Prefer light-background terminals so the image reads well in both
  Quarto light and dark themes.
- Keep filenames stable — the walkthrough refers to them by the names
  above.
