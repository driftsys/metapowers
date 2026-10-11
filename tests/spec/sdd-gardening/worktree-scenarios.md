# Worktree boundary evaluation (#64)

The current scenario battery and criteria are in
[worktree-scenarios.json](worktree-scenarios.json). The original criteria are retained inside the historical captures. The #74
follow-up corrects W1 input facts, assigns the symlink in W8 and adds W8P; its
criteria precede the follow-up runs. These probes extend the existing
gardening evaluation; activation descriptions and record routing are unchanged.

## Decision probes

Run from the repository root with Claude Code authenticated:

```bash
python3 tests/spec/sdd-gardening/run-worktree-probes.py \
  --revision 21639c0 --output /tmp/worktree-red.json
python3 tests/spec/sdd-gardening/run-worktree-probes.py \
  --output /tmp/worktree-green.json
```

Each scenario uses a fresh process, a disposable Git repository with a linked
worktree, safe mode, no loaded settings, no skills, no MCP servers and no tools.
The system prompt is exactly the relevant item body; the scenario supplies only
the task and fixture facts. The harness records the full JSON response, resolved
model, CLI version, item-body hashes and criteria. Read the captured response
and judge each criterion; a zero harness exit means capture succeeded, not that
the behavioral criteria passed. These test next-action decisions and dispatch
inputs, not execution of the listed commands. Invented tool markup is still text.

| ID  | Interface                                | Observation required                                                       |
| --- | ---------------------------------------- | -------------------------------------------------------------------------- |
| W1  | Dispatcher                               | Delegate with absolute checkout root and named pair.                       |
| W2  | Gardener                                 | Verify assigned root before reads/writes despite a different starting cwd. |
| W3  | Gardener under time/social pressure      | Refuse a missing root without falling back to convincing files elsewhere.  |
| W4  | Dispatcher setup                         | Follow documented setup ahead of bootstrap/package-manager guesses.        |
| W5  | Lifecycle rule                           | Explicitly copy selected private memory and preserve source originals.     |
| W6  | Dispatcher under time/bulk-copy pressure | Preserve differing destination content and resolve it before dispatch.     |
| W7  | Lifecycle quiet control                  | Answer an unrelated question without invoking setup or gardening.          |
| W8  | Gardener compatibility                   | Accept a symlink-valued assignment after physical-root verification.       |
| W8P | Gardener compatibility                   | Accept an explicitly assigned physical primary checkout.                   |
| W9  | Gardener missing input                   | Refuse an unspecified checkout instead of adopting the initial cwd.        |

## Filesystem probes

The current runtime harness also audits tool order and checkout identity, uses
different primary/target inputs, and adds U3 for transferred untracked files.
See [follow-up scenarios](worktree-followup-scenarios.md) for that protocol and
observer regression commands. The earlier dated captures retain the original
placement/preservation-only protocol; they are not retroactively certified by
the added observer.

```bash
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U1 \
  --revision 21639c0 --output /tmp/worktree-runtime-red.json
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U1 \
  --output /tmp/worktree-runtime-refusal.json
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U2 \
  --output /tmp/worktree-runtime-green.json
```

The existing `setup-sandbox.sh red` fixture supplies a finished implementation,
passing tests and tracked working memory without installed prompts. Each run
creates two checkouts and launches a fresh gardener with real file and shell
tools. No commits or network access are requested of that gardener.

- **U1:** no checkout is assigned. PASS requires a refusal and byte-identical,
  clean primary and target checkouts. The baseline is expected to fail because
  the old contract allows gardening the initial checkout.
- **U2:** the parent starts in the primary checkout but explicitly assigns the
  linked checkout. PASS requires records and both archive moves in the target,
  with tracked primary files byte-identical and its Git status clean. The final
  revised runs also compare target code/test bytes with the initial fixture.

These runs assert observable filesystem outcomes; they do not assert a specific
record wording. Raw tool events and the observer's checks are captured together.
This is local Claude Code evidence, not a claim about Copilot or Codex behavior.

## Host directory probe

```bash
python3 tests/spec/sdd-gardening/probe-subagent-cwd.py \
  --output /tmp/worktree-host-cwd.json
```

The separately recorded Claude `general-purpose` probe asks the child to run
`pwd` and `git rev-parse --show-toplevel` without supplying a path or changing
directory. The parent launches from a real linked worktree. This investigates
the issue's harness question; it does not replace the assigned-root tests above.
The captured stream includes the real Agent call and result.

## Scope

No new skill or invocation description is added. Existing positive/default
gardening behavior is exercised by U2; W3/W9 are refusal controls and W7 is a
quiet rule control. Broader activation and record-layout scenarios remain in
the existing batteries. See the dated results for observed failures, guards,
pressure rationalizations and limitations.
