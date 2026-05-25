---
name: Skill topic (rule + skill + agent)
about: Author a topic-scoped triple — rule, skill, and reviewer agent — using the writing-skills RED-GREEN-REFACTOR discipline
title: "Topic: <topic-name> — rule + skill + agent"
labels: ["story"]
assignees: []
---

## Topic

<!-- e.g. architecture, security-review, tech-writing, diagramming, product-discipline -->

## Triple to produce

Not every topic needs all three. Tick what applies and delete the rest.

- [ ] `<topic>` **RULE.md** — always-loaded invariants for this domain
- [ ] `<topic>` **SKILL.md** — on-demand procedure the main agent runs inline
- [ ] `<topic>-reviewer` (or similar) **AGENT.md** — specialist subagent the main agent dispatches to

## Why each piece exists (fill in)

- **Rule**: which invariant must hold across every session? (Skip if none.)
- **Skill**: what triggering condition activates it? what failure mode does it prevent?
- **Agent**: what work is worth handing off to a specialist instead of doing inline? (Skip if none.)

## Workflow

Each phase should produce a visible artifact (commit, branch, PR comment, scratch note in `.scratch/superpowers/`).

### 1. Brainstorm

Use `superpowers:brainstorming`. Resolve before writing anything:

- [ ] User intent: what real problem prompts loading this content?
- [ ] Boundary: what's IN scope, what's OUT (delegated to other skills)?
- [ ] Triggering condition (one sentence, starts with "Use when…")
- [ ] Failure mode if absent (be concrete — name the rationalization or shortcut an agent would take)
- [ ] Minimum viable shape (rule, skill, agent — or any subset)

### 2. RED — baseline without the content

Use `superpowers:writing-skills` testing methodology.

- [ ] Write 2–3 pressure scenarios per item to be authored
- [ ] Dispatch baseline subagents (no skill/rule/agent loaded), capture verbatim rationalizations and choices
- [ ] Record the baseline as a scratch note (PR description or `.scratch/superpowers/`)

### 3. GREEN — write the content

Use `superpowers:writing-skills` for each item:

- [ ] **Description** starts with `Use when…`; describes triggering conditions ONLY; no workflow summary; third-person; under ~500 chars
- [ ] **Body** follows the SKILL.md template — Overview / When to Use / Core Pattern / Quick Reference / Implementation / Common Mistakes (adapt for RULE.md and AGENT.md as needed)
- [ ] Re-run the RED scenarios with the content loaded; verify the agent now complies
- [ ] `upskill lint --strict` passes; `upskill fmt` is idempotent

### 4. REFACTOR — close loopholes

- [ ] Identify NEW rationalizations the agent surfaces under pressure
- [ ] Add explicit counters, a Red Flags list, a rationalization table
- [ ] Re-test until bulletproof (no new rationalizations appear)

### 5. Ship

- [ ] One PR per item, OR one PR for the tightly-coupled triple (your call — document in the PR which)
- [ ] PR description links to the brainstorm artifact and the RED→GREEN evidence
- [ ] Bundle manifest update (`skills/metapowers.bundle.yaml`) is deferred to a final integration PR — do NOT bundle-bump in topic PRs

## Acceptance Criteria

- [ ] Description matches `superpowers:writing-skills` `Use when…` format
- [ ] Body follows the writing-skills SKILL.md template
- [ ] PR description shows at least one RED→GREEN cycle (baseline scenario, baseline behavior, post-skill behavior)
- [ ] `upskill lint --strict` passes
- [ ] `upskill fmt` idempotent
- [ ] No bundle-manifest changes in this PR

## Out of scope

- Bundle manifest update — final integration PR
- Cross-references to other in-flight topic skills — forward refs are fine
- Reworking unrelated `docs/` or other skills

## References

- Reference scaffold (do not merge): #10
- Original phase-1 plan (kept for traceability): `docs/plans/2026-05-24-phase-1-curated-skills.md` (lives only on the reference branch)
- Skill authoring discipline: `superpowers:writing-skills`
- Brainstorming discipline: `superpowers:brainstorming`
