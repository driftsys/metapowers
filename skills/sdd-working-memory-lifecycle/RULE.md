---
schema: 1
name: sdd-working-memory-lifecycle
description: Standing guardrails for Superpowers working memory — where specs/plans live, gardening them into durable docs before a PR lands, and editing those records in place. Applies when authoring a spec/plan or finishing a branch.
metadata:
  version: 0.2.1
---

A Superpowers session produces a **spec** and a **plan** — working memory.
Durable engineering records are _gardened_ from that working memory; the working
memory itself is transient. Code and tests remain the source of truth — these
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
  tracked `docs/wip/` still holds work (`.gitkeep` placeholders ignored). On a
  host that supports it, surface the result as a **blocking review thread** that
  stays unresolved until the work is gardened away or the debt is explicitly
  accepted — accepted debt must be made visible to approvers (a reason plus a
  durable marker), so the standing approval requirement, not a silent dismiss, is
  what holds the line.

## Durable records — the taxonomy

- Garden working memory into four artifact homes: `docs/specification/`
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
  Forward-looking concepts stay in `docs/wip/` until implemented and gardened in;
  they do not leak into shipped docs. Code+tests are the SSOT: when a shipped doc
  and the code diverge, gardening **surfaces** the drift for a human to reconcile —
  it does not autonomously rewrite a human-facing doc to match code.

## Capture decisions at the source

- When writing a spec, record an "Alternatives considered" section and the trace
  links (`Satisfies:`, related ids) so the decision rationale survives into the
  gardened records.
