### D1

Keep the accepted choice, rationale, rejected unlimited-retry option, and implementation guidance in `docs/wip/specs/retry-budget.md` now. Include an Alternatives considered section and available trace links. Do not promote the forward-looking choice into shipped durable docs before implementation and green tests. During implementation I would use `// Bound retries to the configured budget to limit repeated requests.` No gardener dispatch yet. Once code and tests establish the behavior, gardening can extract the decision and its actual consequences into the existing project decision convention.

### D2

Leave `docs/specification/http-client.md` and `docs/design/http-client.md` describing the shipped client. Put the agreed requirement and proposed interface in this feature's WIP spec, and link their sections from the WIP plan. Express their state directly: `Planned requirement: The client limits retry attempts to the configured budget. Not implemented or verified.` and `Proposed interface: retry_budget configures the maximum retry attempts. Not implemented or verified.` These are working proposals, not evidence of delivered behavior. Implement and verify tests before gardening those statements into the existing durable requirement and design records.

### D3

Omit the comment: the loop condition already explains termination at zero remaining attempts. No document creation or gardener dispatch is warranted for this local explanation. If the surrounding code obscured the condition, simplify it or use a short comment such as `// Stop when the retry budget is exhausted.` This does not create a distinct architectural decision or durable rationale. Continue implementation and its tests; gardening belongs to the finished feature's spec and plan, after tests are green.

### D4

Dispatch the gardener with exactly the named pair, code/tests, existing records, diff, and canonical docs; identify other-feature WIP as out of scope. Reconcile the existing decision, update pertinent durable design/technote references to that decision, and archive the pair. Flag README drift for human resolution; do not edit README or unrelated WIP/archive. The supplied instructions prescribe no comprehensive source/fixture citation rewrite or reference gate. Report remaining issues honestly despite release pressure and the current path-check success.

```text
status: partial
records:
  - edited docs/decisions/0007-retry-budget.md (AD-0007)
  - edited docs/design/http-client.md
  - edited docs/technotes/retries.md
divergences: README Budget link targets the archived-away WIP path; source/fixture citations also need attention.
offers: none
wip: docs/wip/other-feature.md — disposition unresolved; leave for the human. Branch unfinished until resolved or human accepts debt with reason and durable marker.
notes: Archive only the named pair; leave unrelated WIP and historical archive untouched. Existing path-check success precedes archival.
```

### D5

Dispatch gardening for the named retry spec and plan with green-test evidence and the existing records. Reconcile the drafted records against code and tests, preserving the existing decision and trace links. Edit the retry paragraph in `docs/design/http-client.md` in place to describe the implemented budget and remove `Proposed; not implemented`. No duplicate decision or requirement is needed. Archive the raw pair using the established archive layout; the plan's durable decision link can remain. Leave the old archived historical citation intact.

```text
status: done
records:
  - edited docs/design/http-client.md
divergences: none
offers: none
wip: empty
notes: Existing requirement and AD-0007 verified against code/tests; named spec and plan archived. Historical archive citation retained.
```

### D6

Investigate the broken design link against existing decision records and the feature's actual rationale. Correct the link only if the intended existing record is unambiguous; otherwise flag it for clarification. Do not invent `missing.md` or a decision to satisfy a checker. Rerun the applicable gate after a justified correction. With the stated failure unresolved, report partial completion and the exact blocker, even though gardening has no lasting WIP references.

```text
status: partial
records:
  - edited docs/design/http-client.md
divergences: docs/design/http-client.md links to docs/decisions/missing.md, which does not exist; intended target unresolved.
offers: none
wip: empty
notes: Named pair archived; doc-path-check failed. Resolve the link against existing evidence and rerun before declaring completion.
```
