//! Minimal rule evaluation
//!
//! Demonstrates deterministic evaluation living in Rust while
//! Python retains control of the larger workflow.
//!
//! A rule has the form:
//!   when <condition> then <action>
//!
//! For the course we support a very small language:
//! - equality on string observations
//! - presence of a key
//! - simple boolean conjunction

use crate::error::KernelError;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::HashMap;

/// A simple rule definition.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule {
    pub id: String,
    pub when: Condition,
    pub then: Action,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "op", rename_all = "snake_case")]
pub enum Condition {
    /// observation[key] == value
    Eq { key: String, value: String },
    /// key is present in observation
    Present { key: String },
    /// all sub-conditions must hold
    And { conditions: Vec<Condition> },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "op", rename_all = "snake_case")]
pub enum Action {
    /// emit a named event / signal
    Emit { event: String },
    /// set a value in a result map
    Set { key: String, value: String },
}

/// Observation is a flat string map (Python dict of strings).
pub type Observation = HashMap<String, String>;

/// Result of evaluating one or more rules.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvaluationResult {
    pub matched: bool,
    pub actions: Vec<Action>,
    pub rule_id: Option<String>,
}

impl Condition {
    pub fn evaluate(&self, obs: &Observation) -> bool {
        match self {
            Condition::Eq { key, value } => obs.get(key).map(|v| v == value).unwrap_or(false),
            Condition::Present { key } => obs.contains_key(key),
            Condition::And { conditions } => conditions.iter().all(|c| c.evaluate(obs)),
        }
    }
}

/// Evaluate a single rule against an observation.
pub fn evaluate_rule(rule: &Rule, observation: &Observation) -> EvaluationResult {
    if rule.when.evaluate(observation) {
        EvaluationResult {
            matched: true,
            actions: vec![rule.then.clone()],
            rule_id: Some(rule.id.clone()),
        }
    } else {
        EvaluationResult {
            matched: false,
            actions: vec![],
            rule_id: Some(rule.id.clone()),
        }
    }
}

/// Evaluate a list of rules; returns the first match (or no match).
pub fn evaluate_first(rules: &[Rule], observation: &Observation) -> EvaluationResult {
    for rule in rules {
        let result = evaluate_rule(rule, observation);
        if result.matched {
            return result;
        }
    }
    EvaluationResult {
        matched: false,
        actions: vec![],
        rule_id: None,
    }
}

/// Build a rule from a JSON value (convenient for the Python boundary).
pub fn rule_from_value(value: &Value) -> Result<Rule, KernelError> {
    serde_json::from_value(value.clone())
        .map_err(|e| KernelError::rule_evaluation(format!("invalid rule: {e}")))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn obs(pairs: &[(&str, &str)]) -> Observation {
        pairs
            .iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect()
    }

    #[test]
    fn eq_matches() {
        let rule = Rule {
            id: "r1".into(),
            when: Condition::Eq {
                key: "status".into(),
                value: "ready".into(),
            },
            then: Action::Emit {
                event: "start".into(),
            },
        };
        let result = evaluate_rule(&rule, &obs(&[("status", "ready")]));
        assert!(result.matched);
        assert_eq!(result.actions.len(), 1);
    }

    #[test]
    fn eq_no_match() {
        let rule = Rule {
            id: "r1".into(),
            when: Condition::Eq {
                key: "status".into(),
                value: "ready".into(),
            },
            then: Action::Emit {
                event: "start".into(),
            },
        };
        let result = evaluate_rule(&rule, &obs(&[("status", "busy")]));
        assert!(!result.matched);
    }

    #[test]
    fn and_condition() {
        let rule = Rule {
            id: "r2".into(),
            when: Condition::And {
                conditions: vec![
                    Condition::Present {
                        key: "device".into(),
                    },
                    Condition::Eq {
                        key: "intent".into(),
                        value: "nod".into(),
                    },
                ],
            },
            then: Action::Emit {
                event: "nod".into(),
            },
        };
        let result = evaluate_rule(
            &rule,
            &obs(&[("device", "lamp"), ("intent", "nod")]),
        );
        assert!(result.matched);
    }
}
