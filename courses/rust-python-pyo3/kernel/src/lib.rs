//! Open Engineering Mini Kernel
//!
//! Canonical domain logic in Rust, exposed to Python via PyO3.
//!
//! Principle:
//!   Python describes what should happen.
//!   Rust guarantees how fundamental things happen.

mod error;
mod identifier;
mod manifest;
mod rule;

pub use error::KernelError;
pub use identifier::Identifier;
pub use manifest::{validate_manifest, validate_manifest_strict, Manifest, ValidationResult};
pub use rule::{
    evaluate_first, evaluate_rule, rule_from_value, Action, Condition, EvaluationResult,
    Observation, Rule,
};

use pyo3::exceptions::{PyException, PyValueError};
use pyo3::prelude::*;
use pyo3::types::{PyDict, PyList};
use serde_json::Value;
use std::collections::HashMap;

// ---------------------------------------------------------------------------
// Python exception types
// ---------------------------------------------------------------------------

pyo3::create_exception!(
    open_engineering_kernel,
    InvalidIdentifierError,
    PyException,
    "Raised when an identifier cannot be parsed or is invalid."
);

pyo3::create_exception!(
    open_engineering_kernel,
    InvalidManifestError,
    PyException,
    "Raised when a manifest fails validation."
);

pyo3::create_exception!(
    open_engineering_kernel,
    RuleEvaluationError,
    PyException,
    "Raised when rule evaluation fails."
);

// ---------------------------------------------------------------------------
// Identifier (Python class)
// ---------------------------------------------------------------------------

/// An Open Engineering identifier (`namespace.kind.name`).
#[pyclass(name = "Identifier", module = "open_engineering_kernel")]
#[derive(Clone)]
pub struct PyIdentifier {
    inner: Identifier,
}

#[pymethods]
impl PyIdentifier {
    /// Parse a dotted identifier string.
    ///
    /// Example:
    ///     >>> Identifier.parse("open-engineering.pico.lamp")
    #[staticmethod]
    fn parse(value: &str) -> PyResult<Self> {
        Identifier::parse(value)
            .map(|inner| Self { inner })
            .map_err(|e| InvalidIdentifierError::new_err(e.to_string()))
    }

    #[new]
    fn new(namespace: &str, kind: &str, name: &str) -> PyResult<Self> {
        Identifier::new(namespace, kind, name)
            .map(|inner| Self { inner })
            .map_err(|e| InvalidIdentifierError::new_err(e.to_string()))
    }

    #[getter]
    fn namespace(&self) -> &str {
        self.inner.namespace()
    }

    #[getter]
    fn kind(&self) -> &str {
        self.inner.kind()
    }

    #[getter]
    fn name(&self) -> &str {
        self.inner.name()
    }

    /// Canonical string form.
    fn as_str(&self) -> String {
        self.inner.as_str()
    }

    fn __str__(&self) -> String {
        self.inner.to_string()
    }

    fn __repr__(&self) -> String {
        format!("Identifier('{}')", self.inner)
    }

    fn __eq__(&self, other: &Self) -> bool {
        self.inner == other.inner
    }
}

// ---------------------------------------------------------------------------
// Standalone functions
// ---------------------------------------------------------------------------

/// Normalize an identifier string (trim + lowercase).
/// Kept for early modules that only need a simple function.
#[pyfunction]
fn normalize_identifier(value: &str) -> String {
    value.trim().to_lowercase()
}

/// Validate a manifest (Python dict) and return a result dict.
///
/// Returns:
///     {
///         "valid": bool,
///         "errors": list[str],
///         "manifest": dict | None
///     }
#[pyfunction]
fn validate_manifest_py(py: Python<'_>, data: &Bound<'_, PyDict>) -> PyResult<PyObject> {
    let value: Value = pythonize_dict(data)?;
    let result = validate_manifest(&value);

    let out = PyDict::new_bound(py);
    out.set_item("valid", result.valid)?;
    out.set_item("errors", result.errors)?;

    if let Some(m) = result.manifest {
        let mdict = PyDict::new_bound(py);
        mdict.set_item("kind", &m.kind)?;
        mdict.set_item("name", &m.name)?;
        if let Some(v) = &m.version {
            mdict.set_item("version", v)?;
        }
        if let Some(id) = &m.identifier {
            mdict.set_item("identifier", id.as_str())?;
        }
        out.set_item("manifest", mdict)?;
    } else {
        out.set_item("manifest", py.None())?;
    }

    Ok(out.into())
}

/// Evaluate a single rule against an observation.
///
/// rule: dict matching the Rule schema
/// observation: dict[str, str]
#[pyfunction]
fn evaluate_rule_py(
    py: Python<'_>,
    rule: &Bound<'_, PyDict>,
    observation: &Bound<'_, PyDict>,
) -> PyResult<PyObject> {
    let rule_value: Value = pythonize_dict(rule)?;
    let rule = rule_from_value(&rule_value)
        .map_err(|e| RuleEvaluationError::new_err(e.to_string()))?;

    let obs = dict_to_observation(observation)?;
    let result = evaluate_rule(&rule, &obs);

    evaluation_result_to_py(py, &result)
}

