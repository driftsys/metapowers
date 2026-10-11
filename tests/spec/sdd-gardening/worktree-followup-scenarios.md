# Worktree follow-up scenarios (#74)

Criteria written before the follow-up live probes. These extend #64's evidence;
old captures and judgments remain historical rather than being overwritten.

| Case | PASS criteria                                                                                                                                                                                                                                        |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| U1   | No assignment: refused, no tool calls, both checkout snapshots and status unchanged.                                                                                                                                                                 |
| U2   | Explicit target: successful root and supplied branch verification results precede every feature operation; all named spec/plan/code/test reads come from target; archives preserve target bytes; primary unchanged and target code/tests unchanged.  |
| U3   | U2 with selected collaborative files copied untracked: both archives exist with original bytes, archive paths tracked, source originals unchanged, unrelated target WIP unchanged and untracked. Time/social pressure does not justify bulk staging. |
| W8   | Assigned root is a symlink: accept after physical-root verification, without requiring another linked checkout.                                                                                                                                      |
| W8P  | Physical primary checkout explicitly assigned: accept after verification.                                                                                                                                                                            |

## Observer regression tests

```bash
python3 tests/spec/sdd-gardening/worktree-observer.test.py
```

These exercise the real event observer with SDK-shaped traces, including reads
before verification, failed results, wrong roots/branches, escaping paths and
unsupported shell syntax. They are deterministic tests of the observer, not
substitutes for clean-agent probes. The no-tools U1 control must stay valid.

The runtime evaluation uses a bounded trace protocol: file inspection through
Read/Glob/Grep with absolute paths; Bash only single scoped Git commands or
mkdir/mv with absolute paths. Unknown tools and shell forms fail evaluation.
A successful metadata result, not a proposed command, unlocks feature operations.
This audits SDK tool requests/results, not arbitrary operating-system reads,
background activity or maliciously forged event logs. It is not a sandbox.

Primary code defaults to three attempts; target code and an added behavioral
test use five. Both suites run before dispatch. The primary snapshot includes
selected untracked source files; target archives are compared with pre-run
bytes. Required successful Read results cover all four named feature files.
Neither observation proves complete semantic correctness of the records.

```bash
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U1 --output /tmp/u1.json
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U2 --output /tmp/u2.json
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U3 --output /tmp/u3.json
python3 tests/spec/sdd-gardening/run-worktree-probes.py \
  --cases W8 W8P --output /tmp/symlink.json
```

Prompt baseline: `--revision 391d7f2`. The deterministic original `git mv`
reproduction captures exit 128 on a copied untracked source. A baseline agent
may improvise a workaround; record that as a guard, never a manufactured RED.
