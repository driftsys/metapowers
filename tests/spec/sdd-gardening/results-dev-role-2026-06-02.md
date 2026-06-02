# sdd-gardening — dev-role end-to-end run, 2026-06-02

Harness: [dev-role-harness.md](dev-role-harness.md). Each run is a fresh,
headless `claude -p` session (Claude Code 2.1.118, scoped `--allowedTools`, no
`--dangerously-skip-permissions`) in a throwaway sandbox built by
`setup-sandbox.sh`. The metapowers items are installed into the sandbox's
`.claude/` via `upskill add` (0.7.1) — a **genuine live registry**, the gap the
[triggering battery](results-2026-06-02.md) could not cover.

Runs: GREEN ×4 (items present), RED ×2 (items absent). The first RED was
discarded (harness bug — see Harness self-correction); GREEN #2 surfaced the
convention/gate findings; GREEN #3 confirmed convergence after the item fixes.

> **Agent rename (#21).** Mid-PR, #21 landed on main: it co-located the gardening
> agent into the skill directory and renamed it `sdd-gardener` → `sdd-gardening`
> (`subagent_type: sdd-gardening`; the agent now shares the skill's name). GREEN
> #1–#3 ran against the old `sdd-gardener`; after rebasing onto #21, **GREEN #4
> re-validated against the renamed, co-located agent** — activation, dispatch
> (`subagent_type: sdd-gardening`), the digest contract, the triad, the archive,
> and the gate all still hold. The representative digest below is from GREEN #4.

## Live-registry confirmation

A read-only probe in a GREEN sandbox confirmed all three items are live, not
handed-in:

- `sdd-gardening` skill discovered as a project skill.
- the co-located `sdd-gardening` agent available as a subagent type
  (`subagent_type: sdd-gardening`).
- `working-memory-lifecycle` rule auto-loaded — Claude Code reads
  `.claude/rules/*.md` natively (no `CLAUDE.md` import needed).

## Verdicts — GREEN (5/5 acceptance criteria met; 7/7 harness criteria pass)

| # | Criterion             | Observed                                                                                                                                        | Verdict                              |
| - | --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| 1 | Activation at wrap-up | `Skill -> sdd-gardening` invoked without the prompt mentioning gardening; agent cited `.claude/rules/working-memory-lifecycle.md` as the reason | PASS                                 |
| 2 | Delegation            | `Agent -> subagent_type: sdd-gardening` (dispatched, not inline; GREEN #1–#3 dispatched the then-named `sdd-gardener`)                          | PASS                                 |
| 3 | Return contract       | Digest with status/records/divergences/offers/wip/notes, ~25 lines, no raw file dumps (quoted below)                                            | PASS                                 |
| 4 | Triad produced        | `docs/spec/retry-backoff.md`, `docs/decisions/<topic>.md` (AD-0001…), `docs/design/retry-backoff.md`                                            | PASS                                 |
| 5 | Archive + empty wip   | raw `git mv`-d to `archive/superpowers/{specs,plans}/`; `git ls-files wip/superpowers/` empty                                                   | PASS                                 |
| 6 | WIP-gate red → green  | gate exit 1 before gardening, 0 after                                                                                                           | PASS (after gate fix — see findings) |
| 7 | Reconciliation        | planted spec-R4 (5) vs as-built code (3) divergence **flagged**, plus 2 bonus divergences (jitter param, delay exponent)                        | PASS                                 |

### Captured `sdd-gardening` agent digest (GREEN #4, against the renamed/co-located items)

```text
status: done
records:
  - created docs/spec/retry-backoff.md
  - created docs/decisions/retry-policy.md  (AD-0001, AD-0002, AD-0003, AD-0004)
  - created docs/design/retry-backoff.md
  - git mv wip/superpowers/specs/retry-backoff.md → archive/superpowers/specs/...
  - git mv wip/superpowers/plans/retry-backoff.md → archive/superpowers/plans/...
divergences:
  - max_attempts default: spec (R4) says 5; plan and as-built code both use 3.
    Durable records use 3 (as-built); noted in the requirement and a decision.
  - jitter parameter: not in the plan; as-built adds a `jitter` injectable for
    tests. Recorded in design as a natural extension, not a requirements gap.
offers:
  - no system-wide architecture doc exists — not auto-created.
  - spec R4's original 5 is superseded by the as-built 3; if 5 was intentional,
    that is a product decision to make before merging.
wip: empty (specs/ and plans/ each contain only .gitkeep)
notes: markspec installed but no project.yaml, so EARS prose used for requirements.
```

A clean summary-with-references — the dispatcher acted on it and read files only as
needed. Contract honoured. Note this run exercises **both** item fixes end to end:
the agent leaves `.gitkeep` placeholders and the gate (now tolerating them) reports
green; decisions land in one topic file (`retry-policy.md`); the archive uses
`archive/superpowers/{specs,plans}/`.

## RED contrast (items absent) — confirms the items are load-bearing

Same prompt, same fixture, no metapowers items (Superpowers plugin still present
user-global). The baseline agent invoked `superpowers:finishing-a-development-branch`
and:

- produced **no triad** (`docs/` empty) and **no archive**;
- **deleted** the raw working memory (`git rm` of both wip spec + plan — "scratch
  design docs") — the rationale survives only in git history, exactly the
  disposable-model loss the lifecycle exists to prevent;
- resolved the planted divergence **backwards** — edited the _code_ default
  `3 → 5` to match the spec, treating documentation as authoritative (the inverse
  of "code + tests win").

This directly answers open finding #4 of the triggering eval: **in a live
session, the rule makes finishing → gardening fire (GREEN); finishing alone (RED)
discards the working memory.** Both sandboxes had `finishing-a-development-branch`
available; only GREEN produced durable records.

## Findings fed back into the items (this PR)

1. **WIP-gate false-positive on `.gitkeep` (fixed).** GREEN #2's agent left
   `.gitkeep` placeholders in `wip/superpowers/` after archiving; `git ls-files`
   was non-empty, so the gate stayed **red after a complete gardening** — it would
   block a legitimately-mergeable branch in CI. Fixed `wip-gate.sh` to ignore
   `*/​.gitkeep`; unit-tested (real file → exit 1, placeholder-only → exit 0,
   empty → exit 0).
2. **Decision-file convention was ambiguous (clarified).** GREEN #1 wrote one
   file per decision (`AD-NNNN-slug.md`); GREEN #2 wrote one topic file with
   several `## [AD-NNNN]` sections. Both are greppable, but the cross-run drift is
   a smell. The `sdd-gardening` agent's AGENT.md now pins it: **one file per topic,
   named for the topic, with `## [AD-NNNN]` sections** (matches the tech-note
   template). GREEN #3 and #4 converged on the single topic file.
3. **Archive path was ambiguous (clarified).** GREEN #2 used
   `archive/wip/superpowers/…` (kept the `wip/` component); the tech note says
   `archive/superpowers/…`. AGENT.md step 7 now states the exact target
   (`archive/superpowers/{specs,plans}/`, no `wip/` component). GREEN #3 converged.

## Follow-ups (not in this PR)

- **upskill does not deliver rule/skill supporting resources** — filed
  [driftsys/upskill#199](https://github.com/driftsys/upskill/issues/199).
  Consequence here: `wip-gate.sh` (a `working-memory-lifecycle` resource) never
  reaches a consumer via `upskill add`. The harness sidesteps this by running the
  gate as observer tooling. Independent of #199, decide the gate's delivery home
  (the `RULE.md` body does not even reference the script today).
- **Pressure / REFACTOR scenarios** (time pressure, "just merge it", authority)
  remain the separately-tracked hardening story under epic #16.
- **Honest-gap variant**: a fixture whose spec omits "Alternatives considered",
  to confirm the gardener records "alternatives not documented" rather than
  fabricating.

## Harness self-correction (a REFACTOR find)

The **first** RED run was invalid: `setup-sandbox.sh` originally copied
`wip-gate.sh` into the sandbox as `ci/wip-gate.sh`, and that script's comments and
error message name the `sdd-gardening` skill and the garden→archive procedure. The
RED agent read it (18 transcript refs) and reconstructed gardening from the hint —
so "items absent" was not actually a clean baseline. Fix: the gate is **observer
tooling, never staged in the sandbox**; the observer runs the canonical script
from the metapowers repo with cwd set to the sandbox. GREEN was unaffected (0 gate
references — it activated from the rule), and the clean RED re-run produced the
contrast above.
