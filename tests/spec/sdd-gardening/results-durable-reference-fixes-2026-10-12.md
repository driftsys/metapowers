# Durable-reference review regressions, 2026-10-12

These checks supplement the [original results](results-durable-references-2026-10-11.md)
and address PR 76 findings F1 and F2 without changing the historical reports.

## RED and GREEN

The new regression runner first failed twice against the reviewed content:
the documented tracked-only scan missed an untracked requirement pointing to
another feature’s WIP, and the content-aware observer did not exist.
Those initial runner outputs were not retained. After adding `--untracked` and
the fixture-specific observer, all four tests pass:

```bash
python3 tests/spec/sdd-gardening/test_reference_regressions.py
```

The tests execute the documented scan in a temporary Git repository, mutate
accepted decision/design contents, exercise the filesystem observer against
heading-only records, and confirm the sandbox seeder refuses an existing checkout
without changing its file, HEAD, index, or configuration.

## Executed behavior

Fresh isolated executors received only candidate rule/agent snapshots and the
fixture assignment. They used inherited model settings without overrides; the
runtime does not expose a resolved model version. The dispatcher first resolved
the three seeded lasting citations to the existing decision and introduced an
untracked requirement pointing to unrelated `docs/wip/held.md`.

[Blocked output](runs/issue-67/fix-blocked.txt) reports that caller and refuses
archival despite passing tests and the path gate. The independent
[blocked observer](runs/issue-67/fix-blocked-observer.json) confirms the pair stayed
in WIP, no pair archive appeared, the caller was untracked, and history/held WIP
were unchanged.

The dispatcher then replaced that unrelated citation with a self-contained
proposed requirement, and a fresh executor continued. The
[clean output](runs/issue-67/fix-clean.txt) and
[content-aware report](runs/issue-67/fix-clean-observer.json) record successful
pair archival with raw bytes preserved, one reused decision, retained rationale,
alternative, accepted/implemented status, implemented interface and attempt budget,
and explicit unimplemented Retry-After work. Four retry tests and the path gate pass.
Unrelated held WIP still requires its own disposition; the branch is not declared
finished by this fixture run.

A copied clean sandbox then had only the two durable record bodies replaced
with headings. The [negative control](runs/issue-67/fix-heading-control.json)
fails all six content predicates while its retry tests and path gate still pass.
This distinguishes content preservation from mere path existence.

## Bounds

The observer checks known retry-fixture concepts; it is not a general semantic
validator. The executed probe uses default paths. Custom relative paths and
failed gates retain their original decision-test coverage; absent gates are not separately exercised. This does not
claim live client activation or universal prose preservation.

## Quick-review negative controls

Quick review found that the initial observer accepted reversed decision wording,
an unimplemented design status, and a changed callable interface. Three additional
mutations first failed the regression assertions ([RED output](runs/issue-67/fix-observer-red.txt)).
The observer now checks the selected `Decision:` statement independently from
alternatives, explicit implemented design status, and the zero-argument interface.
All four tests pass with those negative controls ([GREEN output](runs/issue-67/fix-observer-green.txt)).
The fixture-specific wording predicates intentionally do not accept arbitrary prose.

Integration preserves main’s assigned-checkout verification, archive collision
preflight and precise staging behavior. CI runs these reference regressions alongside
the existing worktree observer and mutation suite.

The integration quick review also found that the legacy runtime audit rejected
the newly prescribed Git citation scan. Its bounded command protocol now accepts
that exact scan after successful root/branch verification, and still rejects it
before verification or with an escaping path. [RED](runs/issue-67/fix-runtime-red.txt)
and [GREEN](runs/issue-67/fix-runtime-green.txt) retain the three targeted results.
The execution recipe now supplies the required absolute worktree assignment.
This protocol correction is deterministic coverage, not a new live model execution.

A fresh executor also ran the merged rule/agent in an explicitly assigned checkout
with three lasting WIP callers and an existing archive destination. It verified the
root and branch, ran four retry tests and the path gate, reported all three callers
and the collision, and refused archival. [Actual execution](runs/issue-67/integrated-blocked.txt)
and the [independent observer](runs/issue-67/integrated-blocked-observer.json)
confirm the pair, caller bytes, existing archive and index remained unchanged.
Input hashes identify the merged production instructions. This is a bounded
Codex execution; it does not claim a new Claude runtime probe or paid-model battery.

## Final-pass corrections

The final pass identified two remaining coverage gaps. The content observer now
requires a bounded selected budget and exactly three total attempts. Negative
controls for an unbounded budget, 30 attempts and three retries after the initial
attempt first failed the assertions ([RED](runs/issue-67/budget-red.txt)); the
corrected observer passes all four reference tests ([GREEN](runs/issue-67/budget-green.txt)).
An additional scan-option test rejects external pattern files and unsupported
options; it kills the [broadened grep mutation](runs/issue-67/grep-boundary-mutant.txt).

Runtime case U5 occupies only the plan archive, leaving the spec destination free.
The new positive control requires both source byte sequences, the existing plan
archive and index to remain unchanged, with no new spec archive. A sequential
move-and-stage-spec-before-checking-plan double is rejected. The two tests failed
before U5 existed ([RED](runs/issue-67/plan-harness-red.txt)) and pass with the
extended fixture and observer ([GREEN](runs/issue-67/plan-harness-green.txt)).
These doubles validate observer outcomes, not model compliance.

A separate [fresh gardener execution](runs/issue-67/plan-collision.txt) exercised
the same plan-only conflict with current merged instructions and no lasting WIP
citations. It verified the assigned root/branch, passed four retry tests and the
path gate, then refused the entire pair before moving or staging. The
[independent byte/index observer](runs/issue-67/plan-collision-observer.json)
confirms preservation and absence of a spec archive.

The historical upstream verification statement is now explicitly an author report
with no retained command output. Current checks do not retroactively establish
those historical runs. No further numbered review pass is performed over these
final-pass corrections.
