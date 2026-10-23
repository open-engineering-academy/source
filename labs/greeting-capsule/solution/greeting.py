"""Reference implementation of the `oe.greeting` capability.

This is a course-local teaching harness: a single Python function
behind the declared `spec.inputs`/`spec.outputs` of the companion
`capsule.yaml`. The implementation convention for capsules belongs
to `open-engineering-capsule/source`, which has published none yet
(memo24 §2.1 as updated by observation at the upstream commit
`bf071c2c1b57`).

The function raises a structured ``MissingRequiredInput`` error when
a declared-required input is absent, satisfying memo23 §5 rule 9
(graceful failure) at the capability boundary.
"""
from __future__ import annotations


class MissingRequiredInput(Exception):
    """Raised when a declared-required capsule input is not provided."""

    def __init__(self, name: str) -> None:
        super().__init__(f"missing required input: {name!r}")
        self.name = name


def greeting(inputs: dict) -> dict:
    """Compute the ``greeting`` output declared in ``capsule.yaml``.

    Honours the capsule contract literally:

    - reads one declared input (``value``, declared as required and of
      type ``string``);
    - returns one declared output (``greeting``, declared of type
      ``string``);
    - raises :class:`MissingRequiredInput` when ``value`` is missing.
    """
    if "value" not in inputs or inputs["value"] is None:
        raise MissingRequiredInput("value")
    value = inputs["value"]
    if not isinstance(value, str):
        raise TypeError(
            f"input 'value' must be a string per capsule.yaml, got {type(value).__name__}"
        )
    return {"greeting": f"Hello, {value}!"}
