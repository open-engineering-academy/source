#!/usr/bin/env python3
"""Narrow validator for the hello-pico-v1 example package.

Checks:
1. package.yaml parses as YAML.
2. The three records (definition, realization, element) are present and each
   carries the fields required by the hello-pico-v1 profile in
   templates/README.qmd.
3. Internal cross-references are consistent:
   - realization.realizes -> definition.id
   - element.realizes     -> definition.id (single-item)
   - element.produced_by  -> realization.id
   - every validation_results[].check appears in validated_by
   - every validation_results[].validates_constraint text appears in
     definition.constraints
4. External artefact paths under taught_surfaces exist on disk.
"""
import os
import sys
import yaml

PKG_DIR = os.path.abspath(os.path.dirname(__file__))
REPO = os.path.abspath(os.path.join(PKG_DIR, "..", "..", ".."))
PKG_FILE = os.path.join(PKG_DIR, "package.yaml")


def fail(msg, errors):
    errors.append(msg)


def check_role(record, role, required, errors):
    for field in required:
        if field not in record or record[field] in (None, "", [], {}):
            fail(f"{role}: missing required field '{field}'", errors)
    if record.get("constructive_role") != role:
        fail(
            f"{role}: constructive_role expected '{role}', got "
            f"'{record.get('constructive_role')}'",
            errors,
        )
    if record.get("checkable_profile") != "hello-pico-v1":
        fail(f"{role}: checkable_profile must be 'hello-pico-v1'", errors)


def check_validations(record, role, constraints, errors):
    validated_by = set(record.get("validated_by") or [])
    for entry in record.get("validation_results") or []:
        check = entry.get("check")
        if check not in validated_by:
            fail(
                f"{role}: validation_results check '{check}' not in validated_by",
                errors,
            )
        if entry.get("result") not in {"passed", "failed", "not-run"}:
            fail(
                f"{role}: validation_results result must be passed/failed/not-run",
                errors,
            )
        vc = entry.get("validates_constraint")
        if vc and vc not in constraints:
            fail(
                f"{role}: validates_constraint text not found in definition.constraints: {vc}",
                errors,
            )


def main():
    errors = []
    try:
        with open(PKG_FILE) as f:
            doc = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"FAIL: package.yaml does not parse: {e}")
        return 2

    if doc.get("checkable_profile") != "hello-pico-v1":
        fail("top-level checkable_profile must be 'hello-pico-v1'", errors)
    pkg = doc.get("package") or {}
    d = pkg.get("definition") or {}
    r = pkg.get("realization") or {}
    e = pkg.get("element") or {}
    if not (d and r and e):
        print("FAIL: package.yaml must define definition, realization, and element")
        return 2

    check_role(
        d, "definition",
        ["id", "title", "produces", "realization_pattern", "constraints"],
        errors,
    )
    check_role(
        r, "realization",
        ["id", "title", "realizes", "depends_on", "produces",
         "realization_pattern", "conformance_status", "lifecycle_state",
         "validated_by", "validation_results"],
        errors,
    )
    check_role(
        e, "element",
        ["id", "title", "realizes", "produced_by", "lifecycle_state",
         "validated_by", "validation_results"],
        errors,
    )

    if r.get("realizes") != [d.get("id")]:
        fail("realization.realizes must be single-item pointing at definition.id", errors)
    if e.get("realizes") != [d.get("id")]:
        fail("element.realizes must be single-item pointing at definition.id", errors)
    if e.get("produced_by") != r.get("id"):
        fail("element.produced_by must equal realization.id", errors)

    constraints = set(d.get("constraints") or [])
    check_validations(r, "realization", constraints, errors)
    check_validations(e, "element", constraints, errors)

    for _, rel in (pkg.get("taught_surfaces") or {}).items():
        if not os.path.exists(os.path.join(REPO, rel)):
            fail(f"taught_surfaces path missing on disk: {rel}", errors)

    if errors:
        print("FAIL")
        for m in errors:
            print(f"  - {m}")
        return 1
    print("OK: hello-pico-v1 example package is internally coherent.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
