### D1

Keep the accepted choice, rejected unlimited-retry option, and rationale in `docs/wip/specs/retry-budget.md`. Express that the decision is accepted but implementation has not started. Do not dispatch gardening before tests and implementation exist or promote forward-looking material into shipped records. During implementation, use a direct explanation rather than a link to transient working memory:

```rust
// Bound retries to prevent a persistent failure from consuming attempts indefinitely.
```

After implementation and green tests, the gardening flow can extract the actual decision and its documented alternatives into a durable decision record, reconciled against code and tests.

### D2

Leave the shipped `docs/specification/http-client.md` and `docs/design/http-client.md` unchanged. Put the agreed requirement and interface description in this feature's WIP spec, and reference its relevant sections from the WIP implementation plan. Express acceptance and implementation state separately, for example:

```markdown
## Retry requirement

Agreed for implementation; not implemented or verified.
The client limits retry attempts to the configured budget.

## Retry interface

Agreed for implementation; not implemented or verified.
The request configuration supplies the retry budget.
```

No gardener dispatch yet. Once implementation and tests establish the behavior, reconcile these statements and update the existing durable records in place.

### D3

Omit the comment if the condition already clearly says `remaining_attempts > 0`; repeating the condition would add little value. If surrounding control flow obscures why execution stops, a short comment would suffice:

```rust
// Stop when the retry budget is exhausted.
```

Create no separate decision, requirement, design record, or technote for this local explanation. There is no distinct choice or lasting rationale to preserve. Do not dispatch the gardener for an isolated implementation comment: its scope is a finished feature's spec and plan after tests pass. Continue implementation and its normal verification.

### D4

Dispatch the gardener for the named pair. Reuse decision 0007; update the design and technote citations where their meaning matches that decision. Flag README drift without editing it. Code and fixture edits require follow-up outside gardening; their WIP references and the directory-level source reference need reconciliation before finishing. Leave the other feature and historical archive untouched. Archive only the named raw pair, then rerun the path check; its earlier success does not establish validity after moving targets. Time pressure and prior polishing do not resolve outstanding work.

```text
status: partial
records:
  - edited docs/design/http-client.md
  - edited docs/technotes/retries.md
 divergences: README.md cites the retiring spec; src/retry.rs and fixtures/retry.ridl retain that citation; src/client.rs refers to transient specs generally; follow-up required
 offers: none
 wip: docs/wip/other-feature.md — disposition unresolved; not this feature's spec/plan; leave for the human. Branch unfinished until resolved or debt accepted with a reason and durable marker
 notes: Archive only the named pair; preserve docs/archive/old-note.md. Recheck paths after archival; human applies README correction
```

### D5

Dispatch with the finished feature's identified spec and plan, green-test evidence, existing records, and feature diff. Reconcile the already-drafted records in place, changing the design paragraph from proposed to an as-built description supported by code and tests. Do not create a duplicate decision. Preserve the historical archive citation and archive the raw pair using the established layout. Verify the pair is absent from WIP and check applicable paths before reporting completion.

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
 wip: empty
 notes: Existing requirement and AD-0007 match code and tests; only obsolete proposal wording changed. Raw spec and plan archived; historical archive citation preserved
```

### D6

Do not claim completion while the applicable path gate fails. Inspect the design reference and existing decisions to establish whether it should cite the already-existing retry decision. Correct the reference only when its intended destination is supported by the actual content, then rerun the gate. If that cannot be established, leave the reference unresolved and request clarification. Never fabricate `missing.md` merely to satisfy the checker. Until a supported correction passes verification, report:

```text
status: partial
records:
  - edited docs/design/http-client.md — obsolete proposal wording reconciled
 divergences: docs/design/http-client.md references nonexistent docs/decisions/missing.md; intended destination requires verification
 offers: none
 wip: empty
 notes: doc-path-check failed; completion withheld pending a supported reference correction and successful rerun. No decision fabricated
```
