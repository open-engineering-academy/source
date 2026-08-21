# Course: Rust + Python — Building Native Python Modules with PyO3

Open Engineering Academy course implementing **Memo 6**.

## Principle

> Python describes what should happen.  
> Rust guarantees how fundamental things happen.

## Layout

```
courses/rust-python-pyo3/
├── _quarto.yml
├── index.qmd
├── metadata.yaml
├── glossary.qmd
├── modules/                 # 01–15 complete
├── labs/
├── .github/workflows/ci.yml
└── kernel/                  # Mini Open Engineering Kernel
    ├── src/
    ├── tests/python/
    ├── Cargo.toml
    └── pyproject.toml
```

## Modules (all complete)

| #  | Title |
|----|-------|
| 01 | Why Rust + Python? |
| 02 | The Rust Library |
| 03 | First PyO3 Binding |
| 04 | Maturin |
| 05 | Types Across the Boundary |
| 06 | Strong Domain Types |
| 07 | Errors |
| 08 | Structured Data |
| 09 | Boundary Design |
| 10 | Testing |
| 11 | Performance |
| 12 | Concurrency and the GIL |
| 13 | Async Interoperability |
| 14 | What Should Stay Python? |
| 15 | Capstone — Mini Kernel |

## Identifier convention

Aligned with Academy metadata:

- Compact form: `oe.course.pico`, `oe.lab.hello-pico`
- Full form also accepted: `open-engineering.pico.lamp`
- Three segments (`namespace.kind.name`); hierarchical lesson ids are documented as a future extension

## Quick verification

```bash
cd kernel
cargo test --lib
maturin develop   # or maturin build --release && pip install …
pytest tests/python -q
```

## Render the course site

Requires [Quarto](https://quarto.org):

```bash
cd courses/rust-python-pyo3
quarto render
# output → _site/
```

## CI

`.github/workflows/ci.yml` runs format, clippy, cargo test, maturin, pytest, and a clean wheel install.
