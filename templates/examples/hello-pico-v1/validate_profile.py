#!/usr/bin/env python3
"""Local Hello Pico profile validator (Phase 5+6, opt-in, non-blocking).

Discovers every ``metadata.yaml`` file under ``courses/`` and ``labs/``
that declares ``checkable_profile: hello-pico-v1``, applies the Phase 4
shape rules for the claimant's ``constructive_role``, and emits one
Phase 5 validation report per claimant matching the shape defined in
``templates/README.qmd`` (fields: ``profile``, ``subject``,
``subject_role``, ``checked_at``, ``overall``, ``findings[]``,
``evidence_reviewed[]``).

Output modes (mutually exclusive; default is per-claimant reports):

* default: one Phase 5 validation report per claimant on stdout.
* ``--aggregate``: one Phase 6 report-index across the opted-in
  claimants (``profile``, ``generated_at``, ``entries[]``).
* ``--feedback-summary``: a bounded summary of approved claimants and
  where their reports could refine the governing Definition, without
  mutating any repository metadata.

Any mode combined with ``--write`` also writes to
``templates/examples/hello-pico-v1/reports/`` (per-claimant files for
the default mode, ``index.yaml`` for ``--aggregate``,
``feedback-summary.yaml`` for ``--feedback-summary``).

This script is deliberately narrow: it reads only ``metadata.yaml``
files it discovers, never executes shipped Validations (``verify.sh``,
``kubectl``, ...), and never mutates any repository metadata file.
"""
import argparse
import datetime
import os
import re
import sys
import yaml

