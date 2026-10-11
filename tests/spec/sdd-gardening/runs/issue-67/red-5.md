### D1

Keep the accepted rationale and rejected unlimited-retry option in `docs/wip/specs/retry-budget.md` for now, including trace links and the accepted planning decision. Implementation is incomplete, so do not dispatch the gardener or promote the decision into shipped documentation. During implementation I would use `// Keep retries within the bounded budget to prevent indefinite retrying.` This expresses the rationale without a fragile reference to transient working memory. Once implementation and tests are green, garden the rationale into a durable decision with the documented alternatives and affected requirement links.

### D2

Leave `docs/specification/http-client.md` and `docs/design/http-client.md` describing the shipped client. Add the agreed retry requirement and interface description to this feature's WIP spec, with an explicit label such as `Planned: retries are agreed but not implemented or tested.` Have the WIP implementation plan link to the relevant spec sections, for example `Implement the planned retry requirement and interface in ../specs/retry-budget.md#retry-interface`. These are planning references, not shipped claims. Do not dispatch gardening before tests pass. After implementation, reconcile and garden the agreed material against code and tests, raising any missing requirement as an offer.

### D3

Omit the comment: the loop condition and `remaining_attempts` already explain that execution stops at zero. There is no additional rationale to preserve. Create no decision, technote, requirement, or design record for this detail, and dispatch no gardener solely for it. Continue implementation and its tests. If finishing the broader feature later leaves its named spec and plan in WIP, run the normal gardening procedure for that feature after tests pass; that does not make this obvious local control-flow detail a durable record candidate.

### D4

Dispatch gardening for only the named pair after confirming collaborative mode, supplying code/tests, existing records, canonical docs and feature diff; explicitly note `docs/wip/other-feature.md` as outside scope. Edit the existing retry decision in place and reconcile feature records, then archive only the pair. Report the README's resulting stale link for human resolution; never edit README autonomously. The other feature remains untouched, as does historical archive material. The supplied instructions do not establish a comprehensive lasting-reference rewrite gate; the current path-check success cannot establish post-archive validity. Recheck it after changes and surface failures without claiming release readiness.

```text
status: partial
records:
  - edited docs/decisions/0007-retry-budget.md (AD-0007)
divergences: README.md Budget link becomes stale after archival; human resolution needed
offers: none
wip: docs/wip/other-feature.md — disposition unresolved; leave for the human; branch unfinished unless gardened or debt accepted with reason and durable marker
notes: Archive only the named pair; verify paths after archival and report failures.
```

### D5

Dispatch the gardener with the named pair, green code/tests, existing records and scoped diff. Reconcile the existing records in place, replacing `Proposed; not implemented` in the feature design with an as-built description supported by code/tests. Preserve the existing durable decision citation in code. Archive the raw pair using the established archive layout; preserve its internal decision link and leave the historical archived WIP citation alone. Verify that this pair has left WIP and check applicable documentation validation before reporting completion.

```text
status: done
records:
  - edited docs/design/http-client.md
divergences: none
offers: none
wip: empty
notes: Existing requirement and AD-0007 match code/tests; raw spec and plan archived using the established layout.
```

### D6

Do not claim a clean completed finish while the applicable documentation gate fails. Inspect the referencing design paragraph and existing decision records to determine whether the link is a typo or an unresolved documentation gap. Correct an unambiguous record link to an existing supported target; otherwise flag the uncertainty for human resolution. Never invent a decision to satisfy a path check. Re-run the gate after any supported correction. Until resolved, return the failure explicitly, with the actual archival state reported rather than assumed.

```text
status: partial
records:
  - edited docs/design/http-client.md (as-built retry description)
divergences: docs/design/http-client.md references nonexistent docs/decisions/missing.md; intended target unresolved
offers: Human confirmation of intended decision target if inspection cannot establish it
wip: empty
notes: Named pair archived; just doc-path-check fails. Completion remains unverified pending supported correction and a passing rerun.
```
