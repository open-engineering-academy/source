//! Manifest validation
//!
//! A minimal Open Engineering manifest is a structured document that
//! declares kind, name, and optional version / metadata.
//!
//! Validation lives in Rust so the semantics are canonical.

use crate::error::KernelError;
use crate::identifier::Identifier;
use serde::{Deserialize, Serialize};
use serde_json::Value;

/// Validated manifest representation.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Manifest {
    pub kind: String,
    pub name: String,
    pub version: Option<String>,
    pub identifier: Option<Identifier>,
}

/// Result of validating a manifest.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValidationResult {
    pub valid: bool,
    pub errors: Vec<String>,
    pub manifest: Option<Manifest>,
}

/// Validate a JSON-like structure (typically coming from Python as a dict).
pub fn validate_manifest(value: &Value) -> ValidationResult {
    let mut errors = Vec::new();

    let kind = match value.get("kind").and_then(|v| v.as_str()) {
        Some(k) if !k.trim().is_empty() => k.trim().to_lowercase(),
        _ => {
            errors.push("missing or empty 'kind'".into());
            String::new()
        }
    };

    let name = match value.get("name").and_then(|v| v.as_str()) {
        Some(n) if !n.trim().is_empty() => n.trim().to_lowercase(),
        _ => {
            errors.push("missing or empty 'name'".into());
            String::new()
        }
    };

    let version = value
        .get("version")
        .and_then(|v| v.as_str())
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty());

    // Optional explicit identifier; otherwise synthesize from namespace + kind + name
    let identifier = if let Some(id_str) = value.get("identifier").and_then(|v| v.as_str()) {
        match Identifier::parse(id_str) {
            Ok(id) => Some(id),
            Err(e) => {
                errors.push(format!("identifier: {e}"));
                None
            }
        }
    } else if !kind.is_empty() && !name.is_empty() {
        // Default namespace for Academy examples
        match Identifier::new("oe", &kind, &name) {
            Ok(id) => Some(id),
            Err(e) => {
                errors.push(format!("could not synthesize identifier: {e}"));
                None
            }
        }
    } else {
        None
    };

    if !errors.is_empty() {
        return ValidationResult {
            valid: false,
            errors,
            manifest: None,
        };
    }

    ValidationResult {
        valid: true,
        errors: vec![],
        manifest: Some(Manifest {
            kind,
            name,
            version,
            identifier,
        }),
    }
}

/// Convenience: validate and return Result.
pub fn validate_manifest_strict(value: &Value) -> Result<Manifest, KernelError> {
    let result = validate_manifest(value);
    if result.valid {
        Ok(result.manifest.expect("valid result always has manifest"))
    } else {
        Err(KernelError::invalid_manifest(result.errors.join("; ")))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn valid_minimal() {
        let v = json!({"kind": "pico", "name": "lamp"});
        let r = validate_manifest(&v);
        assert!(r.valid);
        let m = r.manifest.unwrap();
        assert_eq!(m.kind, "pico");
        assert_eq!(m.name, "lamp");
        assert_eq!(
            m.identifier.as_ref().map(|i| i.as_str()),
            Some("oe.pico.lamp".into())
        );
    }

    #[test]
    fn missing_kind() {
        let v = json!({"name": "lamp"});
        let r = validate_manifest(&v);
        assert!(!r.valid);
        assert!(r.errors.iter().any(|e| e.contains("kind")));
    }

    #[test]
    fn with_explicit_identifier() {
        let v = json!({
            "kind": "pico",
            "name": "lamp",
            "identifier": "oe.pico.lamp"
        });
        let r = validate_manifest(&v);
        assert!(r.valid);
    }
}
