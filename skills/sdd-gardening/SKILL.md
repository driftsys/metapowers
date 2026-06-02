---
schema: 1
name: sdd-gardening
description: Use when finishing a development branch or before opening/merging a PR while Superpowers working memory (wip/superpowers/ specs and plans) is still present, or when asked to garden, consolidate, or write up specs/plans into durable docs/decisions. Also when CI reports a non-empty wip/superpowers/.
metadata:
  version: 0.1.0
---

## Overview

Gardening turns a finished Superpowers session's working memory (the spec and
plan in `wip/superpowers/`) into the durable record triad — `docs/spec/`,
`docs/decisions/`, `docs/design/` — and moves the raw spec/plan to `archive/`.
Because the work is context-heavy (it reads the spec/plan, the merged code +
tests, and the existing `docs/` records), this skill **dispatches the
`sdd-gardener` subagent** to do it and surfaces the subagent's summary. See the
`working-memory-lifecycle` rule for the standing guardrails.

## When to use

- Finishing a branch / before a `main`-targeting PR, while `wip/superpowers/` is
  non-empty.
- The user asks to garden, consolidate, or promote specs/plans into ADR / SDD /
  requirements.
- Run **after tests are green** — gardening reconciles records against as-built
  code, so it needs the finished implementation.

## Procedure

1. **Detect mode.** `git check-ignore -q wip/superpowers/` → if ignored, this is
   private mode (no archive step, no CI gate); otherwise collaborative.
2. **Gather inputs** for the subagent: the `wip/superpowers/` spec + plan; the
   merged code + tests; the existing `docs/spec`, `docs/decisions`, `docs/design`.
   If this same session ran the brainstorming, include that discussion — it
   carries the considered-options rationale directly.
3. **Dispatch the `sdd-gardener` subagent** with those inputs. (Claude Code:
   Agent/Task tool, `subagent_type: sdd-gardener`. Other clients: the equivalent
   subagent dispatch.) Do not garden inline — the point is to keep this session's
   context lean.
4. **Relay its summary** to the user: records created/edited (paths + `AD-NNNN`
   ids) and flagged divergences. Read the actual files only if needed.
5. **Resolve its offers with the human:** a requirement gap to fill (author via
   the project's requirement tool — markspec if installed, else EARS prose), or a
   system-architecture doc to create/update. Never fabricate or auto-create.
6. **Verify** `wip/superpowers/` is empty (collaborative mode), then commit the
   gardened records + archived raw.

## Common mistakes

- Gardening before tests pass — records then describe as-planned, not as-built.
- Doing the work inline instead of in the subagent — defeats the context saving.
- Auto-creating requirements/architecture instead of offering — see the rule.
