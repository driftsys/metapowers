"""Record the initial cwd of a real Claude subagent in a disposable worktree."""

import argparse
import json
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="gardening-host-cwd-") as directory:
        base = Path(directory)
        primary, target = base / "primary", base / "feature"
        primary.mkdir()
        for command in (
            ["git", "init", "-q", "--initial-branch=main"],
            ["git", "-c", "user.name=Harness", "-c", "user.email=harness@example.invalid", "commit", "--allow-empty", "-qm", "chore: baseline"],
            ["git", "worktree", "add", "-qb", "feat/probe", str(target)],
        ):
            subprocess.run(command, cwd=primary, check=True, capture_output=True)
        result = subprocess.run([
            "claude", "--safe-mode", "--setting-sources", "", "--strict-mcp-config",
            "--disable-slash-commands", "--no-session-persistence", "--model", "sonnet",
            "--tools", "Bash,Agent", "--allowedTools", "Bash(pwd)", "Bash(git rev-parse *)", "Agent",
            "--output-format", "stream-json", "--verbose",
            "--system-prompt", "Use the general-purpose subagent to report its initial directory. Instruct it to run pwd and git rev-parse --show-toplevel using Bash without cd or an explicit workdir, then return the two paths. Do not run shell commands yourself or tell it a directory. Return its findings.",
            "-p", "Launch the general-purpose directory probe now.",
        ], cwd=target, capture_output=True, text=True, timeout=180)
        report = {
            "primary": str(primary), "parent_cwd": str(target),
            "claude_version": subprocess.check_output(["claude", "--version"], text=True).strip(),
            "exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr,
        }
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n")
        for line in result.stdout.splitlines():
            item = json.loads(line)
            if item.get("type") == "result":
                print(item.get("result"))
                print("subagent_stats:", item.get("subagent_stats"))
        raise SystemExit(result.returncode)


if __name__ == "__main__":
    main()