HERE = os.path.abspath(os.path.dirname(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
PROFILE = "hello-pico-v1"
ROLE_ROOTS = ("courses", "labs")
SKIP_DIRS = {"_site", "_freeze", ".quarto", "node_modules"}


def _iter_metadata(root_name):
    for dirpath, dirnames, filenames in os.walk(os.path.join(REPO, root_name)):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS and not d.startswith(".")]
        if "metadata.yaml" not in filenames:
            continue
        path = os.path.join(dirpath, "metadata.yaml")
        with open(path) as f:
            try:
                doc = yaml.safe_load(f) or {}
            except yaml.YAMLError:
                continue
        yield os.path.relpath(path, REPO), doc


def discover_claimants():
    hits = []
    for root_name in ROLE_ROOTS:
        for rel, doc in _iter_metadata(root_name):
            if doc.get("checkable_profile") == PROFILE:
                hits.append((rel, doc))
    hits.sort(key=lambda item: item[0])
    return hits


def load_index():
    by_id = {}
    for root_name in ROLE_ROOTS:
        for rel, doc in _iter_metadata(root_name):
            if isinstance(doc.get("id"), str):
                by_id[doc["id"]] = (rel, doc)
    return by_id


def _f(rule, status, details, path=None):
    entry = {"rule": rule, "status": status, "details": details}
    if path is not None:
        entry["path"] = path
    return entry


def check_definition(doc, rel, index):
    findings = []
    for field in ("id", "title", "produces"):
        val = doc.get(field)
        findings.append(_f(
            f"definition.has-{field}",
            "satisfied" if val not in (None, "", [], {}) else "violated",
            f"{field} present" if val else f"{field} is empty or missing",
            rel,
        ))
    constraints = doc.get("constraints") or []
    findings.append(_f(
        "definition.has-constraints",
        "satisfied" if constraints else "violated",
        f"{len(constraints)} constraint(s) declared" if constraints else "no constraints declared",
        rel,
    ))
    realizations = [d for _, d in index.values()
                    if d.get("constructive_role") == "realization"
                    and doc.get("id") in (d.get("realizes") or [])]
    pattern = next((r.get("realization_pattern") for r in realizations
                    if r.get("realization_pattern")), None)
    if pattern:
        findings.append(_f("definition.reachable-realization-pattern", "satisfied",
                           f"reachable via a realization with realization_pattern='{pattern}'.", rel))
    elif realizations:
        findings.append(_f("definition.reachable-realization-pattern", "violated",
                           "realizations found but none declare realization_pattern.", rel))
    else:
        findings.append(_f("definition.reachable-realization-pattern", "not-applicable",
                           "no realization records reachable from this Definition; rule cannot be evaluated.", rel))
    return findings, []


def check_realization(doc, rel, index):
    findings = []
    realizes = doc.get("realizes") or []
    single = isinstance(realizes, list) and len(realizes) == 1
    findings.append(_f("realization.names-exactly-one-definition",
                       "satisfied" if single else "violated",
                       f"realizes: {realizes}" if single else f"realizes must be single-item; got {realizes}", rel))
    findings.append(_f("realization.has-depends-on",
                       "satisfied" if (doc.get("depends_on") or []) else "violated",
                       "depends_on has at least one entry" if (doc.get("depends_on") or []) else "depends_on missing or empty", rel))
    findings.append(_f("realization.has-produces",
                       "satisfied" if (doc.get("produces") or []) else "violated",
                       "produces has at least one entry" if (doc.get("produces") or []) else "produces missing or empty", rel))
    findings.append(_f("realization.has-realization-pattern",
                       "satisfied" if doc.get("realization_pattern") else "violated",
                       f"realization_pattern='{doc.get('realization_pattern')}'" if doc.get("realization_pattern") else "realization_pattern missing", rel))
    findings.append(_f("realization.has-lifecycle-and-conformance",
                       "satisfied" if doc.get("lifecycle_state") and doc.get("conformance_status") else "violated",
                       f"lifecycle_state={doc.get('lifecycle_state')!r}; conformance_status={doc.get('conformance_status')!r}", rel))

    validated_by = doc.get("validated_by") or []
    results = doc.get("validation_results") or []
    result_names = {r.get("check") for r in results}
    unmatched = [name for name in validated_by if name not in result_names]
    bad_result = [r for r in results if r.get("result") not in {"passed", "failed", "not-run"}]
    if validated_by and not unmatched and not bad_result:
        findings.append(_f("validation.has-result", "satisfied",
                           "every validated_by entry has a validation_results entry with a valid result.", rel))
    else:
        detail = []
        if not validated_by: detail.append("validated_by empty")
        if unmatched: detail.append(f"unmatched validated_by: {unmatched}")
        if bad_result: detail.append(f"bad result values: {[r.get('result') for r in bad_result]}")
        findings.append(_f("validation.has-result", "violated", "; ".join(detail), rel))

    constraint_texts = set()
    def_id = realizes[0] if single else None
    def_rel = None
    if def_id and def_id in index:
        def_rel, def_doc = index[def_id]
        constraint_texts = set(def_doc.get("constraints") or [])
    validates = [r.get("validates_constraint") for r in results if r.get("validates_constraint")]
    unknown = [v for v in validates if constraint_texts and v not in constraint_texts]
    if def_id is None:
        findings.append(_f("constraint.validates-known-text", "not-applicable",
                           "cannot check validates_constraint texts without a single Definition target.", rel))
    elif def_rel is None:
        findings.append(_f("constraint.validates-known-text", "not-applicable",
                           f"Definition '{def_id}' not resolvable from index; rule cannot be evaluated.", rel))
    elif unknown:
        findings.append(_f("constraint.validates-known-text", "violated",
                           f"validates_constraint text(s) not in Definition constraints: {unknown}", def_rel))
    elif validates and constraint_texts:
        covered = {v for v in validates}
        missing = [c for c in constraint_texts if c not in covered]
        if missing:
            findings.append(_f("constraint.covered-by-validation", "violated",
                               f"constraint(s) not covered by any validates_constraint: {missing}", def_rel))
        else:
            findings.append(_f("constraint.covered-by-validation", "satisfied",
                               "every Definition constraint is covered by at least one validates_constraint.", def_rel))
    else:
        findings.append(_f("constraint.covered-by-validation", "not-applicable",
                           "no validates_constraint entries to correlate.", rel))

    evidence = doc.get("evidence") or []
    ev_bad = [e.get("check") for e in evidence if e.get("check") not in {v for v in validated_by}]
    if evidence and not ev_bad:
        findings.append(_f("evidence.matches-validated-by", "satisfied",
                           "every evidence[].check matches a validated_by entry.", rel))
    elif ev_bad:
        findings.append(_f("evidence.matches-validated-by", "violated",
                           f"evidence[].check names not in validated_by: {ev_bad}", rel))
    else:
        findings.append(_f("evidence.matches-validated-by", "not-applicable",
                           "no Phase 3 evidence entries present.", rel))

    return findings, list(validated_by)


def check_element(doc, rel, index):
    findings = []
    realizes = doc.get("realizes") or []
    single = isinstance(realizes, list) and len(realizes) == 1
    findings.append(_f("element.realizes-single-definition",
                       "satisfied" if single else "violated",
                       f"realizes: {realizes}", rel))
    findings.append(_f("element.has-produced-by",
                       "satisfied" if isinstance(doc.get("produced_by"), str) and doc.get("produced_by") else "violated",
                       f"produced_by={doc.get('produced_by')!r}", rel))
    findings.append(_f("element.has-lifecycle-state",
                       "satisfied" if doc.get("lifecycle_state") else "violated",
                       f"lifecycle_state={doc.get('lifecycle_state')!r}", rel))
    validated_by = doc.get("validated_by") or []
    results = doc.get("validation_results") or []
    matched = validated_by and all(any(r.get("check") == v for r in results) for v in validated_by)
    findings.append(_f("element.has-validated-by-with-result",
                       "satisfied" if matched else "violated",
                       f"validated_by={validated_by}", rel))
    return findings, list(validated_by)


ROLE_CHECKS = {
    "definition": check_definition,
    "realization": check_realization,
    "element": check_element,
}


def build_report(rel, doc, index):
    role = doc.get("constructive_role")
    checker = ROLE_CHECKS.get(role)
    if checker is None:
        findings = [_f("profile.known-role", "violated",
                       f"unknown constructive_role: {role!r}", rel)]
        evidence_reviewed = []
    else:
        findings, evidence_reviewed = checker(doc, rel, index)
    if any(f["status"] == "violated" for f in findings):
        overall = "non-conformant"
    elif any(f["status"] == "not-applicable" for f in findings):
        overall = "inconclusive"
    else:
        overall = "conformant"
    return {
        "profile": PROFILE,
        "subject": doc.get("id"),
        "subject_role": role,
        "checked_at": datetime.date.today().isoformat(),
        "overall": overall,
        "findings": findings,
        "evidence_reviewed": evidence_reviewed,
    }


def _slug(subject):
    return re.sub(r"[^a-z0-9]+", "-", (subject or "unknown").lower()).strip("-")


REPORTS_REL = "templates/examples/hello-pico-v1/reports"


def _history_for(subject, reports_dir):
    slug = _slug(subject)
    history_dir = os.path.join(reports_dir, "history")
    if not os.path.isdir(history_dir):
        return []
    prefix = slug + "."
    snapshots = [name for name in os.listdir(history_dir)
                 if name.startswith(prefix) and name.endswith(".yaml")]
    snapshots.sort(reverse=True)
    return [f"{REPORTS_REL}/history/{name}" for name in snapshots]


def build_aggregate(reports, reports_dir):
    entries = []
    for report in reports:
        subject = report["subject"]
        entries.append({
            "subject": subject,
            "subject_role": report["subject_role"],
            "report": f"{REPORTS_REL}/{_slug(subject)}.yaml",
            "overall": report["overall"],
            "checked_at": report["checked_at"],
            "history": _history_for(subject, reports_dir),
        })
    return {
        "profile": PROFILE,
        "generated_at": datetime.date.today().isoformat(),
        "entries": entries,
    }


def _governing_definition(doc, index):
    if doc.get("constructive_role") == "definition":
        return doc.get("id")
    realizes = doc.get("realizes") or []
    if isinstance(realizes, list) and len(realizes) == 1:
        return realizes[0]
    return None


def _metadata_path_for(subject_id, doc, rel, index):
    if doc.get("id") == subject_id:
        return rel
    hit = index.get(subject_id)
    if hit:
        return hit[0]
    return None


def _existing_feedback(doc):
    out = []
    for entry in (doc.get("feedback") or []):
        if not isinstance(entry, dict):
            continue
        out.append({
            "about": entry.get("about"),
            "refines": entry.get("refines"),
            "from_report": entry.get("from_report"),
        })
    return out


def build_feedback_summary(claimants_with_reports, index):
    approved = []
    skipped = []
    for rel, doc, report in claimants_with_reports:
        if report["overall"] != "conformant":
            skipped.append({
                "subject": report["subject"],
                "overall": report["overall"],
                "reason": "not an approved claimant; correct metadata before recording feedback.",
            })
            continue
        subject = report["subject"]
        gov_id = _governing_definition(doc, index)
        gov_path = _metadata_path_for(gov_id, doc, rel, index) if gov_id else None
        candidates = [
            {
                "rule": f["rule"],
                "details": f["details"],
                "path": f.get("path"),
            }
            for f in report["findings"] if f["status"] == "not-applicable"
        ]
        approved.append({
            "subject": subject,
            "subject_role": report["subject_role"],
            "report": f"{REPORTS_REL}/{_slug(subject)}.yaml",
            "claimant_metadata": rel,
            "governing_definition": gov_id,
            "governing_metadata": gov_path,
            "existing_feedback": _existing_feedback(doc),
            "candidate_observations": candidates,
        })
    return {
        "profile": PROFILE,
        "generated_at": datetime.date.today().isoformat(),
        "note": (
            "Informational summary. No metadata was modified by this run. "
            "Refinements are recorded manually as Phase 2 feedback[] entries "
            "on the governing Definition's metadata.yaml, and MAY carry an "
            "optional feedback[].from_report pointer."
        ),
        "approved_claimants": approved,
        "skipped_claimants": skipped,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--write", action="store_true",
                        help="Also write output under templates/examples/hello-pico-v1/reports/.")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--aggregate", action="store_true",
                      help="Emit one Phase 6 report-index across the opted-in claimants.")
    mode.add_argument("--feedback-summary", dest="feedback_summary",
                      action="store_true",
                      help="Emit a bounded feedback summary for approved claimants.")
    args = parser.parse_args()

    claimants = discover_claimants()
    if not claimants:
        print(f"No claimants found for checkable_profile: {PROFILE}.", file=sys.stderr)
        return 2
    index = load_index()
    reports = [(rel, doc, build_report(rel, doc, index)) for rel, doc in claimants]
    reports_dir = os.path.join(HERE, "reports")
    if args.write:
        os.makedirs(reports_dir, exist_ok=True)

    if args.aggregate:
        aggregate = build_aggregate([r for _, _, r in reports], reports_dir)
        print(yaml.safe_dump(aggregate, sort_keys=False, allow_unicode=True), end="")
        if args.write:
            with open(os.path.join(reports_dir, "index.yaml"), "w") as f:
                yaml.safe_dump(aggregate, f, sort_keys=False, allow_unicode=True)
        return 1 if any(r["overall"] == "non-conformant" for _, _, r in reports) else 0

    if args.feedback_summary:
        summary = build_feedback_summary(reports, index)
        print(yaml.safe_dump(summary, sort_keys=False, allow_unicode=True), end="")
        if args.write:
            with open(os.path.join(reports_dir, "feedback-summary.yaml"), "w") as f:
                yaml.safe_dump(summary, f, sort_keys=False, allow_unicode=True)
        return 0

    exit_code = 0
    for i, (_, _, report) in enumerate(reports):
        if i:
            print("---")
        print(yaml.safe_dump(report, sort_keys=False, allow_unicode=True), end="")
        if args.write:
            out = os.path.join(reports_dir, _slug(report["subject"]) + ".yaml")
            with open(out, "w") as f:
                yaml.safe_dump(report, f, sort_keys=False, allow_unicode=True)
        if report["overall"] == "non-conformant":
            exit_code = 1
    return exit_code


if __name__ == "__main__":
    sys.exit(main())