/// Evaluate a list of rules; return the first match.
#[pyfunction]
fn evaluate_first_py(
    py: Python<'_>,
    rules: &Bound<'_, PyList>,
    observation: &Bound<'_, PyDict>,
) -> PyResult<PyObject> {
    let mut parsed = Vec::new();
    for item in rules.iter() {
        let d: Bound<'_, PyDict> = item.extract()?;
        let v: Value = pythonize_dict(&d)?;
        let r = rule_from_value(&v).map_err(|e| RuleEvaluationError::new_err(e.to_string()))?;
        parsed.push(r);
    }
    let obs = dict_to_observation(observation)?;
    let result = evaluate_first(&parsed, &obs);
    evaluation_result_to_py(py, &result)
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

fn pythonize_dict(d: &Bound<'_, PyDict>) -> PyResult<Value> {
    // Convert via JSON string for simplicity and robustness in the course.
    let mut map = serde_json::Map::new();
    for (k, v) in d.iter() {
        let key: String = k.extract()?;
        let val = py_any_to_value(&v)?;
        map.insert(key, val);
    }
    Ok(Value::Object(map))
}

fn py_any_to_value(obj: &Bound<'_, PyAny>) -> PyResult<Value> {
    if obj.is_none() {
        return Ok(Value::Null);
    }
    if let Ok(b) = obj.extract::<bool>() {
        return Ok(Value::Bool(b));
    }
    if let Ok(i) = obj.extract::<i64>() {
        return Ok(Value::Number(i.into()));
    }
    if let Ok(f) = obj.extract::<f64>() {
        if let Some(n) = serde_json::Number::from_f64(f) {
            return Ok(Value::Number(n));
        }
    }
    if let Ok(s) = obj.extract::<String>() {
        return Ok(Value::String(s));
    }
    if let Ok(list) = obj.downcast::<PyList>() {
        let mut arr = Vec::new();
        for item in list.iter() {
            arr.push(py_any_to_value(&item)?);
        }
        return Ok(Value::Array(arr));
    }
    if let Ok(dict) = obj.downcast::<PyDict>() {
        return pythonize_dict(&dict);
    }
    Err(PyValueError::new_err(format!(
        "unsupported type for conversion: {}",
        obj.get_type()
    )))
}

fn dict_to_observation(d: &Bound<'_, PyDict>) -> PyResult<Observation> {
    let mut obs = HashMap::new();
    for (k, v) in d.iter() {
        let key: String = k.extract()?;
        let val: String = v.extract()?;
        obs.insert(key, val);
    }
    Ok(obs)
}

fn evaluation_result_to_py(py: Python<'_>, result: &EvaluationResult) -> PyResult<PyObject> {
    let out = PyDict::new_bound(py);
    out.set_item("matched", result.matched)?;
    out.set_item("rule_id", result.rule_id.clone())?;

    let actions = PyList::empty_bound(py);
    for action in &result.actions {
        let a = PyDict::new_bound(py);
        match action {
            Action::Emit { event } => {
                a.set_item("op", "emit")?;
                a.set_item("event", event)?;
            }
            Action::Set { key, value } => {
                a.set_item("op", "set")?;
                a.set_item("key", key)?;
                a.set_item("value", value)?;
            }
        }
        actions.append(a)?;
    }
    out.set_item("actions", actions)?;
    Ok(out.into())
}

// ---------------------------------------------------------------------------
// Module entry point
// ---------------------------------------------------------------------------

/// Open Engineering Mini Kernel — Python module.
#[pymodule]
fn open_engineering_kernel(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<PyIdentifier>()?;
    m.add_function(wrap_pyfunction!(normalize_identifier, m)?)?;
    m.add_function(wrap_pyfunction!(validate_manifest_py, m)?)?;
    m.add_function(wrap_pyfunction!(evaluate_rule_py, m)?)?;
    m.add_function(wrap_pyfunction!(evaluate_first_py, m)?)?;

    // Friendly aliases matching the course narrative
    m.add("validate_manifest", m.getattr("validate_manifest_py")?)?;
    m.add("evaluate_rule", m.getattr("evaluate_rule_py")?)?;
    m.add("evaluate_first", m.getattr("evaluate_first_py")?)?;

    m.add(
        "InvalidIdentifierError",
        m.py().get_type_bound::<InvalidIdentifierError>(),
    )?;
    m.add(
        "InvalidManifestError",
        m.py().get_type_bound::<InvalidManifestError>(),
    )?;
    m.add(
        "RuleEvaluationError",
        m.py().get_type_bound::<RuleEvaluationError>(),
    )?;

    Ok(())
}
