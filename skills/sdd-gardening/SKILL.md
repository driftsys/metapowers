---
schema: 1
name: sdd-gardening
description: Use when finishing a development branch or before opening/merging a PR while Superpowers working memory (docs/wip/ specs and plans) is still present, or when asked to garden, consolidate, or write up specs/plans into durable docs/ records. Also when CI reports a non-empty docs/wip/.
metadata:
  version: 0.2.2
---

## Overview

Gardening turns a finished Superpowers session's working memory (the spec and
plan in `docs/wip/`) into the durable record taxonomy — `docs/specification/`,
`docs/design/`, `docs/decisions/`, `docs/technotes/` — and moves the raw
spec/plan to `docs/archive/`. Because the work is context-heavy (it reads the
spec/plan, the merged code + tests, and the existing `docs/` records), this skill
**dispatches the `sdd-gardener` subagent** to do it and surfaces the subagent's
summary. See the `sdd-working-memory-lifecycle` rule for the standing guardrails.

## When to use

- Finishing a branch / before a `main`-targeting PR, while `docs/wip/` is
  non-empty.
- The user asks to garden, consolidate, or promote specs/plans into durable
  requirements, design, decisions, or notes.
- Run **after tests are green** — gardening reconciles records against as-built
  code, so it needs the finished implementation.

## Procedure

1. **Detect mode.** `git check-ignore -q docs/wip/` → if ignored, this is
   private mode (no archive step, no CI gate); otherwise collaborative.
2. **Gather inputs** for the subagent: the `docs/wip/specs/` + `docs/wip/plans/`
   spec + plan (the only directories this flow reconciles); the merged code +
   tests; and the existing `docs/specification/`, `docs/design/`,
   `docs/decisions/`, `docs/technotes/` records. If any other
   `docs/wip/<name>/` directory is present, mention its existence to the
   subagent when dispatching (so the subagent can name it in its report), but
   do not hand it over as spec/plan material, and do not pre-decide its
   disposition yourself — do not instruct the subagent to archive, discard,
   move, or otherwise resolve it, however confidently its (ir)relevance to the
   current feature can be inferred. If this same session ran the
   brainstorming, include that discussion — it carries the considered-options
   rationale directly. Also gather, for the consistency pass, the canonical
   project docs — `README*` (root + dirs the feature touched),
   `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING*`, `NOTICE(S)` — and the feature's
   code+test diff (`git diff main...HEAD`) so the gardener can diff-gate and
   feature-scope.
3. **Dispatch the `sdd-gardener` subagent** with those inputs. (Claude Code:
   Agent/Task tool, `subagent_type: sdd-gardener`. Other clients: the equivalent
   subagent dispatch.) Do not garden inline — the point is to keep this session's
   context lean.
4. **Relay its summary** to the user: records created/edited (paths + `AD-NNNN`
   ids) and flagged divergences — including any project-doc drift the gardener
   surfaced. Read the actual files only if needed.
5. **Resolve its offers with the human:** a requirement gap to fill (author it as
   a durable record — descriptive prose by default, or in whatever substrate an
   inherited project rule prescribes), a system-architecture doc to
   create/update, or a project-doc line the gardener flagged but never edits (a
   stale fact in `README`/`AGENTS`, or a policy/legal line in
   `CONTRIBUTING`/`AGENTS`/`NOTICE(S)`) — apply the fix or accept it yourself.
   Never fabricate or auto-create.
6. **Verify** `docs/wip/specs/` and `docs/wip/plans/` are empty (collaborative
   mode), then commit the gardened records + archived raw. A `docs/wip/<name>/`
   directory outside that pair is not this skill's to resolve — see the
   `sdd-working-memory-lifecycle` rule; relay it to the human as-is (step 4).
   Do not garden it, do not delete it, and do not archive, move, or relocate
   it in any way (including via `git mv` to `docs/archive/`) — its
   disposition is not this skill's decision, however confidently its
   (ir)relevance to the current feature can be inferred.

## Common mistakes

- Gardening before tests pass — records then describe as-planned, not as-built.
- Doing the work inline instead of in the subagent — defeats the context saving.
- Auto-creating requirements/architecture instead of offering — see the rule.
- Naming a specific authoring tool — the substrate is descriptive prose unless an
  inherited project rule prescribes otherwise.
- Editing a human-facing project doc (`README`/`AGENTS`/`CONTRIBUTING`/`NOTICE(S)`)
  during the consistency pass — it flags drift; the human applies the fix, because
  a stale-looking fact may be intended behaviour the code got wrong.
- Auditing the whole repo's docs instead of feature-scoping the consistency pass
  via the diff-gate — re-flags unrelated pre-existing drift.
