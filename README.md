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

