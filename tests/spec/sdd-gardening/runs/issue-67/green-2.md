### D1

Write a durable decision now in `docs/decisions/`, following the project's existing naming and ID convention after checking existing records. Capture Context, Options (bounded budget and rejected unlimited retries), Decision, Consequences, and available trace links. State `Status: accepted; not implemented`. Preserve exploration in WIP. Implementation tomorrow still requires red-green-refactor; acceptance does not establish shipped behavior. Use the actual allocated record path in the source comment, for example, if allocated as 0007:

```rust
// Retry attempts are bounded by the accepted budget; see docs/decisions/0007-retry-budget.md.
```

Do not dispatch gardening before implementation and green tests.

### D2

Update the existing `docs/specification/http-client.md` and `docs/design/http-client.md` in place, preserving their shipped-client descriptions. Add clearly separate proposed sections containing the agreed requirement and interface description, using the actual agreed values and signature rather than inventing them. Express status in each:

```text
Status: agreed during planning; proposed behavior; not implemented or verified.
```

The requirement states the bounded retry behavior; the design describes the agreed interface. Give the requirement its next project-convention ID and link the WIP implementation plan directly to these durable sections. Do not describe retries as shipped. Reconcile these statuses against code and tests during gardening after TDD finishes.

### D3

Omit the comment: the loop condition already explains that execution stops when `remaining_attempts` reaches zero. No separate rationale or architectural decision needs preservation. If surrounding control flow makes the condition unclear, a short local comment such as `// Stop when no retry attempts remain.` is sufficient, but avoid merely restating obvious code. Create no document solely to supply a link. Do not cite WIP or create a decision record, technote, requirement, or design section for this fact. Do not dispatch the gardener for this isolated explanation; gardening belongs to the finished feature's spec/plan reconciliation after tests pass.

### D4

Dispatch the gardener with exactly the assigned pair, green-test evidence, existing records, diff, and canonical docs; mention `docs/wip/other-feature.md` without directing its disposition. Citation review blocks archival despite link approval, sunk effort, release pressure, and passing existence checks. Establish meaningful durable targets or local explanations with the human, resolve callers through normal review, then rerun gardening. Do not blindly replace links with the ADR or archive paths. Exclude the WIP caller and historical archive citation from blocking references.

```text
status: refused
records: none
references: src/retry.rs; fixtures/retry.ridl; docs/design/http-client.md; README.md; docs/technotes/retries.md -> docs/wip/specs/retry-budget.md; src/client.rs -> docs/wip/specs/
checks: supplied just doc-path-check success does not clear citation blockers
wip: docs/wip/specs/retry-budget.md and docs/wip/plans/retry-budget.md retained; docs/wip/other-feature.md disposition unresolved — not this feature's spec/plan; leave for human or producing skill
notes: branch unfinished; unrelated WIP requires human disposition or accepted debt with reason and durable marker
```

### D5

Dispatch the gardener with the named retry spec/plan, finished code/tests, existing records, feature diff, and canonical docs. Reuse the existing requirement and decision records; edit the retry design paragraph in place to describe implemented behavior verified by tests. Preserve the WIP plan's durable link and the historical archived citation. After citation review, archive only the assigned raw pair using the established archive layout; discover and run applicable path checks. The example digest below is conditional on those checks passing and no further findings, not a claim of execution.

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
 references: none
 checks: applicable repository path checks passed
 wip: empty
 notes: existing requirement and AD-0007 reconciled; raw assigned pair archived using established layout
```

### D6

Return refusal and report the failed command and exact missing path. Do not fabricate `docs/decisions/missing.md`, substitute an unrelated decision, or claim completion. Ask the dispatcher to establish whether the design citation is wrong or a real record is missing, resolve it through normal implementation/review, and rerun applicable checks. Since path validation follows archival, the assigned pair may already be archived; report its actual location without claiming a move occurred in this evaluation.

```text
status: refused
records: report actual record edits, if any
 divergences: none
 offers: none
 references: none
 checks: just doc-path-check failed — docs/design/http-client.md: docs/decisions/missing.md does not exist
 wip: report actual remaining files; empty if assigned pair already archived and no other WIP remains
 notes: completion blocked until citation or target is resolved and gate passes
```
