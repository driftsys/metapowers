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
