//! Open Engineering Identifier
//!
//! Canonical teaching form (three segments):
//!
//! ```text
//! namespace.kind.name
//! ```
//!
//! Academy metadata uses the compact namespace `oe`:
//!
//! - `oe.course.pico`
//! - `oe.lab.hello-pico`
//! - `oe.exercise.pico-first-rule`
//!
//! The longer namespace `open-engineering` is also accepted and is
//! treated as equivalent in spirit (full organisational name).
//! Both are valid; `oe` is preferred for machine-readable ids.
//!
//! Rules:
//! - exactly three segments separated by `.`
//! - each segment is non-empty
//! - only lowercase letters, digits, and hyphens
//! - segments are normalized to lowercase on parse
//! - no leading or trailing hyphen in a segment
//!
//! Hierarchical lesson ids such as `oe.lesson.pico.01-introduction`
//! (four segments) are intentionally out of scope for this mini-kernel;
//! they remain a documented Academy convention for a later extension.

use crate::error::KernelError;
use serde::{Deserialize, Serialize};
use std::fmt;
use std::str::FromStr;

/// Preferred compact namespace used in Academy metadata.yaml files.
pub const NAMESPACE_OE: &str = "oe";

/// Full organisational namespace (also accepted).
#[allow(dead_code)]
pub const NAMESPACE_OPEN_ENGINEERING: &str = "open-engineering";

/// A validated Open Engineering identifier (`namespace.kind.name`).
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct Identifier {
    namespace: String,
    kind: String,
    name: String,
}

impl Identifier {
    /// Create an Identifier from already-validated parts.
    pub fn new(
        namespace: impl Into<String>,
        kind: impl Into<String>,
        name: impl Into<String>,
    ) -> Result<Self, KernelError> {
        let namespace = normalize_segment(&namespace.into())?;
        let kind = normalize_segment(&kind.into())?;
        let name = normalize_segment(&name.into())?;
        Ok(Self {
            namespace,
            kind,
            name,
        })
    }

    /// Parse a dotted identifier string.
    ///
    /// Accepts both `oe.course.pico` and `open-engineering.pico.lamp`.
    pub fn parse(value: &str) -> Result<Self, KernelError> {
        let value = value.trim();
        if value.is_empty() {
            return Err(KernelError::invalid_identifier(
                "identifier must not be empty",
            ));
        }

        let parts: Vec<&str> = value.split('.').collect();
        if parts.len() != 3 {
            return Err(KernelError::invalid_identifier(format!(
                "expected three segments (namespace.kind.name), got {} \
                 (hierarchical ids with more segments are out of scope for this kernel)",
                parts.len()
            )));
        }

        Self::new(parts[0], parts[1], parts[2])
    }

    pub fn namespace(&self) -> &str {
        &self.namespace
    }

    pub fn kind(&self) -> &str {
        &self.kind
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    /// Whether this identifier uses the compact Academy namespace `oe`.
    pub fn is_academy_compact(&self) -> bool {
        self.namespace == NAMESPACE_OE
    }

    /// Canonical string form.
    pub fn as_str(&self) -> String {
        format!("{}.{}.{}", self.namespace, self.kind, self.name)
    }
}

impl FromStr for Identifier {
    type Err = KernelError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Self::parse(s)
    }
}

impl fmt::Display for Identifier {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}.{}.{}", self.namespace, self.kind, self.name)
    }
}

fn normalize_segment(segment: &str) -> Result<String, KernelError> {
    let s = segment.trim().to_lowercase();
    if s.is_empty() {
        return Err(KernelError::invalid_identifier(
            "identifier segment must not be empty",
        ));
    }
    if !s
        .chars()
        .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
    {
        return Err(KernelError::invalid_identifier(format!(
            "segment '{s}' contains invalid characters (allowed: a-z, 0-9, -)"
        )));
    }
    if s.starts_with('-') || s.ends_with('-') {
        return Err(KernelError::invalid_identifier(format!(
            "segment '{s}' must not start or end with a hyphen"
        )));
    }
    Ok(s)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_academy_compact() {
        let id = Identifier::parse("oe.course.pico").unwrap();
        assert_eq!(id.namespace(), "oe");
        assert_eq!(id.kind(), "course");
        assert_eq!(id.name(), "pico");
        assert!(id.is_academy_compact());
        assert_eq!(id.as_str(), "oe.course.pico");
    }

    #[test]
    fn parse_lab_style() {
        let id = Identifier::parse("oe.lab.hello-pico").unwrap();
        assert_eq!(id.kind(), "lab");
        assert_eq!(id.name(), "hello-pico");
    }

    #[test]
    fn parse_full_namespace() {
        let id = Identifier::parse("open-engineering.pico.lamp").unwrap();
        assert_eq!(id.namespace(), "open-engineering");
        assert!(!id.is_academy_compact());
    }

    #[test]
    fn normalize_case() {
        let id = Identifier::parse("  OE.Course.Pico  ").unwrap();
        assert_eq!(id.as_str(), "oe.course.pico");
    }

    #[test]
    fn reject_wrong_segment_count() {
        assert!(Identifier::parse("a.b").is_err());
        assert!(Identifier::parse("a.b.c.d").is_err());
        assert!(Identifier::parse("oe.lesson.pico.01-introduction").is_err());
        assert!(Identifier::parse("").is_err());
    }

    #[test]
    fn reject_invalid_chars() {
        assert!(Identifier::parse("open_engineering.pico.lamp").is_err());
        assert!(Identifier::parse("open engineering.pico.lamp").is_err());
    }

    #[test]
    fn reject_hyphen_edges() {
        assert!(Identifier::parse("-oe.pico.lamp").is_err());
        assert!(Identifier::parse("oe-.pico.lamp").is_err());
    }
}
