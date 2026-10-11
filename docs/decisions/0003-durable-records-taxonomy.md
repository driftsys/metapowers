# AD-0003: Durable records use a by-artifact taxonomy

**Context.** Gardening routes working memory into durable `docs/` records. The
homes must be unambiguous, and a reader must never mistake binding guidance for
background. Code and lasting documents also need stable reference targets before
working memory is archived.

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

Capture accepted decisions and useful requirements or design descriptions in
these homes during development, updating existing records for the same topic.
Mark proposed or unimplemented material explicitly; accepting a decision does
not establish its implementation. Code and durable documentation reference these
records directly, or explain a local choice without creating an unnecessary
record. Citations to temporary working content stay within working memory.
Gardening reconciles durable records with code and tests, extracts remaining
lasting value, and archives the raw spec and plan. It blocks on lasting WIP
citations rather than automatically repointing them to the archive. Historical
archive citations remain untouched.

**Consequences.** Good — each artifact has one home; the decision/technote split
keeps "binding" legible by location alone; aligns the technote with AGENTS.md.
Bad — renames the technote's earlier `spec/` and `design/` buckets, so existing
references must be updated. Early records also need explicit implementation
status and final reconciliation so proposed behavior is not presented as shipped.

Supersedes: the working-memory-lifecycle technote's `spec/ decisions/ design/`
layout. Related: [AD-0001](0001-working-memory-location-and-mode.md)
