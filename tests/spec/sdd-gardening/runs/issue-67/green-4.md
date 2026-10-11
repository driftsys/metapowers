### D1

Write `docs/decisions/0007-retry-budget.md` now, assuming 0007 is the next available project id after checking existing records. Record Context, Options (bounded budget and unlimited retries), Decision, Consequences, and available trace links. Preserve the documented rationale without inventing alternatives. Express status as `Accepted; not implemented` so agreement does not imply shipped behavior. Keep exploration in WIP. During implementation, use `// Retry budget rationale: docs/decisions/0007-retry-budget.md.` after confirming that path. Do not cite the WIP spec or dispatch gardening before implementation and tests are green.

### D2

Edit the existing requirement and design records in place; preserve their descriptions of shipped behavior. Add clearly separated planning content, for example in `docs/specification/http-client.md`: `Status: agreed; not implemented. The client limits retries to the agreed retry budget.` In `docs/design/http-client.md`: `Status: agreed; not implemented. The planned retry interface exposes the agreed budget and exhaustion behavior described below.` Include the actual agreed interface details, without inventing signatures. The WIP plan references these durable sections directly. Neither draft establishes implemented behavior; reconcile both against code and tests after TDD. Do not dispatch the gardener during planning.

### D3

Omit the comment: the condition and `remaining_attempts` name already explain when the loop stops. If surrounding code needs clarification, a local `// Stop when the attempt budget is exhausted.` is sufficient. Create no document solely to give this statement a link, and introduce no WIP citation. No architectural choice or separate rationale needs a decision record. Do not dispatch the gardener for this implementation detail; gardening applies to the finished feature's assigned spec and plan once tests pass.

### D4

Dispatch the gardener for the named pair and report the other WIP file without deciding its disposition. Require citation review independently of the passing path check. Release pressure and prior approval do not clear lasting WIP citations. Establish each caller's meaning with the human; the existing decision may fit some callers, but do not blindly substitute it or archive paths. Resolve callers through normal implementation/review, then rerun gardening. Leave the pair in place on refusal; exclude WIP-internal and historical archive citations.

```text
status: refused
records: none
 divergences: none established
 offers: none established
references:
  - src/retry.rs -> docs/wip/specs/retry-budget.md
  - fixtures/retry.ridl -> docs/wip/specs/retry-budget.md
  - docs/design/http-client.md -> docs/wip/specs/retry-budget.md
  - README.md -> docs/wip/specs/retry-budget.md
  - docs/technotes/retries.md -> docs/wip/specs/retry-budget.md
  - src/client.rs -> docs/wip/specs/
checks: just doc-path-check passed as supplied; does not clear citations
wip:
  - docs/wip/specs/retry-budget.md; retained on refusal
  - docs/wip/plans/retry-budget.md; retained on refusal
  - docs/wip/other-feature.md; disposition unresolved — not this feature's spec/plan; leave for human or producing skill
notes: Branch unfinished until other WIP is gardened or human accepts debt with reason and durable marker; do not write marker.
```

### D5

Dispatch for the retry spec and plan after gathering current records, code/tests, and feature diff. Reuse existing records; update the retry paragraph in `docs/design/http-client.md` to describe implemented behavior confirmed by code and tests. Do not create duplicate requirements or decisions. Review lasting references separately; the plan's durable link is appropriate, and the archive's historical WIP citation stays untouched. Perform the feature-scoped project-doc consistency pass, archive the raw pair using established layout, and run applicable path checks. The following is the completion digest only if those checks pass and no additional drift appears:

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
references: none
checks: just doc-path-check passed (required before this digest)
wip: empty
notes: Existing requirement and AD-0007 retained; raw retry spec and plan archived using established layout; historical archive citation preserved.
```

### D6

Return refused and report the exact failed gate. Do not fabricate `missing.md`, repoint the link speculatively, or claim completion. Ask the dispatcher to establish the intended target and resolve the broken reference through normal implementation/review, then rerun the gate and gardening verification. Since path validation follows archival, a failure does not imply that the raw pair remains in WIP; report actual disposition. Under the stated clean finish and normal procedure, the digest is:

```text
status: refused
records:
  - edited docs/design/http-client.md (implementation status reconciled)
 divergences: none
 offers: none
references: none
checks: just doc-path-check FAILED — docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty
notes: Raw pair archived before path validation; completion blocked pending correct link/target resolution and passing recheck. No decision invented.
```
