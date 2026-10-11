"""Check the issue-67 clean execution fixture, including record meaning."""

import argparse
import json
from pathlib import Path
import re
import subprocess


def content_failures(decision: str, design: str) -> list[str]:
    """Check fixture-specific concepts; this is not a general prose validator."""
    selected = re.search(r"^Decision:[^\n]+", decision, re.I | re.M)
    choice = selected.group() if selected else ""
    checks = {
        "decision retains accepted choice": all(
            re.search(pattern, choice, re.I)
            for pattern in (r"exponential", r"full jitter", r"bound\w*.*(?:budget|attempt)")
        ) and not bool(re.search(r"\b(?:reject|not|without|no)\b", choice, re.I)),
        "decision retains rationale": all(
            re.search(pattern, decision, re.I) for pattern in (r"transient", r"fail")
        ),
        "decision retains considered alternative": bool(re.search(r"fixed.*interval", decision, re.I)),
        "decision reconciles implementation status": bool(re.search(r"accepted.*implemented", decision, re.I))
        and not bool(re.search(r"accepted[^\n]*not implemented", decision, re.I)),
        "design retains implemented interface": "retry_with_backoff" in design
        and "zero-argument callable" in design
        and bool(re.search(r"^(?:Status:\s*implemented\b|Implemented:)", design, re.I | re.M))
        and bool(re.search(r"(?:three|3).*attempt", design, re.I)),
        "design preserves deferred work as unimplemented": bool(
            re.search(r"Retry-After[^\n]*(?:not implemented|deferred|future)", design, re.I)
        ),
    }
    return [name for name, passed in checks.items() if not passed]


def observe(root: Path) -> dict:
    errors = []
    records = {}
    for key, relative in (
        ("decision", "docs/decisions/0007-retry-budget.md"),
        ("design", "docs/design/retry.md"),
    ):
        path = root / relative
        records[key] = path.read_text() if path.is_file() else ""
    errors.extend(content_failures(**records))
    for folder in ("specs", "plans"):
        old = f"docs/wip/{folder}/retry-backoff.md"
        archived = root / "docs/archive" / folder / "retry-backoff.md"
        original = subprocess.run(
            ["git", "show", f"HEAD:{old}"], cwd=root, capture_output=True, check=True
        ).stdout
        if (root / old).exists() or not archived.is_file() or archived.read_bytes() != original:
            errors.append(f"raw {folder} not archived intact")
    for relative in ("docs/archive/history.md", "docs/wip/held.md"):
        original = subprocess.run(
            ["git", "show", f"HEAD:{relative}"], cwd=root, capture_output=True, check=True
        ).stdout
        if not (root / relative).is_file() or (root / relative).read_bytes() != original:
            errors.append(f"protected file changed: {relative}")
    for relative in ("src/retry.py", "fixtures/retry.ridl"):
        body = (root / relative).read_text()
        if "docs/decisions/0007-retry-budget.md" not in body or "docs/wip/" in body:
            errors.append(f"durable caller reference lost: {relative}")
    decisions = sorted(path.name for path in (root / "docs/decisions").glob("*.md"))
    if decisions != ["0007-retry-budget.md"]:
        errors.append("decision duplicated or lost")
    checks = []
    for command in (["python3", "tests/test_retry.py"], ["just", "doc-path-check"]):
        result = subprocess.run(command, cwd=root, capture_output=True, text=True)
        checks.append({"command": command, "exit_code": result.returncode,
                       "stdout": result.stdout, "stderr": result.stderr})
        if result.returncode:
            errors.append(f"check failed: {' '.join(command)}")
    return {"passed": not errors, "errors": errors, "records": records, "checks": checks}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    report = observe(parser.parse_args().directory.resolve())
    print(json.dumps(report, indent=2))
    raise SystemExit(0 if report["passed"] else 1)
