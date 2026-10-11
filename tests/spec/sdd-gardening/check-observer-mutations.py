"""Run targeted guard mutations in memory; each must fail the observer suite."""

import argparse
import subprocess
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import unittest

base = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("observer_tests", base / "worktree-observer.test.py")
tests = importlib.util.module_from_spec(spec)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--tests-revision", help="Use historical test definitions as a baseline")
parser.add_argument("--expect-survivors", action="store_true")
args = parser.parse_args()
if args.tests_revision:
    content = subprocess.check_output(["git", "-C", str(base.parents[2]), "show", f"{args.tests_revision}:tests/spec/sdd-gardening/worktree-observer.test.py"], text=True)
    exec(compile(content, str(base / "worktree-observer.test.py"), "exec"), tests.__dict__)
else:
    spec.loader.exec_module(tests)
source = (base / "run-worktree-runtime.py").read_text()
mutations = {
    "relative-read": ('if absolute and not path.is_absolute():', 'if False:'),
    "wrong-git-root": ('if not Path(words[2]).is_absolute() or Path(words[2]).resolve() != root:', 'if False:'),
    "unsupported-shell": ('raise ValueError("unsupported shell command")', 'return "other"'),
    "symlink-escape": ('return (path if path.is_absolute() else root / path).resolve().is_relative_to(root)', 'return (path if path.is_absolute() else root / path).is_relative_to(root) or (path if path.is_absolute() else root / path).resolve().is_relative_to(root)'),
    "early-write": ('if kind not in ("root", "branch", "branch-status") and not (verified and branch_verified):', 'if kind not in ("root", "branch", "branch-status") and name != "Write" and not (verified and branch_verified):'),
    "early-root-request": ('kind = shell(arguments.get("command", ""))', 'kind = shell(arguments.get("command", ""))\n                        if kind == "root":\n                            verified = True'),
    "failed-root-result": ('if not isinstance(content, str) or item.get("is_error"):', 'if not isinstance(content, str):'),
    "branch-order": ('if kind not in ("root", "branch", "branch-status") and not (verified and branch_verified):', 'if kind not in ("root", "branch", "branch-status") and not verified:'),
    "pending-result": ('if pending:\n        errors.append("tool request has no result")', 'if False:\n        errors.append("tool request has no result")'),
}
original = tests.runtime.audit_events
report = {}
for name, (old, new) in mutations.items():
    assert source.count(old) == 1, (name, source.count(old))
    namespace = {"__file__": str(base / "run-worktree-runtime.py"), "__name__": "observer_mutant"}
    exec(compile(source.replace(old, new), namespace["__file__"], "exec"), namespace)
    tests.runtime.audit_events = namespace["audit_events"]
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(tests.ObserverTests)
    with contextlib.redirect_stderr(io.StringIO()):
        result = unittest.TextTestRunner(stream=io.StringIO()).run(suite)
    report[name] = {"tests": result.testsRun, "failures": len(result.failures), "errors": len(result.errors),
                    "caught": bool(result.failures) and not result.errors,
                    "failed_tests": [str(test) for test, _ in result.failures]}
tests.runtime.audit_events = original
print(json.dumps(report, indent=2))
passed = any(not item["caught"] for item in report.values()) if args.expect_survivors else all(item["caught"] for item in report.values())
raise SystemExit(0 if passed else 1)
