//! Domain errors for the Open Engineering mini-kernel.
//!
//! These errors are designed to cross the PyO3 boundary cleanly
//! and become useful Python exceptions.

use thiserror::Error;

#[derive(Debug, Error, PartialEq, Eq)]
pub enum KernelError {
    #[error("invalid identifier: {0}")]
    InvalidIdentifier(String),

    #[error("invalid manifest: {0}")]
    InvalidManifest(String),

    #[error("rule evaluation failed: {0}")]
    RuleEvaluation(String),
}

impl KernelError {
    pub fn invalid_identifier(msg: impl Into<String>) -> Self {
        Self::InvalidIdentifier(msg.into())
    }

    pub fn invalid_manifest(msg: impl Into<String>) -> Self {
        Self::InvalidManifest(msg.into())
    }

    pub fn rule_evaluation(msg: impl Into<String>) -> Self {
        Self::RuleEvaluation(msg.into())
    }
}
