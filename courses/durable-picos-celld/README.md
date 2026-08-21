# Course: Durable Picos with celld

Open Engineering Academy course implementing **Memo 7**.

## Principle

> Pico is the Open Engineering abstraction.  
> celld is one possible durable runtime implementation.

## Vertical slice (acceptance gate)

```
Hello, Pico!
    ↓
PicoRuntime SPI
    ↓
DurableRuntime (SQLite)
    ↓
restart → state recovery
    ↓
automated tests (18 passed)
```

## Quick start

```bash
cd runtime
make test
# or: PYTHONPATH=src python -m pytest tests -q
```

## Layout

```
courses/durable-picos-celld/
├── modules/           # 01–14
├── runtime/           # SPI + Native + Durable + tests
├── labs/
├── deploy/            # future K8s / Crossplane artifacts
└── .github/workflows/ci.yml
```

## Status

| Area | Status |
|------|--------|
| Hello Pico domain | Done |
| PicoRuntime SPI | Done |
| NativeRuntime | Done |
| DurableRuntime (SQLite) | Done |
| Unit + contract + persistence tests | 18 passed |
| Core modules (01–04, 07–08, 14) | Full content |
| Remaining modules | Stubs (Memo 7 roadmap) |
| Real celld binary integration | Documented path; SPI-ready |
