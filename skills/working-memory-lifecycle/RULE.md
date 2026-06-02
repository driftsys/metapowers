---
schema: 1
name: working-memory-lifecycle
description: Standing guardrails for Superpowers working memory — where specs/plans live, gardening them into durable docs before a PR lands, and editing those records in place. Applies when authoring a spec/plan or finishing a branch.
metadata:
  version: 0.1.0
---

A Superpowers session produces a **spec** and a **plan** — working memory.
Durable engineering records are *gardened* from that working memory; the working
memory itself is transient. Code and tests remain the source of truth — these
records describe the system, they do not drive it.

## Where working memory lives

- Write Superpowers specs and plans under `wip/superpowers/specs/` and
  `wip/superpowers/plans/`.
- Keep working memory collaborative by tracking `wip/superpowers/` in git, or
  private by gitignoring it — the gitignore entry is the only switch; do not add a
  config flag.

## Garden before a PR lands

- When finishing a branch, run the `sdd-gardening` skill before opening or merging
  a `main`-targeting PR, so `wip/superpowers/` is empty.
- Treat a non-empty `wip/superpowers/` on a `main`-targeting branch as unfinished
  work, not a mergeable state.
- This rule ships `wip-gate.sh` as a supporting resource (installed alongside it,
  e.g. `.claude/rules/working-memory-lifecycle/wip-gate.sh`). Wire it into CI as a
  required check on `main`-targeting branches to enforce the invariant: it fails
  when tracked `wip/superpowers/` still holds ungardened work (`.gitkeep`
  placeholders are ignored).

## Durable records — the triad

- Garden working memory into `docs/spec/` (requirements + feature architecture),
  `docs/decisions/` (decisions, each with an `AD-NNNN` id), and `docs/design/`
  (detailed design).
- When new work changes a recorded decision or design, edit the existing record in
  place; create a new record only for a genuinely new topic.
- Keep system-wide architecture human-curated; let gardening link to it or offer
  to create it, never auto-rewrite it.

## Capture decisions at the source

- When writing a spec, record an "Alternatives considered" section and the trace
  links (`Satisfies:`, related ids) so the decision rationale survives into the
  gardened records.
