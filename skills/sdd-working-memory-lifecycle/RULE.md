---
schema: 1
name: sdd-working-memory-lifecycle
description: Standing guardrails for Superpowers working memory and durable references. Applies during design, planning, implementation, review, and branch completion.
metadata:
  version: 0.2.4
---

A Superpowers session produces a **spec** and a **plan** — working memory.
Durable engineering records are captured during development and reconciled by
gardening; the working memory itself is transient. Code and tests remain the source of truth — these
records describe the system, they do not drive it.

## Where working memory lives

- Write Superpowers specs and plans under `docs/wip/`. When the work lands and
  durable records are written, move the raw originals to `docs/archive/` — never
  delete them.
- Keep working memory collaborative by tracking `docs/wip/` in git, or private by
  gitignoring it — the gitignore entry is the only switch; do not add a config
  flag. Tracked is the default.
- A skill other than the Superpowers spec/plan flow that stages its own
  transient content in `docs/wip/<name>/` (e.g., an import/migration skill
  writing a staging brief) owns that content's disposition: it must document,
  in its own `SKILL.md`, whether that content is discarded or archived
  verbatim to `docs/archive/<name>/`, and must run that step as part of its
  own completion — not deferred to branch-finish time.

## Garden before a PR lands

- When finishing a branch, run the `sdd-gardening` skill before opening or merging
  a `main`-targeting PR, so `docs/wip/` is empty.
- Treat a non-empty `docs/wip/` on a `main`-targeting branch as unfinished work,
  not a mergeable state.
- This rule ships `wip-gate.sh` as a supporting resource (installed alongside it,
  e.g. `.claude/rules/sdd-working-memory-lifecycle/wip-gate.sh`). It is a
  host-agnostic detector: it exits non-zero and lists the ungardened files when
  tracked `docs/wip/` still holds work (`.gitkeep` and the folder's own
  `README.md` are ignored placeholders). On a
  host that supports it, surface the result as a **blocking review thread** that
  stays unresolved until the work is gardened away or the debt is explicitly
  accepted — accepted debt must be made visible to approvers (a reason plus a
  durable marker), so the standing approval requirement, not a silent dismiss, is
  what holds the line.

## Durable records — the taxonomy

- Capture lasting content in four artifact homes: `docs/specification/`
  (requirements), `docs/design/` (architecture — interfaces and components),
  `docs/decisions/` (decision records), and `docs/technotes/` (explanatory
  notes).
- Keep `docs/decisions/` and `docs/technotes/` distinct: a **decision** is
  normative — it binds downstream work and is traced to what it affects; a
  **technote** is informative — it explains, and nothing depends on it.
- When new work changes a recorded decision or design, edit the existing record in
  place; create a new record only for a genuinely new topic.
- Keep system-wide architecture human-curated; let gardening link to it or offer
  to create it, never auto-rewrite it.
- Shipped docs — the project READMEs, `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING`,
  `NOTICE(S)`, and the `docs/` records — describe the system **as-built**.
  Mark proposed or unimplemented content explicitly in durable records; keep it
  distinct from shipped behavior and reconcile it against code+tests before merge.
  Code+tests are the SSOT: when a shipped doc
  and the code diverge, gardening **surfaces** the drift for a human to reconcile —
  it does not autonomously rewrite a human-facing doc to match code.

## Capture decisions at the source

- During design and planning, record accepted decisions and useful requirements
  or interface descriptions in their durable homes; update existing records for
  the same topic. Keep exploration and execution steps in WIP.
- Distinguish an accepted decision from its implementation status; an early
  record does not establish implemented behavior or replace the TDD cycle.
- When writing a spec, record an "Alternatives considered" section and the trace
  links (`Satisfies:`, related ids) so the decision rationale survives into the
  gardened records.

## Lasting references

- When writing code, tests, or durable documentation, reference useful durable
  records directly; use a local explanation when no separate record adds value.
  Do not create documents solely to provide a link.
- Keep citations to WIP files or directories within WIP; this applies to prose,
  code spans, Markdown links, fixtures, and source comments. Preserve historical
  citations already in the archive; descriptions of the lifecycle's directory
  conventions and literal test inputs are not dependencies on working content.
- During review and before archiving, report lasting references to WIP as
  blockers even when their paths exist. Resolve their meaning before completion;
  replacing a WIP path with an archive path does not resolve the dependency.
