# Open Engineering Academy — source

Source repository for the **Open Engineering Academy**: a Quarto-based
publishing system for the academy's root website, self-contained course
websites, reusable labs and exercises, and shared templates and assets.

## Layout

```
.
├── _quarto.yml       # Root academy website (Quarto project)
├── index.qmd         # Academy homepage
├── about.qmd         # Academy mission and orientation
├── resources.qmd     # Shared templates, assets, conventions
├── curriculum/       # Curriculum and learning-path overview
├── courses/          # Self-contained course websites (pico is the reference)
├── labs/             # Reusable, cross-course labs
├── exercises/        # Smaller practice tasks
├── shared/           # Cross-course assets and includes
├── templates/        # Starter templates for new content
├── bin/              # Runnable reference CLIs (e.g. bin/pico)
└── .github/          # Build and publishing automation
```

Each course under `courses/` is its own Quarto website with its own
`_quarto.yml`. The root project only renders academy-level pages; each course
is built and published independently.

## Build

Render the root academy site:

```
quarto render
```

Render the reference course website:

```
quarto render courses/pico
```

Rendered output for the root site lands in `docs/`.

## Run the Pico reference path

The Hello Pico lab uses a small reference CLI shipped at `bin/pico`.
It is Python 3 (stdlib only) with subcommands `parse` and `compose`.
Put `bin/` on your `PATH` before running the lab commands so `pico`
resolves to the Academy CLI rather than the `/usr/bin/pico` text
editor:

```
export PATH="$PWD/bin:$PATH"
command -v pico   # should print .../bin/pico
```

See [`labs/hello-pico/`](labs/hello-pico/index.qmd) for the full
walkthrough.

