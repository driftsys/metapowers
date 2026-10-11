"""Pin the event observer: removed order/path checks must fail these cases."""

import importlib.util
from pathlib import Path
import tempfile
import os
import subprocess
import sys
import json
import shlex
import unittest

SPEC = importlib.util.spec_from_file_location("runtime", Path(__file__).with_name("run-worktree-runtime.py"))
runtime = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runtime)


def call(identifier, name, **arguments):
    return {"type": "assistant", "message": {"content": [
        {"type": "tool_use", "id": identifier, "name": name, "input": arguments}
    ]}}


def result(identifier, text, error=False):
    return {"type": "user", "message": {"content": [
        {"type": "tool_result", "tool_use_id": identifier, "content": text, "is_error": error}
    ]}}


class ObserverTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.base = Path(self.directory.name).resolve()
        self.root = self.base / "feature"
        self.root.mkdir()
        self.primary = self.base / "primary"
        self.primary.mkdir()
        self.alias = self.base / "alias"
        self.alias.symlink_to(self.root, target_is_directory=True)
        self.file = self.root / "src/retry.py"
        self.verified = [
            call("root", "Bash", command=f"git -C {self.root} rev-parse --show-toplevel"),
            result("root", str(self.root)),
            call("branch", "Bash", command=f"git -C {self.root} branch --show-current"),
            result("branch", "feat/probe"),
        ]

    def audit(self, events, assigned=True):
        self.assertTrue(hasattr(runtime, "audit_events"), "Runtime observer lacks event order/path assertions")
        return runtime.audit_events(events, self.root if assigned else None, "feat/probe")

    def assert_rejected(self, events, reason):
        audit = self.audit(events)
        self.assertFalse(audit["valid"], audit)
        self.assertTrue(any(reason in error for error in audit["errors"]), audit)
        self.assertNotIn("tool request has no result", audit["errors"], audit)

    def test_accepts_successful_verification_before_assigned_read(self):
        audit = self.audit(self.verified + [call("read", "Read", file_path=str(self.file)), result("read", "target")])
        self.assertTrue(audit["valid"], audit)
        self.assertIn(str(self.file), audit["reads"])

    def test_missing_assignment_rejects_read_then_refusal(self):
        self.assertFalse(self.audit([call("r", "Read", file_path=str(self.primary / "src/retry.py")), result("r", "primary")], False)["valid"])

    def test_missing_assignment_accepts_no_tools(self):
        self.assertTrue(self.audit([], False)["valid"])

    def test_read_before_verification_fails_even_if_verified_later(self):
        self.assertFalse(self.audit([call("r", "Read", file_path=str(self.file)), result("r", "target")] + self.verified)["valid"])

    def test_read_before_verification_result_fails(self):
        self.assert_rejected([self.verified[2], self.verified[3], self.verified[0], call("r", "Read", file_path=str(self.file)), result("r", "target"), self.verified[1]], "feature operation before")

    def test_wrong_checkout_read_fails_after_valid_verification(self):
        self.assertFalse(self.audit(self.verified + [call("r", "Read", file_path=str(self.primary / "src/retry.py")), result("r", "primary")])["valid"])

    def test_failed_verification_cannot_unlock_feature_reads(self):
        events = [self.verified[0], result("root", str(self.root), error=True)] + self.verified[2:]
        audit = self.audit(events + [call("r", "Read", file_path=str(self.file)), result("r", "target")])
        self.assertFalse(audit["root_verified"], audit)
        self.assertFalse(audit["valid"], audit)
        self.assertIn("verification command failed or unsupported result", audit["errors"])
        self.assertNotIn("tool request has no result", audit["errors"])

    def test_wrong_verification_output_fails(self):
        self.assertFalse(self.audit([self.verified[0], result("root", str(self.primary))] + self.verified[2:])["valid"])

    def test_branch_mismatch_fails(self):
        self.assertFalse(self.audit(self.verified[:3] + [result("branch", "main")])["valid"])

    def test_branch_status_result_is_accepted(self):
        events = self.verified[:2] + [call("b", "Bash", command=f"git -C {self.root} status --short --branch"), result("b", "## feat/probe\n?? docs/wip/retry.md")]
        self.assertTrue(self.audit(events)["valid"])

    def test_branch_status_with_wrong_branch_is_rejected(self):
        events = self.verified[:2] + [call("b", "Bash", command=f"git -C {self.root} status --short --branch"), result("b", "## main")]
        self.assertFalse(self.audit(events)["valid"])

    def test_empty_branch_status_result_fails_without_crashing(self):
        events = self.verified[:2] + [call("b", "Bash", command=f"git -C {self.root} status --short --branch"), result("b", "")]
        self.assertFalse(self.audit(events)["valid"])

    def test_parallel_metadata_checks_finish_before_reads(self):
        events = [self.verified[0], self.verified[2], self.verified[1], self.verified[3], call("r", "Read", file_path=str(self.file)), result("r", "target")]
        self.assertTrue(self.audit(events)["valid"])

    def test_completed_read_before_branch_result_is_rejected(self):
        self.assert_rejected(self.verified[:3] + [call("r", "Read", file_path=str(self.file)), result("r", "target"), self.verified[3]], "feature operation before")

    def test_unanswered_feature_read_is_rejected(self):
        audit = self.audit(self.verified + [call("r", "Read", file_path=str(self.file))])
        self.assertEqual(audit["errors"], ["tool request has no result"])
        self.assertFalse(audit["valid"])

    def test_tracking_check_with_both_option_separators_is_accepted(self):
        events = self.verified + [call("ls", "Bash", command=f"git -C {self.root} ls-files --error-unmatch -- docs/wip/retry.md"), result("ls", "docs/wip/retry.md")]
        self.assertTrue(self.audit(events)["valid"])

    def test_ignore_check_of_named_file_is_accepted(self):
        events = self.verified + [call("ignore", "Bash", command=f"git -C {self.root} check-ignore docs/wip/retry.md"), result("ignore", "", error=True)]
        self.assertTrue(self.audit(events)["valid"])

    def test_branch_status_with_upstream_is_accepted(self):
        events = self.verified[:2] + [call("b", "Bash", command=f"git -C {self.root} status --short --branch"), result("b", "## feat/probe...main [ahead 1]\n?? docs/")]
        self.assertTrue(self.audit(events)["valid"])

    def test_wrong_branch_tracking_expected_branch_is_rejected(self):
        events = self.verified[:2] + [call("b", "Bash", command=f"git -C {self.root} status --short --branch"), result("b", "## main...feat/probe")]
        self.assertFalse(self.audit(events)["valid"])

    def test_unanswered_verification_is_not_success(self):
        self.assertFalse(self.audit([self.verified[0]])["valid"])

    def test_compound_shell_cannot_hide_wrong_checkout_read(self):
        event = call("shell", "Bash", command=f"git -C {self.root} status --short && cat {self.primary}/src/retry.py")
        self.assert_rejected(self.verified + [event, result("shell", "output")], "unsupported shell")

    def test_unsupported_shell_reader_fails_closed(self):
        event = call("shell", "Bash", command=f"python3 -c 'print(open(\"{self.primary}/src/retry.py\").read())'")
        self.assert_rejected(self.verified + [event, result("shell", "output")], "unsupported shell")

    def test_relative_read_cannot_use_initial_cwd(self):
        self.assert_rejected(self.verified + [call("r", "Read", file_path="src/retry.py"), result("r", "output")], "outside assigned root")

    def test_escaping_symlink_read_fails(self):
        (self.root / "outside").symlink_to(self.primary, target_is_directory=True)
        self.assert_rejected(self.verified + [call("r", "Read", file_path=str(self.root / "outside/src/retry.py")), result("r", "output")], "outside assigned root")

    def test_equivalent_symlink_read_is_accepted(self):
        self.assertTrue(self.audit(self.verified + [call("r", "Read", file_path=str(self.alias / "src/retry.py")), result("r", "target")])["valid"])

    def test_wrong_root_git_command_fails(self):
        self.assert_rejected(self.verified + [call("s", "Bash", command=f"git -C {self.primary} status --short"), result("s", "output")], "Git command uses another checkout")

    def test_unsupported_git_external_diff_fails_closed(self):
        self.assert_rejected(self.verified + [call("s", "Bash", command=f"git -C {self.root} diff --no-index a b"), result("s", "output")], "unsupported shell command")

    def test_glob_without_explicit_root_fails(self):
        self.assert_rejected(self.verified + [call("g", "Glob", pattern="**/*.md"), result("g", "output")], "outside assigned root")

    def test_write_before_verification_fails(self):
        self.assert_rejected([call("w", "Write", file_path=str(self.root / "docs/design/retry.md"), content="record"), result("w", "written")] + self.verified, "feature operation before")


