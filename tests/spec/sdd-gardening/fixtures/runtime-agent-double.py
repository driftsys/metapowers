"""Inject SDK-shaped traces while preserving real harness filesystem outcomes.

Used only to test the observer; this does not evaluate the gardener prompt.
"""

import json
import os
from pathlib import Path
import sys
import subprocess

if "--version" in sys.argv:
    print("observer-test-double")
    raise SystemExit(0)

primary = Path.cwd()
target = Path(sys.argv[sys.argv.index("--add-dir") + 1])
mode = os.environ["GARDENING_TEST_TRACE"]
sequence = 0


def operation(name, arguments, output=""):
    global sequence
    sequence += 1
    identifier = f"test-{sequence}"
    print(json.dumps({"type": "assistant", "message": {"content": [
        {"type": "tool_use", "id": identifier, "name": name, "input": arguments}
    ]}}))
    print(json.dumps({"type": "user", "message": {"content": [
        {"type": "tool_result", "tool_use_id": identifier, "content": output, "is_error": False}
    ]}}))


if mode == "early-refusal-read":
    source = primary / "src/retry.py"
    operation("Read", {"file_path": str(source)}, source.read_text())
    print(json.dumps({"type": "result", "is_error": False, "result": "status: refused"}))
    raise SystemExit(0)

if mode != "skip-verification":
    operation("Bash", {"command": f"git -C {target} rev-parse --show-toplevel"}, str(target.resolve()))
    operation("Bash", {"command": f"git -C {target} branch --show-current"}, "feat/gardening-probe")
for relative in ("docs/wip/specs/retry-backoff.md", "docs/wip/plans/retry-backoff.md", "src/retry.py", "tests/test_retry.py"):
    source = (primary if mode == "wrong-source" else target) / relative
    operation("Read", {"file_path": str(source)}, source.read_text())
if mode in ("archive-conflict", "stage-conflict", "vague-conflict", "missing-conflict-path", "missing-conflict-reason", "partial-spec-first"):
    if mode == "stage-conflict":
        blob = subprocess.check_output(["git", "-C", str(target), "hash-object", "-w", "docs/wip/specs/retry-backoff.md"], text=True).strip()
        subprocess.run(["git", "-C", str(target), "update-index", "--cacheinfo", "100644", blob, "docs/archive/specs/retry-backoff.md"], check=True)
    if mode == "partial-spec-first":
        source = target / "docs/wip/specs/retry-backoff.md"
        destination = target / "docs/archive/specs/retry-backoff.md"
        destination.parent.mkdir(parents=True, exist_ok=True)
        source.rename(destination)
        operation("Bash", {"command": f"mv {source} {destination}"})
        subprocess.run(["git", "-C", str(target), "add", "--", "docs/archive/specs/retry-backoff.md"], check=True)
        operation("Bash", {"command": f"git -C {target} add -- docs/archive/specs/retry-backoff.md"})
    relative = "docs/archive/specs/retry-backoff.md"
    if not (target / relative).exists() or mode == "partial-spec-first":
        relative = "docs/archive/plans/retry-backoff.md"
    archive = target / relative
    operation("Read", {"file_path": str(archive)}, archive.read_text())
    response = f"status: refused; archive conflict: {relative} already exists"
    if mode == "vague-conflict":
        response = response.replace("status: refused", "status: done")
    elif mode == "missing-conflict-path":
        response = response.replace("docs/archive/specs/retry-backoff.md", "destination")
    elif mode == "missing-conflict-reason":
        response = response.replace(" already exists", "")
    print(json.dumps({"type": "result", "is_error": False, "result": response}))
    raise SystemExit(0)

record = target / "docs/design/retry.md"
record.parent.mkdir(parents=True, exist_ok=True)
record.write_text("# Retry\n\nThe default budget is five attempts.\n")
operation("Write", {"file_path": str(record), "content": record.read_text()})
for kind in ("specs", "plans"):
    source = target / f"docs/wip/{kind}/retry-backoff.md"
    destination = target / f"docs/archive/{kind}/retry-backoff.md"
    destination.parent.mkdir(parents=True, exist_ok=True)
    source.rename(destination)
    operation("Bash", {"command": f"mv {source} {destination}"})
print(json.dumps({"type": "result", "is_error": False, "result": "status: done; archive conflict" if mode == "overwrite-conflict" else "status: done"}))
