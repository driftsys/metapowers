"""Seed a disposable repository for the issue-67 gardening execution probe."""

from pathlib import Path
import argparse
import shutil
import subprocess


def seed(destination: Path) -> None:
    fixture = Path(__file__).parent / "fixtures" / "sandbox"
    # copytree refuses an existing destination; never reset someone else's work.
    shutil.copytree(fixture, destination)
    for directory in (
        "docs/design", "docs/specification", "docs/decisions",
        "docs/archive", "fixtures", "tools",
    ):
        (destination / directory).mkdir(parents=True, exist_ok=True)
    files = {
        "src/retry.py": (
            "# Rationale: docs/wip/specs/retry-backoff.md\n"
            + (destination / "src/retry.py").read_text()
        ),
        "fixtures/retry.ridl": "# Rationale: docs/wip/specs/retry-backoff.md\n",
        "docs/design/retry.md": (
            "# Retry design\n\nStatus: proposed; not implemented.\n\n"
            "Rationale: `docs/wip/specs/retry-backoff.md`.\n"
            "\nInterface: retry_with_backoff wraps a zero-argument callable.\n"
            "\n## Deferred work\n\nRetry-After handling is not implemented.\n"
        ),
        "docs/decisions/0007-retry-budget.md": (
            "# AD-0007: Bounded retries\n\nAccepted; not implemented.\n\n"
            "Context: upstream requests can fail transiently.\n"
            "Options: fixed intervals or exponential backoff; no jitter or full jitter.\n"
            "Decision: exponential backoff with full jitter and a bounded attempt budget.\n"
        ),
        "docs/archive/history.md": (
            "# History\n\nSee docs/wip/specs/retry-backoff.md.\n"
        ),
        "docs/wip/held.md": (
            "# Held work\n\nSee docs/wip/specs/retry-backoff.md.\n"
        ),
        "justfile": "doc-path-check:\n    python3 tools/doc_path_check.py\n",
        # A narrow fixture gate, not a general-purpose path extractor.
        "tools/doc_path_check.py": (
            "from pathlib import Path\n"
            'assert Path("docs/decisions/0007-retry-budget.md").is_file()\n'
            'print("doc-path-check: durable decision exists")\n'
        ),
    }
    for name, body in files.items():
        (destination / name).write_text(body)
    commands = (
        ("git", "init", "-q", "-b", "main"),
        ("git", "config", "user.name", "Evaluation"),
        ("git", "config", "user.email", "eval@example.invalid"),
        ("git", "add", "."),
        ("git", "commit", "-qm", "test: seed gardening evaluation"),
        ("git", "switch", "-qc", "feat/retry"),
    )
    for command in commands:
        subprocess.run(command, cwd=destination, check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    seed(parser.parse_args().destination)
