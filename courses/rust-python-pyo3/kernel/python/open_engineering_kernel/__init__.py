"""Open Engineering Mini Kernel - Python surface.

Re-exports the native Rust extension so callers can write:

    from open_engineering_kernel import Identifier, validate_manifest
"""

from .open_engineering_kernel import (
  Identifier,
  normalize_identifier,
  validate_manifest,
  validate_manifest_py,
  evaluate_rule,
  evaluate_rule_py,
  evaluate_first,
  evaluate_first_py,
  InvalidIdentifierError,
  InvalidManifestError,
  RuleEvaluationError,
)

__all__ = [
  "Identifier",
  "normalize_identifier",
  "validate_manifest",
  "validate_manifest_py",
  "evaluate_rule",
  "evaluate_rule_py",
  "evaluate_first",
  "evaluate_first_py",
  "InvalidIdentifierError",
  "InvalidManifestError",
  "RuleEvaluationError",
]
