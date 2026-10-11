### D1

Write `docs/decisions/0007-retry-budget.md` now, assuming 0007 is the next unused project decision number after checking existing records. Include Context, Options (bounded budget and unlimited retries), Decision, Consequences, and available trace links. State `Status: accepted; not implemented`. Preserve the rationale from the spec without claiming shipped behavior. Keep execution steps in WIP; do not dispatch gardening before implementation and green tests. During implementation use: `// Retry attempts are bounded by the accepted budget; see docs/decisions/0007-retry-budget.md.` Use the actual allocated path if numbering differs.

### D2

Edit the existing requirement and design records in place, retaining their descriptions of shipped behavior. Add clearly separated sections: in `docs/specification/http-client.md`, `Status: agreed requirement; not implemented. The client shall stop retrying when its configured attempt budget is exhausted.` In `docs/design/http-client.md`, `Status: proposed interface; not implemented. The retry interface accepts a bounded attempt budget.` Preserve the actual agreed interface details rather than inventing a signature. Link the WIP plan directly to these durable sections. These records describe agreed future work; they do not establish implemented behavior or replace TDD. No finishing gardener dispatch yet.

### D3

Omit the comment: the loop condition and `remaining_attempts` already explain the stopping condition. If surrounding code obscures the behavior, a self-contained comment such as `// Stop once the attempt budget is exhausted.` is sufficient. Create no separate requirement, decision, design record, or technote solely to furnish a link. Do not cite WIP or archive content. Do not dispatch the gardener for this local implementation detail; gardening belongs to finishing a tested feature's assigned spec and plan.

### D4

Refuse archival despite release pressure, prior approval, and the passing existence check. Report all six lasting callers; exclude WIP and historical archive citations. Leave the assigned pair in place and `docs/wip/other-feature.md` untouched. The dispatcher must establish appropriate durable references or local explanations with the human, resolve callers through normal review, and rerun gardening. The existing decision is a candidate, not an automatic substitution.

```text
status: refused
records: none
divergences: none
offers: none
references: src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md -> docs/wip/specs/retry-budget.md; src/client.rs -> docs/wip/specs/
checks: just doc-path-check reports success; citation review remains blocked
wip: docs/wip/specs/retry-budget.md and docs/wip/plans/retry-budget.md retained; docs/wip/other-feature.md — disposition unresolved, outside assigned pair; branch unfinished pending human disposition or explicit debt acceptance with reason and durable marker
notes: WIP and historical archive callers excluded; no edits performed
```

### D5

Dispatch gardening with the exact retry pair, green tests, existing records, feature diff, and canonical docs. Reuse the requirement and decision unchanged; edit the design paragraph in place to describe implemented behavior verified against code and tests. Preserve the archived historical citation and raw pair contents. With no lasting WIP citations, archive only the pair using the established layout, then run applicable path checks. This hypothetical digest assumes those checks pass:

```text
status: done
records: edited docs/design/http-client.md
divergences: none
offers: none
references: none
checks: just doc-path-check — pass (required hypothetical outcome)
wip: empty
notes: Existing requirement and AD-0007 reused; raw retry spec and plan archived using project convention
```

### D6

Return refused with the exact gate failure; do not invent `missing.md` or claim completion. Surface the broken design reference to the dispatcher for normal implementation/review resolution, then rerun the gate and gardening as needed. Because path validation follows archival, the pair may already be archived; report its actual location rather than promising it remains in WIP. Assuming the standard successful archival step preceded this failure:

```text
status: refused
records: edited docs/design/http-client.md (status reconciliation)
divergences: none
offers: none
references: none
checks: just doc-path-check — failed: docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty
notes: Assigned pair archived before path validation; completion blocked until broken reference is resolved and checks pass
```

### D7

Inspect each match semantically. The rejection assertion is literal test input, so it does not depend on working content. The lifecycle sentence describes the directory convention, so it is also exempt. The fixture rationale is a real lasting dependency on the current retry spec and blocks archive despite living under tests. Leave the assigned pair in place. Report:

```text
status: refused
references: tests/fixtures/retry.ridl -> docs/wip/specs/retry-budget.md (real retry-policy rationale)
checks: not run in this hypothetical evaluation
wip: named retry spec and plan retained pending reference resolution
notes: tests/test_paths.py literal input and docs/technotes/lifecycle.md convention description are not blocking citations
```

### D8

Inspect tracked citations using the project's actual `notes/inflight/` convention, including relative Markdown links; absence of `docs/wip/` proves nothing. Resolve the design link relative to `docs/design/client.md`: it targets the assigned inflight spec. Refuse before moving either file. Preserve the bare-slug decision convention when a useful durable target is established; do not invent an AD id or blindly repoint the link.

```text
status: refused
references: docs/design/client.md -> ../../notes/inflight/specs/retry.md (resolves to notes/inflight/specs/retry.md)
checks: not run in this hypothetical evaluation
wip: notes/inflight/specs/retry.md and notes/inflight/plans/retry.md retained
notes: Dispatcher must establish durable rationale or local explanation and resolve caller before rerunning gardening
```
