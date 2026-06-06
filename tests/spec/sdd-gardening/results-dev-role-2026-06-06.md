# sdd-gardening dev-role results — 2026-06-06 (substrate-seam RED→GREEN)

Run for issue #39 (substrate-neutral gardener + shared-vocabulary override seam).
Verifies the migrated `sdd-gardening` SKILL + `sdd-gardener` AGENT on the
ratified `docs/wip/` + four-home taxonomy, and the authoring-substrate seam:
prose by default, overridable by an inherited always-loaded project rule.

Environment: `claude` 2.1.118, scoped `--allowedTools` (no
`--dangerously-skip-permissions`). Sandboxes built by `setup-sandbox.sh` into
`/tmp`. Same dev-role prompt in every run (it never mentions gardening,
substrates, or paths). Observer = the metapowers worktree.

## RED baseline

### Deterministic gate (items, pre-edit)

`grep -rnE 'wip/superpowers|docs/spec/|\btriad\b|markspec|adr-tools|MADR|EARS' skills/sdd-gardening/`
matched 19 lines across `SKILL.md` + `AGENT.md` (old paths, "triad", and the
named substrates markspec / adr-tools / MADR / EARS). **RED.** After the Task 3
edit the same grep is empty (`exit=1`). **GREEN.**

### Live RED (old items + ACME override) — `/tmp/sdd-red-s1`, `override` mode

Ran the dev-role prompt against the **un-migrated** gardener with the ACME-SDD
override rule installed. Finding (more nuanced than "fails"):

- The dev-role agent **dispatched the `sdd-gardener` subagent**, and the subagent
  honored "the project's ACME-SDD substrate and four-home taxonomy — **not the
  skill defaults**." So the inherited `.claude/rules/` override **reaches the
  subagent** even when the gardener item's own (old) vocabulary contradicts it.
  This answers the seam's open risk (design spec §6) affirmatively.
- BUT the old item's **decision convention leaked**: decisions landed in a single
  topic-grouped `docs/decisions/retry-policy.md` (with `AD-0001/2/3` sections) —
  the pre-#39 "one file per topic" model.

So the live RED is not a clean failure; it instead pins the **behavioral delta**
the Task 3 edit must produce: **one decision per file** (`<NNNN-slug>.md`).
The planted 5-vs-3 retry-budget divergence was correctly flagged (reconciliation
intact).

## GREEN

Items migrated (Task 3, commit `e6fcdda`). Sandboxes re-rendered the migrated
gardener (`docs/specification` vocab confirmed in the installed agent).

### S1 — override → substrate — `/tmp/sdd-green-s1`, `override` mode → **PASS**

| # | Criterion                  | Verdict                                                                                                                                                                       |
| - | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | Activation                 | `sdd-gardening` fired at wrap-up, unprompted                                                                                                                                  |
| 2 | Delegation                 | `sdd-gardener` **subagent** dispatched (not inline)                                                                                                                           |
| 3 | Return contract            | digest only (records / divergence / offer), no raw dumps                                                                                                                      |
| 4 | Four homes                 | `docs/specification/retry-backoff.md`, `docs/design/retry-backoff.md`, 3× `docs/decisions/000N-*.md`; `technotes` empty (nothing informative left over)                       |
| 5 | **Decisions one-per-file** | `0001-exponential-backoff-over-fixed-interval.md`, `0002-full-jitter.md`, `0003-no-third-party-retry-library.md` — the RED→GREEN delta vs the topic-grouped `retry-policy.md` |
| 6 | **Substrate fingerprint**  | `<!-- substrate: ACME-SDD v1 -->` is the **first line of all 5** durable records; spec uses `REQ-<n>:` one-per-line                                                           |
| 7 | Archive + empty wip        | raw `git mv`'d to `docs/archive/{specs,plans}/`; `docs/wip/` holds only `.gitkeep`                                                                                            |
| 8 | WIP-gate                   | `docs/wip/ is clean.` exit 0                                                                                                                                                  |
| 9 | Reconciliation             | planted 5-vs-3 budget divergence recorded as-built (3); original preserved in `docs/archive/`; system-architecture doc **offered, not auto-created**                          |

### S2 — bare → prose — `/tmp/sdd-green-s2`, `green` mode (no override) → **PASS**

| #   | Criterion                          | Verdict                                                                                                                                                                    |
| --- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1–3 | Activation / delegation / contract | same as S1 (fired, subagent dispatched, digest only)                                                                                                                       |
| 4   | Four homes                         | `docs/specification/`, `docs/design/`, 1× `docs/decisions/0001-*.md`; `technotes` empty                                                                                    |
| 5   | Decisions one-per-file             | `0001-exponential-backoff-with-full-jitter.md` (NNNN-slug, in-doc `# AD-0001`)                                                                                             |
| 6   | **No fingerprint**                 | `grep -rl 'substrate: ACME-SDD v1' docs` → **nothing**; first lines are descriptive headings (`# Specification:`, `# Design:`, `# AD-0001:`); requirements are plain prose |
| 7–8 | Archive / wip / gate               | archived; `docs/wip/` only `.gitkeep`; gate exit 0                                                                                                                         |
| 9   | Reconciliation                     | 5-vs-3 divergence flagged, as-built (3) recorded                                                                                                                           |

## Verdict

**Both cases GREEN.** The S1↔S2 contrast is the load-bearing evidence: the ACME
fingerprint appears **only** when the override rule is installed (S1) and is
**absent** without it (S2) — so an inherited, shared-vocabulary project rule, not
chance, drives the gardener's substrate, and **descriptive prose is the default**.
Issue #39 acceptance satisfied:

- override repo → authors in that substrate (S1) ✅
- bare repo → descriptive prose (S2) ✅
- items carry zero substrate-tool names / zero `wip/superpowers`/`docs/spec` stragglers (deterministic gate) ✅

## Notes / observed variance (not failures)

- **Decision granularity differs by run** — S1 extracted 3 decisions, S2 extracted
  1 (folding jitter into the backoff decision). Both obey one-decision-per-file;
  how many distinct decisions to split is gardener judgment, expected to vary.
- **S2 phrasing** — the gardener described its prose requirements as "EARS"; that
  is a phrasing style, still plain Markdown prose with no fingerprint. The items
  themselves name no substrate (verified by the gate); the runtime style choice
  is the model's, not the item's.
- **Subagent reach confirmed** — across RED, S1, and S2 the `sdd-gardener`
  subagent was dispatched and the inherited rules shaped its output, validating
  the no-`skills:`-preload, inheritance-only seam.
