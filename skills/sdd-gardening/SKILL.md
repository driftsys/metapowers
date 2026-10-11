---
schema: 1
name: sdd-gardening
description: Use when finishing a development branch or before opening/merging a PR while Superpowers working memory (docs/wip/ specs and plans) is still present, or when asked to garden, consolidate, or write up specs/plans into durable docs/ records. Also when CI reports a non-empty docs/wip/.
metadata:
  version: 0.2.4
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

Before gathering feature material, resolve the intended checkout with
`git rev-parse --show-toplevel` from the active feature workspace and record its
absolute root as `worktree`. Keep every subsequent file and Git operation scoped
to that root; the primary checkout and Git common directory are not substitutes.
An explicitly assigned primary checkout is also valid.

When entering a newly created worktree, run the repository's documented setup
there before execution or dispatch. Follow `AGENTS.md`/`CLAUDE.md` and
`CONTRIBUTING*`; if no setup is documented but a root `bootstrap` exists, run
`./bootstrap`. Package-manager detection alone is insufficient. Do not repeat
setup already completed in this worktree; report a setup failure before proceeding.

If the named spec or plan is missing, copy only the selected files from an
identified source checkout, preserving their relative paths and source originals.
Ignored, untracked and uncommitted working memory does not travel with
`git worktree add`. Verify the copies before use; leave unrelated WIP behind.
If a destination already exists, keep it: reuse an identical copy, but surface
different contents for resolution before dispatch instead of overwriting or
choosing a version yourself. If the source is unknown, ask for it. Transfer does
not authorize cleanup in the source checkout.

1. **Detect mode.** `git check-ignore -q docs/wip/` → if ignored, this is
   private mode (no archive step, no CI gate); otherwise collaborative.
2. **Gather inputs** for the subagent: this feature's Superpowers spec + plan in
   `docs/wip/`, each named by path (`docs/wip/specs/` + `docs/wip/plans/` by
   default, or the project's own layout, such as dated files in a flat
   `docs/wip/`) — the only material this flow reconciles. Name exactly one spec
   and one plan; if you cannot tell which files are this feature's, ask the
   human instead of guessing. Also gather the merged code + tests, and the
   existing `docs/specification/`, `docs/design/`, `docs/decisions/`,
   `docs/technotes/` records. If any other `docs/wip/<name>/` directory, or any
   other `docs/wip/` file outside the pair (except the `README.md` and
   `.gitkeep` placeholders), is present, mention its existence to the subagent
   when dispatching (so the subagent can name it in its report), but do not hand
   it over as spec/plan material, and do not pre-decide its disposition
   yourself — do not instruct the subagent to archive, discard, move, or
   otherwise resolve it, however confidently its (ir)relevance to the current
   feature can be inferred. If this same session ran the brainstorming, include
   that discussion — it carries the considered-options rationale directly. Also
   gather, for the consistency pass, the canonical project docs — `README*`
   (root + dirs the feature touched), `AGENTS.md`/`CLAUDE.md`, `CONTRIBUTING*`,
   `NOTICE(S)` — and the feature's code+test diff (`git diff main...HEAD`) so
   the gardener can diff-gate and feature-scope.
3. **Dispatch the `sdd-gardener` subagent** with those inputs. (Claude Code:
   Agent/Task tool, `subagent_type: sdd-gardener`. Other clients: the equivalent
   subagent dispatch.) Include a required `worktree: <absolute checkout root>`
   field and the named spec/plan paths relative to it; instruct the gardener to
   verify that root before reading feature material or writing. Set the child
   working directory when the client supports it, and pass the root in the prompt
   regardless of that setting. Do not garden inline — the point is to keep this
   session's context lean.
4. **Relay its summary** to the user: records created/edited (paths, plus
   `AD-NNNN` ids where the project uses them) and flagged divergences —
   including any project-doc drift the gardener surfaced. Read the actual files
   only if needed.
5. **Resolve its offers with the human:** a requirement gap to fill (author it as
   a durable record — descriptive prose by default, or in whatever substrate an
   inherited project rule prescribes), a system-architecture doc to
   create/update, or a project-doc line the gardener flagged but never edits (a
   stale fact in `README`/`AGENTS`, or a policy/legal line in
   `CONTRIBUTING`/`AGENTS`/`NOTICE(S)`) — apply the fix or accept it yourself.
   Never fabricate or auto-create.
6. **Verify** this feature's spec + plan are gone from `docs/wip/`
   (collaborative mode), then commit the gardened records + archived raw. A
   `docs/wip/<name>/` directory, or any other `docs/wip/` file, outside the
   spec/plan pair is not this skill's to resolve — relay it to the human as-is
   (step 4). Do not garden it, do not delete it, and do not archive, move, or
   relocate it in any way (including via `git mv` to `docs/archive/`) — its
   disposition is not this skill's decision, however confidently its
   (ir)relevance to the current feature can be inferred. While it keeps
   `docs/wip/` non-empty, the `sdd-working-memory-lifecycle` rule treats the
   branch as unfinished until the human gardens it or accepts the debt with a
   reason and a durable marker (for example an entry in a ledger such as
   `docs/wip/README.md`); tell the human so, and do not write that marker
   yourself.

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
