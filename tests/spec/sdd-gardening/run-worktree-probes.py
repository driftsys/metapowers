"""Run isolated decision probes; judge recorded outputs against the scenario criteria.

These are next-action probes, not filesystem or client-conformance tests.
Each fresh Claude process loads only the role content, with tools disabled.
"""

import argparse
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
ROLES = {
    "dispatcher": "skills/sdd-gardening/SKILL.md",
    "gardener": "skills/sdd-gardening/AGENT.md",
    "lifecycle": "skills/sdd-working-memory-lifecycle/RULE.md",
}


def body(text):
    return text.split("---", 2)[2].strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--revision", help="Git revision of the role prompts; default: working tree")
    parser.add_argument("--cases", nargs="+", help="Scenario ids; default: all")
    args = parser.parse_args()
    scenarios = json.loads((HERE / "worktree-scenarios.json").read_text())
    if args.cases:
        unknown = set(args.cases) - {case["id"] for case in scenarios}
        if unknown:
            parser.error(f"unknown scenarios: {sorted(unknown)}")
        scenarios = [case for case in scenarios if case["id"] in args.cases]
    prompts = {}
    for role, path in ROLES.items():
        if args.revision:
            text = subprocess.check_output(["git", "show", f"{args.revision}:{path}"], cwd=ROOT, text=True)
        else:
            text = (ROOT / path).read_text()
        prompts[role] = body(text)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "revision": args.revision or "working-tree",
        "claude_version": subprocess.check_output(["claude", "--version"], text=True).strip(),
        "model": "sonnet",
        "kind": "decision-probes-no-tools",
        "prompt_sha256": {role: hashlib.sha256(text.encode()).hexdigest() for role, text in prompts.items()},
        "runs": [],
    }

    def run(case):
        # A new cwd and process prevent project discovery and session reuse.
        with tempfile.TemporaryDirectory(prefix="gardening-probe-") as directory:
            base = Path(directory).resolve()
            primary, target = base / "project", base / "retry-feature"
            primary.mkdir()
            target_branch = "feat/other-checkout" if case["id"] in ("W8", "W8P") else "feat/retry"
            for operation in (
                ["git", "init", "-q", "--initial-branch=main"],
                ["git", "-c", "user.name=Harness", "-c", "user.email=harness@example.invalid", "commit", "--allow-empty", "-qm", "chore: baseline"],
                ["git", "worktree", "add", "-qb", target_branch, str(target)],
            ):
                subprocess.run(operation, cwd=primary, capture_output=True, check=True)
            if case["id"] in ("W8", "W8P"):
                subprocess.run(["git", "switch", "-qc", "feat/retry"], cwd=primary, capture_output=True, check=True)
            (base / "alias").mkdir()
            (base / "alias/project").symlink_to(primary, target_is_directory=True)
            # Keep the model's real environment consistent with scenario facts.
            case = json.loads(json.dumps(case).replace("/work/", str(base) + "/").replace("/alias/project", str(base / "alias/project")))
            cwd = primary if case["id"] in ("W2", "W3", "W5", "W8", "W9") else target
            command = [
                "claude", "--safe-mode", "--setting-sources", "", "--strict-mcp-config",
                "--disable-slash-commands", "--no-session-persistence", "--tools", "",
                "--model", "sonnet", "--output-format", "json",
                "--system-prompt", prompts[case["role"]], "-p", case["prompt"],
            ]
            result = subprocess.run(command, cwd=cwd, text=True, capture_output=True, timeout=180)
            return {"scenario": case, "exit_code": result.returncode, "stdout": result.stdout, "stderr": result.stderr}

    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        futures = {pool.submit(run, case): case for case in scenarios}
        for future in concurrent.futures.as_completed(futures):
            case = futures[future]
            try:
                entry = future.result()
            except Exception as error:
                entry = {"scenario": case, "harness_error": str(error)}
            report["runs"].append(entry)
            report["runs"].sort(key=lambda entry: entry["scenario"]["id"])
            args.output.write_text(json.dumps(report, indent=2) + "\n")
            print(f"{case['id']}: captured", flush=True)

    failed = any(
        entry.get("harness_error") or entry.get("exit_code") != 0
        or json.loads(entry["stdout"]).get("is_error")
        for entry in report["runs"]
    )
    raise SystemExit(1 if failed else 0)


if __name__ == "__main__":
    main()
