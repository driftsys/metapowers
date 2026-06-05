# AD-0003: Durable records use a by-artifact taxonomy

**Context.** Gardening routes working memory into durable `docs/` records. The
homes must be unambiguous, and a reader must never mistake binding guidance for
background.

**Options.** A concern-first top-level layout (`requirements/ architecture/
verification/`); a 3-bucket `spec/ decisions/ design/`; a by-artifact taxonomy
that separates normative decisions from informative notes.

**Decision.** Use four artifact homes: `docs/specification/` (requirements),
`docs/design/` (architecture — interfaces and components), `docs/decisions/`
(decision records — normative, binding, traced), and `docs/technotes/`
(explanatory notes — informative, non-binding). Full words only —
`specification`, not `spec`. Architecture lives in `design/`, not in
`specification/`. There is no separate `verification/` home: tests and code are
the source of truth, so verification lives where it runs, not in a doc bucket.

**Consequences.** Good — each artifact has one home; the decision/technote split
keeps "binding" legible by location alone; aligns the technote with AGENTS.md.
Bad — renames the technote's earlier `spec/` and `design/` buckets, so existing
references must be updated.

Supersedes: the working-memory-lifecycle technote's `spec/ decisions/ design/`
layout. Related: [AD-0001](0001-working-memory-location-and-mode.md)
