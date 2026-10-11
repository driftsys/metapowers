"""Regression checks for the issue-67 citation command and execution observer."""

import importlib.util
import json
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


class ReferenceRegressions(unittest.TestCase):
    def seed(self, root):
        subprocess.run(["python3", str(HERE / "setup-reference-sandbox.py"), str(root)],
                       check=True, capture_output=True)

    def test_documented_scan_includes_untracked_caller_to_unrelated_wip(self):
        instructions = (ROOT / "skills/sdd-gardening/AGENT.md").read_text()
        command = re.search(r"`(git grep[^`]+)`", instructions).group(1)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "tracked.md").write_text("No citations.\n")
            subprocess.run(["git", "add", "."], cwd=root, check=True)
            (root / "new-requirement.md").write_text(
                "Rationale: docs/wip/specs/other-feature.md\n"
            )
            result = subprocess.run(
                shlex.split(command), cwd=root, capture_output=True, text=True
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("new-requirement.md", result.stdout)
            self.assertIn("docs/wip/specs/other-feature.md", result.stdout)

    def test_observer_checks_content_and_rejects_each_semantic_loss(self):
        observer = HERE / "check-reference-sandbox.py"
        self.assertTrue(observer.is_file(), "Missing content-aware observer")
        spec = importlib.util.spec_from_file_location("reference_observer", observer)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        decision = (
            "# Bounded retries\nAccepted; implemented.\n"
            "Context: transient failures can overload upstream services.\n"
            "Options: fixed intervals; no jitter.\n"
            "Decision: exponential backoff with full jitter and a bounded budget.\n"
        )
        design = (
            "# Retry design\nImplemented: retry_with_backoff wraps a zero-argument callable with three total attempts.\n"
            "Status: deferred; Retry-After handling is not implemented.\n"
        )
        self.assertEqual(module.content_failures(decision, design), [])
        for name, changed_decision, changed_design in (
            ("reversed choice", decision.replace("Decision: exponential backoff with full jitter and a bounded budget.", "Decision: fixed intervals with no jitter and a bounded budget.\nRejected: exponential backoff with full jitter."), design),
            ("rejected choice", decision.replace("Decision: exponential", "Decision: reject exponential"), design),
            ("unimplemented design", decision, design.replace("Implemented:", "Status: proposed; not implemented:")),
            ("changed interface", decision, design.replace("zero-argument", "two-argument")),
            ("decision stub", "# Bounded retries\n", design),
            ("design stub", decision, "# Retry design\n"),
            ("lost alternatives", decision.replace("Options: fixed intervals; no jitter.\n", ""), design),
            ("lost rationale", decision.replace("Context: transient failures can overload upstream services.\n", ""), design),
            ("lost deferred status", decision, design.replace("Status: deferred; Retry-After handling is not implemented.\n", "")),
            ("wrong implementation status", decision.replace("Accepted; implemented", "Accepted; not implemented"), design),
        ):
            with self.subTest(name=name):
                self.assertTrue(module.content_failures(changed_decision, changed_design))

    def test_filesystem_observer_rejects_heading_only_records(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "sandbox"
            self.seed(root)
            decision = root / "docs/decisions/0007-retry-budget.md"
            decision.write_text(decision.read_text().replace("not implemented", "implemented"))
            design = root / "docs/design/retry.md"
            design.write_text(
                "# Retry design\nImplemented: retry_with_backoff wraps a zero-argument callable with three total attempts.\n"
                "Retry-After handling is not implemented.\n"
            )
            for relative in ("src/retry.py", "fixtures/retry.ridl"):
                path = root / relative
                path.write_text(path.read_text().replace(
                    "docs/wip/specs/retry-backoff.md", "docs/decisions/0007-retry-budget.md"
                ))
            for folder in ("specs", "plans"):
                (root / "docs/archive" / folder).mkdir()
                subprocess.run(["git", "mv", f"docs/wip/{folder}/retry-backoff.md",
                                f"docs/archive/{folder}/retry-backoff.md"], cwd=root, check=True)
            command = ["python3", str(HERE / "check-reference-sandbox.py"), str(root)]
            clean = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(clean.returncode, 0, clean.stdout + clean.stderr)
            decision.write_text("# Bounded retries\n")
            design.write_text("# Retry design\n")
            broken = subprocess.run(command, capture_output=True, text=True)
            self.assertEqual(broken.returncode, 1, broken.stdout + broken.stderr)
            errors = json.loads(broken.stdout)["errors"]
            self.assertIn("decision retains accepted choice", errors)
            self.assertIn("design retains implemented interface", errors)

    def test_seeder_refuses_existing_repository_without_mutation(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / "sandbox"
            self.seed(root)
            (root / "src/retry.py").write_text("Pending local changes.\n")
            subprocess.run(["git", "add", "src/retry.py"], cwd=root, check=True)
            protected = ("src/retry.py", ".git/HEAD", ".git/index", ".git/config")
            before = {path: (root / path).read_bytes() for path in protected}
            result = subprocess.run(
                ["python3", str(HERE / "setup-reference-sandbox.py"), str(root)],
                capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("FileExistsError", result.stderr)
            self.assertEqual(before, {path: (root / path).read_bytes() for path in protected})


if __name__ == "__main__":
    unittest.main()
