### D1

Write a durable decision now in `docs/decisions/`, following existing naming and ID conventions; use `0007-retry-budget.md` / `AD-0007` only if available. Record Context / Options / Decision / Consequences, the documented unlimited-retry alternative, and useful trace links. Express status as **Accepted; not implemented**. Keep exploration and execution steps in WIP; the durable record must not cite WIP. During implementation, use: `// Retry attempts are bounded by the accepted budget; see docs/decisions/0007-retry-budget.md.` Adjust that path to the actual allocated record. Implementation still requires red-green-refactor; acceptance does not establish shipped behavior. No gardener dispatch before green tests.

### D2

Edit `docs/specification/http-client.md` and `docs/design/http-client.md` in place, preserving their shipped-client descriptions. Add clearly separated sections headed **Agreed retry requirement — not implemented** and **Proposed retry interface — not implemented**. Requirement excerpt: “The client limits retry attempts to the configured retry budget. Status: agreed; tests and implementation pending.” Describe only the agreed interface details, without inventing signatures. The plan should link to these durable sections directly. Their status remains explicit until implementation and tests substantiate it; documentation does not supersede code and tests. Retain planning steps in WIP. This is source-time capture, not completion gardening; do not dispatch the gardener yet.

### D3

Omit the comment if the loop condition already clearly expresses `remaining_attempts > 0`; repeating the condition adds little. If context makes a comment useful, use `// Stop when no attempts remain.` No architectural choice or separate rationale exists, so create no durable document solely to supply a link. Do not cite a WIP path in source. Do not dispatch the gardener for this local implementation explanation: its scope is a finished feature's assigned spec/plan pair after tests pass, not ad-hoc documentation. Continue the implementation's normal TDD cycle.

### D4

Dispatch gardening with the named pair and mention `docs/wip/other-feature.md` without assigning its disposition. Report all six lasting callers; neither link approval, urgency, nor a passing existence check clears them. Leave the pair in place. Establish useful durable targets or local explanations with the human, then resolve callers through normal implementation/review and rerun gardening; the existing decision is a candidate, not an automatic replacement. Exclude WIP and historical archive citations.

```text
status: refused
records: none
 divergences: none
 offers: none
references: src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md -> docs/wip/specs/retry-budget.md; src/client.rs -> docs/wip/specs/
checks: just doc-path-check passed; does not clear citation blockers
wip: docs/wip/specs/retry-budget.md and docs/wip/plans/retry-budget.md retained; docs/wip/other-feature.md disposition unresolved — not this feature's spec/plan; leave for human or producing skill. Branch unfinished unless resolved or human accepts debt with reason and durable marker.
notes: No edits performed in this evaluation.
```

### D5

Dispatch the gardener for the retry spec/plan pair after confirming mode and supplying code, tests, existing records, and canonical docs. Reuse existing records; edit only the retry paragraph's stale status to describe implemented behavior supported by code and tests. Do not create duplicate requirements or decisions. WIP's outbound durable link is fine; preserve the archived historical citation. In collaborative mode, archive the raw pair using the established archive layout, then run applicable path checks. Assuming those checks pass and no other WIP exists, the digest would be:

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
references: none
checks: just doc-path-check passed (hypothetical successful result)
wip: empty
notes: Existing requirement and AD-0007 reused; raw pair archived using established layout. No execution claimed.
```

### D6

Return refused with the exact gate failure. Do not invent `missing.md`, blindly change the link, or claim completion. Ask the dispatcher/human to establish the intended reference and resolve it through normal implementation/review; rerun the gate and gardening verification afterward. If collaborative archival already occurred before the prescribed post-archive check, report that state accurately; failure does not imply the pair remains in WIP or require undoing archival.

```text
status: refused
records: none newly created; report any actual reconciliation edits separately
 divergences: none
 offers: none
references: none
checks: just doc-path-check FAILED: docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty if the assigned pair was already archived and no other WIP remains
notes: Completion blocked pending intended-link resolution and passing gate; no missing decision fabricated. Hypothetical digest, no execution.
```
