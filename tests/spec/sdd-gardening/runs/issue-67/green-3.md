### D1

Write the accepted decision now in `docs/decisions/`, following existing numbering and naming conventions (scan before allocating an ID). Capture context, bounded versus unlimited retries, the accepted choice, consequences, and available trace links. State **Accepted; not implemented** explicitly. Preserve the actual rejected option and rationale from WIP; do not fabricate alternatives. This is design-time capture, so do not dispatch finishing-time gardening before implementation and green tests. During implementation, use a direct durable reference, for example:

```rust
// Bound retries to limit repeated failures; rationale: docs/decisions/0007-retry-budget.md.
```

Use that filename only if it is the allocated record's actual path.

### D2

Edit the existing HTTP-client requirement and design records in place, keeping shipped descriptions accurate. Add distinct, explicitly unimplemented sections for the agreed retry requirement and interface; preserve their agreed details rather than inventing values or signatures. For example:

```markdown
## Retry budget

Status: Agreed during planning; not implemented or verified.

The client shall stop retrying when its configured retry budget is exhausted.
```

In the design record, label the agreed interface **Proposed; not implemented**, recording its actual agreed signature and semantics. Link the implementation plan directly to these durable sections. Acceptance of the proposal does not establish shipped behavior or replace the forthcoming red-green-refactor cycle. No finishing-time gardener dispatch yet.

### D3

Omit the comment if the loop condition already makes the stopping condition clear. If local context warrants it, use:

```rust
// Stop when the retry budget is exhausted.
```

Create no decision, requirement, design, or technote solely to provide a citation: there is no useful separate rationale here. Do not cite a WIP file. Do not dispatch the gardener for this isolated implementation comment; gardening is for a finished feature's named spec and plan after tests are green. Continue the implementation and its applicable TDD work normally.

### D4

Refuse archival despite release pressure, prior link approval, and passing path checks. Report all six lasting callers; exclude WIP itself and historical archive citations. Leave the assigned pair in place and leave `other-feature.md` untouched. The dispatcher must establish meaningful durable references or local explanations with the human, resolve callers through implementation/review, and rerun gardening. The existing decision is a candidate, not permission for blind substitution.

```text
status: refused
records: none
divergences: none
offers: none
references:
  - src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md -> docs/wip/specs/retry-budget.md
  - src/client.rs -> docs/wip/specs/
checks: supplied just doc-path-check success does not clear citation blockers
wip:
  - docs/wip/specs/retry-budget.md and docs/wip/plans/retry-budget.md: retained; references block archive
  - docs/wip/other-feature.md: disposition unresolved; not this feature's spec/plan; human or producing skill owns completion
notes: branch unfinished while unresolved WIP remains; human debt acceptance requires reason and durable marker
```

### D5

Dispatch gardening with the exact retry pair, green-test evidence, existing records, feature diff, and canonical docs. Reconcile existing records in place; change the stale design status to implemented as verified by code and tests. Do not duplicate the requirement or decision. The plan's durable link is appropriate; leave the historical archive citation untouched. Review lasting citations separately, archive only the raw pair using the established archive layout, and run applicable path checks. A successful hypothetical digest, conditional on those checks, is:

```text
status: done
records:
  - edited docs/design/http-client.md
divergences: none
offers: none
references: none
checks: applicable repository path checks must pass; otherwise refused
wip: empty
notes: existing requirement and AD-0007 reconciled; raw pair archived under established layout
```

### D6

Return refused with the precise gate failure; do not invent the missing decision or claim completion. Have the dispatcher establish the intended durable target or a self-contained explanation through normal implementation/review, correct the caller accordingly, and rerun the gate and gardening checks. Since path validation follows archival, report the pair's actual location; a failed gate need not imply it remains in WIP. Assuming the clean pair was archived before this gate:

```text
status: refused
records: none newly required by this failure
divergences: none
offers: resolve intended target for docs/design/http-client.md with the human
references: none
checks: just doc-path-check FAILED: docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty
notes: raw pair archived; failed path gate blocks completion
```
