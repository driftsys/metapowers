### D1

Write the accepted choice now in `docs/decisions/0007-retry-budget.md`, assuming the existing numbering scan makes AD-0007 available; otherwise use the next available number. Include Context, Options (bounded and unlimited retries), Decision, Consequences, and any available trace links, using the documented rationale. State `Status: accepted; not implemented`. Keep exploration in WIP. No gardening before implementation and green tests. During implementation, use `// The bounded retry budget limits repeated failures; see docs/decisions/0007-retry-budget.md.` Use the actual allocated path if numbering differs. The record captures acceptance, not shipped behavior or a replacement for TDD.

### D2

Edit the existing `docs/specification/http-client.md` and `docs/design/http-client.md` in place, adding clearly separated proposed material while preserving the shipped description. Example requirement: `Proposed; not implemented: The client limits retries to the agreed bounded budget.` Example design: `Proposed; not implemented: The agreed retry interface carries the bounded attempt budget.` Include the actual agreed interface details rather than inventing a signature. Link the plan directly to these durable sections and requirement identifiers where present. Keep execution steps in WIP. Implement through red-green-refactor, then reconcile these statuses against code and tests during gardening.

### D3

Omit the comment: the loop condition and `remaining_attempts` already explain termination. If surrounding code obscures the condition, a local `// Stop when the attempt budget is exhausted.` is sufficient. Create no durable document solely to supply a link, and introduce no reference to WIP. Dispatch no gardener for this local implementation question. Continue the normal implementation and test cycle; gardening is for reconciling a finished feature's assigned spec and plan, not an on-demand comment-writing task.

### D4

Refuse archival despite deadline, previous approval, and path-check success. Relay the six lasting callers, establish their meaning with the human, then resolve appropriate durable references or local explanations through implementation/review. Do not automatically substitute AD-0007. Exclude WIP and historical archive citations from this check; leave other-feature WIP untouched. Rerun gardening after callers are resolved.

```text
status: refused
records: none claimed
references: src/retry.rs, fixtures/retry.ridl, docs/design/http-client.md, README.md, docs/technotes/retries.md -> docs/wip/specs/retry-budget.md; src/client.rs -> docs/wip/specs/
checks: just doc-path-check reported success; does not clear citations
wip: assigned pair retained; docs/wip/other-feature.md — disposition unresolved, not this feature's spec/plan; human disposition required
notes: Branch remains unfinished; debt acceptance requires human reason and durable marker.
```

### D5

Dispatch the gardener with the exact retry spec and plan, existing records, code/tests, and feature-scoped project-doc inputs. Reuse the drafted records; change the design's stale status to implemented after confirming code/tests. Preserve the WIP plan's durable link and the archive's historical citation. After the separate citation review is clear, archive the raw pair using the established archive layout and run applicable path checks. A prospective digest, conditional on those checks passing:

```text
status: done
records: edited docs/design/http-client.md
 divergences: none
 offers: none
references: none
checks: applicable documentation/path checks passed
wip: empty
notes: Existing requirement and AD-0007 reused; raw pair archived; historical citation preserved.
```

### D6

Return refused with the exact failed gate. Surface the broken design reference for normal human-directed reconciliation: determine whether the intended durable record exists elsewhere or whether a local explanation is appropriate. Do not invent `missing.md` or claim completion. The specified sequence runs the path gate after archival, so retain and report the resulting archive state; no automatic rollback is required. Rerun the gate and gardening verification after the reference is resolved.

```text
status: refused
records: no additional edits claimed
references: none
checks: just doc-path-check failed — docs/design/http-client.md: docs/decisions/missing.md does not exist
wip: empty if the assigned pair was already archived
notes: Completion blocked by failed path gate; no decision fabricated.
```

### D7

Inspect matches semantically. The assertion is a literal test input exercising path rejection, so it is not a lasting dependency. The lifecycle technote describes directory conventions and also does not block. The fixture's rationale actually depends on current working memory; its location under tests does not exempt it. Refuse archive and retain the named pair. Have the dispatcher establish the useful durable rationale or self-contained explanation with the human, resolve the caller through normal review, then rerun gardening and checks.

```text
status: refused
references: tests/fixtures/retry.ridl -> docs/wip/specs/retry-budget.md; real retry-policy rationale
checks: not run; blocking reference identified
wip: assigned retry spec and plan retained
```

### D8

Check the project's actual `notes/inflight/` convention and relative links in tracked files, independently of the feature-scoped project-doc scan. Resolve the design link relative to `docs/design/client.md`: it targets `notes/inflight/specs/retry.md`, so it is a lasting WIP citation. Zero `docs/wip/` matches does not clear it. Retain both assigned files. Ask the dispatcher to establish an appropriate durable bare-slug decision target or local explanation with the human; do not blindly rewrite to archive or stamp AD identifiers.

```text
status: refused
references: docs/design/client.md -> ../../notes/inflight/specs/retry.md (notes/inflight/specs/retry.md)
checks: not run; blocking reference identified
wip: notes/inflight/specs/retry.md and notes/inflight/plans/retry.md retained
```
