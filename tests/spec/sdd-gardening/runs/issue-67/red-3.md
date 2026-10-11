### D1

Keep the accepted choice and its documented unlimited-retry alternative in `docs/wip/specs/retry-budget.md` now. Mark implementation as pending there. The supplied lifecycle rules keep forward-looking material out of shipped records, so I would not create a durable decision before implementation. Preserve trace links and the rationale for later gardening. During implementation, a possible comment is:

```rust
// Bound retries to the agreed budget so a failing request cannot retry indefinitely.
```

I would not dispatch the gardener before the implementation and tests are complete.

### D2

Leave `docs/specification/http-client.md` and `docs/design/http-client.md` describing the shipped client. Put the agreed retry requirement and interface description in the feature's WIP spec, and link to their sections from its WIP plan. Express their state explicitly in working memory:

```markdown
## Retry requirement

Agreed during planning; not implemented or verified.

The client limits retries to the configured budget.

## Retry interface

Proposed; not implemented. The request configuration supplies the retry budget.
```

The plan would reference those anchors. After implementation and green tests, gardening would reconcile and incorporate the material into the existing durable records.

### D3

Omit the comment: the condition and `remaining_attempts` name already explain why the loop stops. A comment such as “stop when no attempts remain” would repeat the code without adding useful rationale. I would create no decision, technote, requirement, or design record for this local control-flow detail. I would not dispatch the gardener for ad-hoc explanation during implementation; its scope is a finished feature's spec and plan after tests pass. If later work uncovers a separate meaningful choice, its actual rationale can be captured in working memory for that feature.

### D4

Dispatch gardening with exactly the named pair, green-test evidence, existing records, and the feature diff. Note `docs/wip/other-feature.md` as untouched outside-scope WIP. Reconcile the matching decision in place and archive only the pair using the existing archive layout. The supplied instructions define no lasting-reference gate; current path-check success does not establish post-archive validity. Flag the README citation for the human, and surface source/fixture citations as outside the gardener's editing scope. Reconcile citations in owned durable records where relevant; leave other WIP and historical archive untouched. Release pressure does not resolve remaining WIP.

```text
status: partial
records:
  - edited docs/decisions/0007-retry-budget.md (AD-0007), if reconciliation requires it
  - edited docs/design/http-client.md and docs/technotes/retries.md as needed
 divergences: README.md cites the spec being archived; source and fixture references also need resolution outside gardening
 offers: human resolution of lasting source, fixture, and README references
 wip: docs/wip/other-feature.md — disposition unresolved; leave untouched; branch unfinished until human resolution or accepted debt with reason and durable marker
 notes: Archive only the named pair. No claim that the earlier path check validates the resulting tree.
```

### D5

Dispatch the gardener for the named retry spec and plan, with green-test evidence and existing records. Reconcile the existing requirement, design, and decision rather than duplicating them. Remove “Proposed; not implemented” from the design paragraph and describe the verified implemented behavior. The WIP plan's durable link needs no change. Preserve the old archive's historical citation. Archive the raw pair in collaborative mode following the existing archive convention, then verify that the pair is absent from WIP. Assuming no other WIP files or divergences, the proposed digest is:

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
 wip: empty
 notes: Existing requirement and AD-0007 match code and tests. Named raw spec and plan archived; historical archive preserved.
```

### D6

Do not report completion while the applicable documentation gate fails. Inspect the broken link and existing decision records to establish whether it is a mistaken path to an actual record or an unresolved decision gap. Correct a demonstrably wrong link in the owned design record and rerun the gate; if the target cannot be established, flag it for human resolution. Do not manufacture a decision to satisfy the checker. With the failure still unresolved, the proposed digest is:

```text
status: partial
records: no additional record created for the missing target
 divergences: docs/design/http-client.md references nonexistent docs/decisions/missing.md
 offers: confirm the intended existing decision or resolve the documentation gap
 wip: empty, assuming the named pair has already been archived and no other WIP remains
 notes: just doc-path-check fails; completion remains unverified pending correction and a passing rerun.
```
