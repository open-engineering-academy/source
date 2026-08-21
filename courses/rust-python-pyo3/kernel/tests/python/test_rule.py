"""Python contract tests for rule evaluation."""

from open_engineering_kernel import evaluate_rule, evaluate_first


def test_eq_matches():
    rule = {
        "id": "r1",
        "when": {"op": "eq", "key": "status", "value": "ready"},
        "then": {"op": "emit", "event": "start"},
    }
    result = evaluate_rule(rule, {"status": "ready"})
    assert result["matched"] is True
    assert result["rule_id"] == "r1"
    assert result["actions"][0]["op"] == "emit"
    assert result["actions"][0]["event"] == "start"


def test_eq_no_match():
    rule = {
        "id": "r1",
        "when": {"op": "eq", "key": "status", "value": "ready"},
        "then": {"op": "emit", "event": "start"},
    }
    result = evaluate_rule(rule, {"status": "busy"})
    assert result["matched"] is False
    assert result["actions"] == []


def test_and_condition():
    rule = {
        "id": "nod",
        "when": {
            "op": "and",
            "conditions": [
                {"op": "present", "key": "device"},
                {"op": "eq", "key": "intent", "value": "nod"},
            ],
        },
        "then": {"op": "emit", "event": "nod"},
    }
    result = evaluate_rule(rule, {"device": "lamp", "intent": "nod"})
    assert result["matched"] is True
    assert result["actions"][0]["event"] == "nod"


def test_evaluate_first():
    rules = [
        {
            "id": "r1",
            "when": {"op": "eq", "key": "x", "value": "1"},
            "then": {"op": "emit", "event": "one"},
        },
        {
            "id": "r2",
            "when": {"op": "eq", "key": "x", "value": "2"},
            "then": {"op": "emit", "event": "two"},
        },
    ]
    result = evaluate_first(rules, {"x": "2"})
    assert result["matched"] is True
    assert result["rule_id"] == "r2"
