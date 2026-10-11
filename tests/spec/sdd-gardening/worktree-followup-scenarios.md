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

## Review regression cases

U4 copies the selected pair untracked and commits a different existing archive
at the spec destination. PASS requires a reported conflict, unchanged existing
archive and both selected sources, no new plan archive, unchanged index,
unrelated WIP left untracked, and unchanged primary checkout/code/tests. The
fixture is not revealed beyond the assigned feature paths and the conflict.
This tests archival refusal, not complete semantic quality of durable records.

```bash
python3 tests/spec/sdd-gardening/run-worktree-runtime.py U4 --output /tmp/u4.json
python3 tests/spec/sdd-gardening/check-observer-mutations.py
```

The mutation command changes nine observer guards in memory. Every mutant must
cause assertion failures without test errors. Negative traces now include
matching results and assert their intended rejection reason. Separate tests pin
root-result ordering, failed verification, branch-result ordering, and an
otherwise valid trace with an unanswered read. Two fake-agent integration cases
pin the U4 oracle: preservation passes; overwriting and merely mentioning a
conflict fails. Fake-agent outcomes do not evaluate the gardener prompt.
