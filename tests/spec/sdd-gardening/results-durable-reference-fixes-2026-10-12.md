# Durable-reference review regressions, 2026-10-12

These checks supplement the [original results](results-durable-references-2026-10-11.md)
and address PR 76 findings F1 and F2 without changing the historical reports.

## RED and GREEN

The new regression runner first failed twice against the reviewed content:
the documented tracked-only scan missed an untracked requirement pointing to
another feature’s WIP, and the content-aware observer did not exist.
After adding `--untracked` and the fixture-specific observer, all four tests pass:

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
missing/failed gates retain their original decision-test coverage. This does not
claim live client activation or universal prose preservation.
