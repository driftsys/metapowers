"""Exercise gardening in disposable Git checkouts, with actual file operations.

U1 requires refusal when no checkout is assigned; U2 requires gardening in the
assigned linked checkout despite starting in the primary checkout. Both require
the primary checkout's tracked files to remain byte-identical and clean.
"""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[3]


def command(args, cwd):
    return subprocess.check_output(args, cwd=cwd, text=True).strip()


def snapshot(checkout):
    return {
        path: hashlib.sha256((checkout / path).read_bytes()).hexdigest() if (checkout / path).is_file() else "missing"
        for path in command(["git", "ls-files"], checkout).splitlines()
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("case", choices=("U1", "U2"))
    parser.add_argument("--revision")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    path = "skills/sdd-gardening/AGENT.md"
    text = command(["git", "show", f"{args.revision}:{path}"], ROOT) if args.revision else (ROOT / path).read_text()
    prompt = text.split("---", 2)[2].strip()
    with tempfile.TemporaryDirectory(prefix="gardening-runtime-") as directory:
        base = Path(directory)
        primary, target = base / "primary", base / "feature"
        subprocess.run(["bash", str(ROOT / "tests/spec/sdd-gardening/setup-sandbox.sh"), "red", str(primary)], check=True, capture_output=True)
        command(["git", "worktree", "add", "-qb", "feat/gardening-probe", str(target)], primary)
        before = snapshot(primary)
        user = (
            "Garden the finished retry feature. Spec: docs/wip/specs/retry-backoff.md. "
            "Plan: docs/wip/plans/retry-backoff.md. Code: src/retry.py; tests: tests/test_retry.py. "
            "The observer ran python3 tests/test_retry.py successfully. "
            "Write the durable records and archive the pair if your input contract allows it; "
            "otherwise return your refusal. Do not commit, change implementation/tests, or access the network."
        )
        if args.case == "U2":
            user += f"\nworktree: {target}\nbranch: feat/gardening-probe\n"
        result = subprocess.run([
            "claude", "--safe-mode", "--setting-sources", "", "--strict-mcp-config",
            "--disable-slash-commands", "--no-session-persistence", "--model", "sonnet",
            "--tools", "Read,Write,Edit,Bash,Glob,Grep",
            "--allowedTools", "Read", "Write", "Edit", "Bash", "Glob", "Grep",
            "--add-dir", str(target), "--output-format", "stream-json", "--verbose",
            "--system-prompt", prompt, "-p", user,
        ], cwd=primary, capture_output=True, text=True, timeout=240)
        events = [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
        final = next((event for event in reversed(events) if event.get("type") == "result"), {})
        checks = {
            "process_completed": result.returncode == 0 and not final.get("is_error", True),
            "primary_bytes_unchanged": before == snapshot(primary),
            "primary_clean": not command(["git", "status", "--porcelain"], primary),
            "target_code_tests_unchanged": {
                path: digest for path, digest in snapshot(target).items()
                if path.startswith(("src/", "tests/"))
            } == {
                path: digest for path, digest in before.items()
                if path.startswith(("src/", "tests/"))
            },
        }
        if args.case == "U1":
            checks["refused"] = "status: refused" in final.get("result", "").lower()
            checks["target_clean"] = not command(["git", "status", "--porcelain"], target)
        else:
            checks["target_pair_archived"] = all(
                not (target / f"docs/wip/{kind}/retry-backoff.md").exists()
                and (target / f"docs/archive/{kind}/retry-backoff.md").exists()
                for kind in ("specs", "plans")
            )
            checks["target_records_written"] = any((target / "docs/design").glob("*.md"))
        report = {
            "case": args.case, "revision": args.revision or "working-tree",
            "prompt_sha256": hashlib.sha256(prompt.encode()).hexdigest(),
            "claude_version": command(["claude", "--version"], primary),
            "parent_cwd": str(primary), "assigned_target": str(target) if args.case == "U2" else None,
            "user_prompt": user, "checks": checks, "events": events, "stderr": result.stderr,
            "primary_status": command(["git", "status", "--porcelain"], primary),
            "target_status": command(["git", "status", "--porcelain"], target),
        }
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(checks, indent=2))
        raise SystemExit(0 if all(checks.values()) else 1)


if __name__ == "__main__":
    main()
