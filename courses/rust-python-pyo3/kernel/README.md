# Open Engineering Mini Kernel

Canonical domain logic for the **Rust + Python with PyO3** Academy course.

```
Python application
       │
      PyO3
       │
       ▼
┌───────────────────────────┐
│  Open Engineering Kernel  │
│  Identifier · Manifest    │
│  Rule · Validation        │
└───────────────────────────┘
            │
           Rust
```

## Quick start

```bash
# Development install (requires Rust + maturin)
cd kernel
maturin develop

# From Python
python -c "
from open_engineering_kernel import Identifier, validate_manifest, evaluate_rule

id = Identifier.parse('open-engineering.pico.lamp')
print(id.namespace, id.kind, id.name)

result = validate_manifest({'kind': 'pico', 'name': 'lamp'})
print(result)

rule = {
    'id': 'nod-when-ready',
    'when': {'op': 'eq', 'key': 'intent', 'value': 'nod'},
    'then': {'op': 'emit', 'event': 'nod'}
}
print(evaluate_rule(rule, {'intent': 'nod'}))
"
```

## Principle

> Python describes what should happen.  
> Rust guarantees how fundamental things happen.

One semantic core, multiple interfaces.
