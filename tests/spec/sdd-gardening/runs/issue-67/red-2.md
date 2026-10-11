### D1

Keep the accepted rationale and unlimited-retry alternative in `docs/wip/specs/retry-budget.md`, including an Alternatives considered section and available trace links. Do not create the durable decision before implementation: shipped records describe as-built behavior, and gardening requires green tests. During implementation I would use `// A bounded retry budget prevents this request from retrying indefinitely.` This explains the policy locally without depending on transient working memory. Once the feature passes its tests, dispatch the gardener with the exact spec and plan to extract the decision and its rationale into the project's durable decision layout.

### D2

Leave `docs/specification/http-client.md` and `docs/design/http-client.md` describing the shipped client. Put the agreed requirement and interface in `docs/wip/specs/retry-budget.md`, and reference their sections from `docs/wip/plans/retry-budget.md`. Express status explicitly there, for example: `Agreed for implementation; not implemented or verified.` The requirement excerpt could read `The planned client limits each request to the configured retry budget.` The interface excerpt should describe the agreed configuration and behavior without inventing signatures. The plan links to those working sections. After implementation and green tests, gardening reconciles their content against code and tests before updating durable records.

### D3

Omit the comment: `remaining_attempts` and the loop condition already explain why the loop stops. There is no independent decision or background rationale worth extracting into another document. I would create no requirement, design record, decision, or technote for this local explanation, and would not dispatch the gardener for it. If the containing feature has its own Superpowers spec and plan, those remain subject to the normal feature completion workflow; this loop alone does not justify a separate documentation or gardening task.

### D4

Dispatch the gardener for exactly the named pair, noting `docs/wip/other-feature.md` as outside scope. Use the existing decision, editing it only if the feature changes it. Flag the README citation for human resolution; do not edit README or the unrelated WIP. Archive only the pair using the established archive layout. The supplied procedure does not require repairing source and fixture citations or a repository-wide reference gate; existing path-check success does not establish post-archive validity. Report unresolved links explicitly rather than claim a clean branch.

```text
status: partial
records:
  - edited docs/decisions/0007-retry-budget.md (AD-0007), if reconciliation requires it
 divergences: README budget link and other listed citations target working memory moved by archival; human confirmation required
 offers: none
 wip: docs/wip/other-feature.md — disposition unresolved; branch unfinished until human resolution or accepted debt with reason and durable marker
 notes: Archive only the named spec and plan; preserve unrelated WIP and historical archive content.
```

### D5

Dispatch the gardener with the exact retry spec and plan, green-test evidence, existing records, and feature diff. Reconcile existing records in place; change the design paragraph to describe the implemented retry behavior without its obsolete proposed status. Reuse the matching decision. Archive the raw pair in the project's established layout. Leave the old archive citation as historical content. Verify that the pair is gone from WIP; retain placeholders. The WIP plan's durable link needs no repair.

```text
status: done
records:
  - edited docs/design/http-client.md
 divergences: none
 offers: none
 wip: empty
 notes: Existing requirement and AD-0007 match code and tests; raw spec and plan archived using the established layout.
```

### D6

Investigate the failed link against existing decisions and the feature's records. Determine whether it is a typo for a real decision or a documentation gap; do not invent the target. If a correct existing target is established, repair the design link in place and rerun the gate. Until then, report incomplete validation and request clarification if necessary. Preserve the successfully gardened records and archived pair rather than conceal the failure.

```text
status: partial
records:
  - edited docs/design/http-client.md
 divergences: docs/design/http-client.md references nonexistent docs/decisions/missing.md; intended target unresolved
 offers: Confirm the intended existing decision if evidence cannot establish it.
 wip: empty
 notes: just doc-path-check fails; completion remains pending a justified correction and successful rerun. No decision fabricated.
```
