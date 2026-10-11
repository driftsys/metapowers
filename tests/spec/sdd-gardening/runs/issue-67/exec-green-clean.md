```text
status: done
records:
  - retained existing reconciliation in docs/decisions/0007-retry-budget.md (AD-0007)
  - retained existing reconciliation in docs/design/retry.md
  - retained existing untracked docs/specification/retry.md
divergences: Spec R4 and README.md say five attempts; code defaults to three total attempts. README quickstart imports backoff.retry; the implementation exposes retry.retry_with_backoff. Delay and jitter bounds lack direct test assertions.
offers: CONTRIBUTING.md requires descriptions to state five attempts; human policy reconciliation needed. The vendored MIT jitter helper has no NOTICE(S) entry; human provenance/legal review needed.
references: none blocking; docs/wip/held.md and docs/archive/history.md citations are excluded WIP/history and were preserved.
checks: python3 tests/test_retry.py — four PASS results, exit 0; just doc-path-check — durable decision exists, exit 0. Ran git grep -n -F 'docs/wip/' -- . before and after archive and inspected relative record links.
wip: docs/wip/held.md — disposition unresolved — not this feature's spec/plan; left for the human or producing skill. Branch remains unfinished until resolved or debt is accepted with a reason and durable marker.
notes: Archived only the assigned pair with git mv to docs/archive/specs/retry-backoff.md and docs/archive/plans/retry-backoff.md. No records or project docs rewritten; prior reconciliation and dispatcher caller changes retained.
  git diff main...HEAD was empty; inspected git diff main -- src tests and current feature files. No commits or external contact.
```