class RuntimeIntegrationTests(unittest.TestCase):
    def run_trace(self, mode, case="U2"):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            executable = base / "claude"
            double = Path(__file__).with_name("fixtures") / "runtime-agent-double.py"
            executable.write_text(f"#!/bin/sh\nexec {shlex.quote(sys.executable)} {shlex.quote(str(double.resolve()))} \"$@\"\n")
            executable.chmod(0o755)
            output = base / "report.json"
            result = subprocess.run([
                sys.executable, str(Path(__file__).with_name("run-worktree-runtime.py")),
                case, "--output", str(output),
            ], capture_output=True, text=True, env={**os.environ,
                "PATH": str(base) + os.pathsep + os.environ["PATH"],
                "GARDENING_TEST_TRACE": mode, "PYTHONDONTWRITEBYTECODE": "1"})
            self.assertTrue(output.exists(), result.stdout + result.stderr)
            return result.returncode, json.loads(output.read_text())

    def test_harness_accepts_verified_target_reads_and_correct_writes(self):
        code, report = self.run_trace("valid")
        self.assertEqual(code, 0, report["checks"])

    def test_harness_rejects_wrong_reads_despite_correct_target_writes(self):
        code, report = self.run_trace("wrong-source")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["event_audit_passed"])
        self.assertTrue(report["checks"]["target_archive_bytes_preserved"])
        self.assertTrue(report["checks"]["primary_bytes_unchanged"])

    def test_harness_rejects_reads_before_refusal_despite_clean_checkouts(self):
        code, report = self.run_trace("early-refusal-read", "U1")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["event_audit_passed"])
        self.assertTrue(report["checks"]["refused"])
        self.assertTrue(report["checks"]["target_clean"])

    def test_collision_harness_accepts_preserved_pair_and_conflict(self):
        code, report = self.run_trace("archive-conflict", "U4")
        self.assertEqual(code, 0, report["checks"])

    def test_collision_harness_rejects_overwrite_even_when_conflict_reported(self):
        code, report = self.run_trace("overwrite-conflict", "U4")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["existing_archive_preserved"])
        self.assertFalse(report["checks"]["selected_pair_preserved"])

    def test_collision_harness_rejects_staging_without_moves(self):
        code, report = self.run_trace("stage-conflict", "U4")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["index_unchanged"])
        self.assertTrue(report["checks"]["existing_archive_preserved"])
        self.assertTrue(report["checks"]["selected_pair_preserved"])

    def test_collision_harness_requires_refusal_path_and_reason(self):
        code, report = self.run_trace("vague-conflict", "U4")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["archive_conflict_reported"])
        self.assertTrue(report["checks"]["index_unchanged"])

    def test_harness_rejects_skipped_verification_despite_correct_writes(self):
        code, report = self.run_trace("skip-verification")
        self.assertEqual(code, 1)
        self.assertFalse(report["checks"]["event_audit_passed"])
        self.assertTrue(report["checks"]["target_pair_archived"])


if __name__ == "__main__":
    unittest.main()
