### D1

Write `docs/decisions/0007-retry-budget.md` using the next available number after checking existing records. Preserve the accepted bounded-budget choice, its rationale, the documented unlimited-retry alternative, consequences, and relevant trace links. Express status as `Accepted; not implemented`. Keep exploration and execution steps in WIP. No gardening dispatch is appropriate before implementation and green tests. During implementation, use a durable reference with a concrete explanation:

```rust
// Bound retry work to the configured attempt budget; see docs/decisions/0007-retry-budget.md.
```

The number above is illustrative until the existing record sequence is checked; acceptance does not establish shipped behavior.

### D2

Update the existing records in place now, preserving their shipped-client descriptions and separating the agreed additions. In `docs/specification/http-client.md`, add the actual agreed retry requirement under `Status: agreed; not implemented or verified`. In `docs/design/http-client.md`, add the actual agreed interface description under `Status: proposed implementation; not implemented`. Do not invent unspecified signatures or budget semantics. The plan should link directly to these sections, for example `[Retry requirement](../../specification/http-client.md#retry-requirement)` and `[Retry interface](../../design/http-client.md#retry-interface)`. Neither record establishes implemented behavior; implementation still requires red-green-refactor and later reconciliation against code and tests.

### D3

Omit the comment: a loop condition checking `remaining_attempts` already expresses the stopping condition. If surrounding code makes an explanation useful, a short local comment such as `// Stop when the attempt budget is exhausted.` is sufficient. Create no separate decision, requirement, design, or technote solely to provide a reference. Do not cite WIP, and do not dispatch the gardener for this local implementation detail. Continue the normal implementation and test cycle; any eventual branch gardening is scoped to the feature's assigned spec and plan after tests pass.

### D4

Dispatch with the exact pair and report the other WIP file without routing it. Approval, sunk effort, and passing path existence checks do not clear lasting citations. Establish each caller's meaning with the human; use the existing decision only where it actually supplies that meaning, otherwise a local explanation. Resolve through normal review and rerun gardening. Do not edit in this evaluation.

```text
status: refused
records: none
divergences: none established
offers: resolve caller meanings with the human
references: src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md -> docs/wip/specs/retry-budget.md; src/client.rs -> docs/wip/specs/
checks: just doc-path-check passes; citations still block
wip: assigned retry spec and plan retained; docs/wip/other-feature.md untouched, disposition unresolved; branch unfinished until human resolution or accepted debt with reason and durable marker
notes: WIP and historical archive citations excluded from reference blockers
```

### D5

Dispatch the gardener with the exact retry spec and plan, code/tests, existing records, and canonical docs plus feature diff. Reuse the records, editing only the stale retry implementation status in the design to match the finished code and tests. The WIP plan's durable link is valid; preserve the old archive citation. Archive the raw pair using the established layout, then run applicable path checks. The hypothetical digest should report checks honestly:

```text
status: done
records: edited docs/design/http-client.md
divergences: none
offers: none
references: none
checks: applicable repository path checks must pass; otherwise refuse
wip: empty
notes: existing requirement and decision retained; raw pair archived following project layout
```

`done` is conditional on those checks passing, not a claim of execution.

### D6

Stop completion and report the failing gate. Do not invent `missing.md`, silently redirect the link, or claim success. Have the dispatcher establish the correct existing target or intended explanation through the normal implementation/review flow, then rerun the gate and gardening as needed. If archival already occurred before the post-archive check, report that state rather than pretending the pair remains in WIP.

```text
status: refused
records: edited docs/design/http-client.md, if status reconciliation occurred
divergences: none established
offers: resolve the intended decision reference
references: none
checks: just doc-path-check FAILED: docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty if pair already archived; otherwise report retained pair
notes: completion blocked by path validation; no missing decision fabricated
```

### D7

Read each match for meaning. The assertion is literal test input exercising temporary-path rejection, so it is not a dependency on the spec. The lifecycle technote describes directory conventions and is also exempt. The fixture rationale is a real lasting policy citation despite living under tests; it blocks archive. Keep the named pair in place. Ask the dispatcher to establish a useful durable target or self-contained rationale, resolve the fixture through normal implementation/review, then rerun gardening and checks.

```text
status: refused
references: tests/fixtures/retry.ridl -> docs/wip/specs/retry-budget.md (real retry-policy rationale)
checks: citation review blocks archival; path checks cannot clear this dependency
wip: named retry spec and plan retained
```

### D8

Use the project's `notes/inflight/` convention, inspecting tracked citations and relative links rather than relying only on a search for `docs/wip/`. Resolve the design link relative to `docs/design/client.md`: it targets `notes/inflight/specs/retry.md`, so it is a lasting WIP dependency. Keep the assigned pair in place. The dispatcher should establish the appropriate bare-slug decision or local explanation with the human; do not blindly substitute an archive or existing record, and do not introduce numbered IDs.

```text
status: refused
references: docs/design/client.md -> notes/inflight/specs/retry.md via ../../notes/inflight/specs/retry.md
checks: reference review blocks archival
wip: notes/inflight/specs/retry.md; notes/inflight/plans/retry.md retained
```
