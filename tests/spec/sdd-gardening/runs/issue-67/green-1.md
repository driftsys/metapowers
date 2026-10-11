### D1

Write `docs/decisions/0007-retry-budget.md` now, assuming 0007 is the next available project ID after checking existing decisions. Capture the accepted bounded budget, unlimited retries as the rejected option, the supplied rationale, consequences, and relevant trace links. State `Status: accepted; not implemented` explicitly. Keep exploration in WIP; tomorrow's implementation still requires TDD. During implementation, use a direct durable citation:

```rust
// Retry attempts use a bounded budget; see docs/decisions/0007-retry-budget.md.
```

Do not cite the WIP spec or claim that the accepted decision establishes shipped behavior. No gardening dispatch is appropriate before implementation and passing tests.

### D2

Edit the existing `docs/specification/http-client.md` and `docs/design/http-client.md` in place. Preserve their descriptions of shipped behavior and add clearly separated proposed sections containing the agreed requirement and interface description. For example:

```text
Status: agreed; not implemented or verified.
Requirement: The client stops retrying when its configured retry budget is exhausted.
```

In the design record, describe the agreed interface from planning with `Status: proposed; not implemented`; do not invent a signature absent from the inputs. Link the implementation plan directly to these durable sections. These records describe agreed future work, while code and tests remain the implementation evidence. Reconcile status during gardening after TDD passes.

### D3

Omit the comment: `remaining_attempts` and the loop condition already express why the loop stops. If surrounding code needs clarification, use the self-contained comment `// Stop when the retry budget is exhausted.` No separate document adds value here, so create no decision, requirement, or technote merely to provide a citation. Do not link to a WIP spec or plan. Do not dispatch the gardener for this local implementation detail; continue the normal implementation and test cycle. Gardening is for the completed feature's assigned working-memory pair, after tests pass, not an ad-hoc documentation service.

### D4

Dispatch gardening for the named pair, noting `docs/wip/other-feature.md` without assigning its disposition. Reference review must refuse archival despite passing path checks, prior approval, and release pressure. Establish appropriate durable targets or local explanations with the human, then resolve callers through implementation/review and rerun gardening. The existing decision is a candidate, not permission for blind replacement. Exclude WIP and historical archive citations from blockers; leave them untouched.

```text
status: refused
records: none
divergences: none
offers: none
references: src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md cite docs/wip/specs/retry-budget.md; src/client.rs cites docs/wip/specs/
checks: supplied just doc-path-check success does not clear citation blockers; gardening checks not run
wip: docs/wip/specs/retry-budget.md and docs/wip/plans/retry-budget.md retained due to references; docs/wip/other-feature.md disposition unresolved — not this feature's spec/plan; leave for human
notes: Branch remains unfinished; unresolved extra WIP requires human disposition or accepted debt with a reason and durable marker.
```

### D5

Dispatch the gardener with the exact pair, code/tests, existing records, and feature diff. Reuse the drafted records; update the retry section in `docs/design/http-client.md` to describe implemented, test-verified behavior. Keep unchanged matching requirements and decision records. Review lasting citations separately from path checks: the plan's durable link is appropriate, and the historical archive citation stays untouched. In collaborative mode, archive only the assigned raw pair using the established archive layout, then run applicable path checks. The expected digest below is conditional on successful checks, not a claim of execution.

```text
status: done
records:
  - edited docs/design/http-client.md
divergences: none
offers: none
references: none
checks: just doc-path-check passes, required before completion
wip: empty
notes: Assigned raw pair archived using existing layout; historical archive citation preserved.
```

### D6

Return refused with the exact gate failure; do not invent `missing.md` or claim completion. Ask the dispatcher to establish whether the design link names the wrong existing record or exposes a genuine documentation gap, resolve it through the normal review flow, and rerun the gate and gardening. If archival already occurred before this post-archive check, report that actual state; failure does not establish that the pair remains in WIP. The digest below assumes the prescribed collaborative archival step preceded validation.

```text
status: refused
records: none newly required by this case
divergences: none
offers: none
references: none
checks: just doc-path-check failed: docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty, assuming assigned pair was archived before validation
notes: Completion blocked until the link or genuine record gap is resolved and checks pass; do not fabricate a decision.
```
