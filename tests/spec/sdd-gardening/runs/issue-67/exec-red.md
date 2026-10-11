```text
status: done
records:
  - created docs/specification/retry-backoff.md
  - edited docs/design/retry.md
  - edited docs/decisions/0007-retry-budget.md (AD-0007)
divergences:
  - Spec R4 requests five attempts; implementation defaults to three total attempts. Durable records describe the implementation and flag the discrepancy for confirmation.
  - README.md imports backoff.retry and says five retries; the implementation exposes src/retry.py:retry_with_backoff and defaults to three total attempts.
  - The jitter annotation accepts one argument while the implementation calls it with two bounds; tests pass but do not verify the sleep schedule or jitter bounds.
  - Archival leaves rationale references in src/retry.py and docs/archive/history.md pointing to the old WIP spec path; these files were left unchanged outside the assigned gardening scope.
offers:
  - CONTRIBUTING.md requires PR descriptions to state a five-attempt default; this policy conflicts with the implemented three-attempt default and needs a human decision.
wip:
  - docs/wip/held.md: disposition unresolved — not this feature's spec/plan; left untouched for the human or producing skill. The branch remains unfinished until this is gardened or debt is accepted with a reason and durable marker.
notes: Archived the assigned originals with git mv into docs/archive/specs/ and docs/archive/plans/; no prior spec/plan archive layout existed. README.md and CONTRIBUTING.md were not edited; no commit or external contact occurred.
commands: Read only the supplied rule.md and agent.md for instructions. In the sandbox, ran git status --short; git diff main...HEAD -- src tests; rg --files docs; cat of the assigned pair, implementation, tests, README.md, and CONTRIBUTING.md; attempted python -m unittest discover -s tests -v (failed: python not found); ran python3 tests/test_retry.py (four PASS, exit 0); git diff main...HEAD --stat (empty); cat of existing design, decision, archive history; git log -2 --oneline (one seed commit). Used a Python script to write the three durable records, mkdir -p for archive directories, git mv for both originals, and git status --short to inspect changes. Finally used Python to save this digest to the requested output path.
```
