# tech-writing (writingpowers Phase-2) dispatch-chain probe — 2026-06-08

Live-registry behavioral eval of the **writingpowers** Phase-2 bundle (v0.2.0):
the four per-mode skills (`tech-writing-howto`, `-explanation`, `-reference`,
`-tutorial`) that the `tech-writing` umbrella's §6 dispatches to. This probe is
narrow: it confirms the **dispatch chain fires end-to-end** for a how-to
request — the main agent invokes `tech-writing` (classify → how-to) AND then
`tech-writing-howto`, and the output follows the how-to shape. One bounded live
`claude -p` run, fail-fast, no retries.

## Environment

- `claude` (Opus 4.8 1M), scoped
  `--allowedTools "Read,Write,Edit,Bash,Glob,Grep,Skill,TodoWrite"`.
- Sandbox built by `setup-sandbox.sh green` into a `mktemp -d`
  (`/private/var/.../tmp.jg4bl3dIXr/sandbox`).
- Prompt (names no style/Diátaxis/mode/dispatch concept):
  _"Write an integration guide for the calc module."_
- Fixture: `calc.py` as-built `add(a, b, *, round_to=None)`, green under
  `test_calc.py`; `docs/usage.md` present (left untouched by this run).
- **Smoke test (Step 0):** `claude -p "Reply with exactly: SMOKE_OK"` returned
  `SMOKE_OK`. Nested non-interactive Claude works here. (macOS has no
  `timeout`/`gtimeout`; no such prefix was used.)

## What installed (Step 1)

`MODE_SKILLS_INSTALLED` — **yes**. All four mode-skill `SKILL.md` files present
under the sandbox `.claude/skills/`:
`tech-writing-{howto,explanation,reference,tutorial}`. The full install (bundle
v0.2.0, resolved locally, `requires: diagrampowers` satisfied by the sibling
manifest) placed 11 skills + 1 rule:

- writingpowers skills: `tech-writing`, `tech-writing-howto`,
  `tech-writing-explanation`, `tech-writing-reference`, `tech-writing-tutorial`
- writingpowers rule: `tech-writing-style`
- transitive (diagrampowers): `tech-diagramming`, `tech-diagramming-ascii`,
  `tech-diagramming-d2`, `tech-diagramming-drawio`, `tech-diagramming-plantuml`

## Dispatch chain (transcript evidence)

Transcript:
`~/.claude/projects/-private-var-…-tmp-jg4bl3dIXr-sandbox/1a1abcac-…-a96917e43512.jsonl`
(37 references to the sandbox path — confirmed the right session).

`Skill` tool_use counts:

| Skill                | Invocations | Transcript line |
| -------------------- | ----------- | --------------- |
| `tech-writing`       | **1**       | 12              |
| `tech-writing-howto` | **1**       | 28              |

**Order is correct:** the umbrella (`tech-writing`, line 12) fired first, then
the mode skill (`tech-writing-howto`, line 28). The chain is **complete** —
both links fired, in the right order, from a prompt that names neither skill nor
the word "how-to".

## How-to shape assessment

The produced `docs/integration.md` matches the `tech-writing-howto` "The shape"
contract point-for-point:

| `tech-writing-howto` shape element      | In the output?                                                                                     |
| --------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 1. Goal-titled heading                  | ✅ `# To integrate the calc module`                                                                |
| 2. Prerequisites / assumptions up front | ✅ `## Prerequisites` (Python 3, a project dir) before the first step                              |
| 3. Ordered, minimal imperative steps    | ✅ 3 numbered steps: copy → import → call                                                          |
| 4. Expected result                      | ✅ `## Expected result` → "The program prints `5`"                                                 |
| 5. Stop at the goal                     | ✅ ends at the result; the `round_to` detail is a `## Reference` link-out, not a taught digression |

- **No teaching / "why" digressions.** Scan for
  `what is|because|the reason|rationale|under the hood|…` → **none found**. The
  guide states actions, not justifications — exactly the how-to skill's "Don't
  teach", "Don't digress into why".
- **Umbrella routing visible too.** The integration genre routes to
  _how-to (+ reference link-out)_ in the umbrella §1; the output's `## Reference`
  section that defers the full signature to the `add` docstring is that exact
  link-out — evidence both the umbrella's routing AND the mode skill's shape
  landed.
- **No drift introduced (L2).** The guide is consistent with the as-built
  `add(a, b, *, round_to=None)`; it does not inline a stale signature and routes
  the keyword detail to the docstring. The agent's own summary noted it
  verified `add(2, 3)` prints `5`.

## Verdict

**Dispatch chain: COMPLETE.** Both `tech-writing` and `tech-writing-howto`
were invoked, in the correct order, and the output bears the mode skill's
fingerprints (goal-titled shape, prerequisites-first, imperative steps,
expected-result block, reference link-out, no "why" digressions). This is a
clean PASS for the Phase-2 dispatch goal.

**Is the mode skill load-bearing on this probe?** **Plausibly load-bearing,
not isolated-proven.** This probe was designed to confirm the chain fires, not
to A/B the mode skill against an umbrella-only baseline. The umbrella's §6
fallback ("if a mode skill is absent, apply §§2–5 inline … the mode skills only
add depth") means a competent base model could produce a similar how-to shape
without the mode skill — so this single GREEN run does not, on its own, isolate
the mode skill's marginal contribution. What it _does_ prove: the mode skill
**loads and executes** when present, the dispatch instruction is **honored**,
and the output is **shape-correct**. An umbrella-only counter-run (mode skills
absent) would be needed to quantify the delta; that is out of scope for this
single bounded probe.

### REFACTOR signal (honest)

The umbrella's §6 still reads: _"These mode skills do not exist yet (Phase 2).
If a mode skill is absent, do not block…"_ — the Phase-1 absent-skill framing.
Now that Phase 2 ships the four mode skills, §6 carries no **positive** "you
MUST invoke the mode skill once the mode is fixed" instruction; the dispatch
fired anyway on this probe (the table + "follow the per-mode skill" was enough),
but the stale "do not exist yet" sentence is misleading and the dispatch
intent is implicit rather than imperative. Suggest updating §6 to drop the
"do not exist yet" clause and state the dispatch as a directive, keeping the
absent-skill fallback as a graceful-degradation note rather than the headline.
This did not block the chain here, so it is a polish/clarity REFACTOR, not a
blocker.
