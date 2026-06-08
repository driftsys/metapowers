# tech-writing (writingpowers Phase-3) review-agent probe — 2026-06-09

Live-registry behavioral eval of the **writingpowers** Phase-3 bundle (v0.3.0):
the `tech-writing` review **subagent** (co-located at `skills/tech-writing/AGENT.md`).
This probe is narrow: it confirms the review agent is **dispatched** for a review
request, **catches the three planted flaws** in `bad-guide.md`, and **returns a
structured findings digest — not a rewrite**. One bounded live `claude -p` run,
fail-fast, no retries.

## Environment

- `claude` (Opus 4.8 1M, parent; the dispatched subagent ran on the agent's
  declared `model: sonnet`), scoped
  `--allowedTools "Read,Write,Edit,Bash,Glob,Grep,Skill,Agent,Task,TodoWrite"`.
- Sandbox built by `setup-sandbox.sh green` into a `mktemp -d`
  (`/private/var/.../tmp.vuS10gWxtn/sandbox`).
- Prompt (names the review intent, not the flaws):
  _"Review docs/bad-guide.md against the code using the tech-writing review
  agent, and report the findings."_
- Fixture: `docs/bad-guide.md` carries three planted flaws — mode-mix (how-to
  title with explanation/"why" rationale), house-style ("We", `Click [here](#)`),
  and drift (`add(a, b)` vs the as-built `add(a, b, *, round_to=None)` in
  `calc.py`). Code green under `test_calc.py`.
- **Smoke test (Step 0):** `claude -p "Reply with exactly: SMOKE_OK"` returned
  `SMOKE_OK`. Nested non-interactive Claude works here. (macOS has no
  `timeout`/`gtimeout`; no such prefix was used.)

## What installed (Step 1)

`AGENT_INSTALLED` — **yes**. The review agent installs to the consumer's
`.claude/agents/tech-writing.md` (confirmed present in the sandbox). Full green
install resolved the bundle v0.3.0 (`requires: diagrampowers` satisfied by the
sibling manifest) — skills, the `tech-writing-style` rule, and the new
`tech-writing` AGENT all placed.

## Dispatch evidence (transcript)

Transcript:
`~/.claude/projects/-private-var-…-tmp-vuS10gWxtn-sandbox/cab8a123-…-77417533da19.jsonl`
(17 references to the sandbox path — confirmed the right session).

| Signal                                | Count |
| ------------------------------------- | ----- |
| `Agent` tool_use (dispatch)           | **1** |
| `"subagent_type":"tech-writing"`      | **1** |
| Parent `Bash` calls (read code/tests) | 2     |

**Dispatched: yes.** The parent invoked the `Agent` tool exactly once with
`subagent_type: "tech-writing"` and a review-only prompt (handed the doc, the
`calc.py`/`test_calc.py` pointers, and the sibling `usage.md` for context, with
an explicit "Return structured findings only — do not author or rewrite"). The
review was **delegated to the subagent**, not done inline by the main session.

## Planted-flaw coverage (from the subagent's returned digest)

All three planted flaws caught, plus correct secondary findings:

| Planted flaw                       | Caught? | Subagent finding                                                                                                                                                         |
| ---------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **(a) Mode-mix**                   | ✅ yes  | `blocker \| mode \| bad-guide.md:1-9` — explanation rationale ("We built `add` because…") wedged against a how-to instruction; neither mode developed → split + link out |
| **(b) House style** ("We")         | ✅ yes  | `blocker \| conformance \| bad-guide.md:3` — first person "We built `add`"; Tier-1 requires second person                                                                |
| **(b) House style** ("click here") | ✅ yes  | `blocker \| conformance \| bad-guide.md:9` — bare `Click [here](#)` link text; Tier-1 forbids "click here"                                                               |
| **(c) Drift** (signature)          | ✅ yes  | `blocker \| drift \| bad-guide.md:7` — documented `add(a, b)` vs as-built `add(a, b, *, round_to=None)` (calc.py:1); `round_to` keyword-only param undocumented          |

Secondary findings (all correct, not planted): conditional return path
`round(total, round_to)` undocumented (drift, calc.py:3-4); dead `#` anchor for
the promised rounding reference (drift); unverifiable "forward compatibility"
rationale with no code/ADR backing (drift, minor); compound "call X and it
returns Y" instruction; passive "it returns the sum"; zero code examples despite
runnable samples in `test_calc.py`.

## Structured digest, not a rewrite

- **Return shape matches the contract.** The digest carries `status: reviewed`,
  layered `findings:` lines (each `<severity> | <layer> | <file:loc> — <issue>
  → <fix direction>`), a `mode-purity: mixed (explanation + how-to)` line, a
  `drift:` block, and a one-line `verdict: revise`. Fix **directions** only — no
  document contents quoted back as a replacement, no authored prose.
- **`bad-guide.md` UNCHANGED.** Pre/post `shasum` identical
  (`174b2b99…`), `diff` empty. The agent did not edit, rewrite, or author the
  document — it reviewed and reported, exactly per the AGENT.md stance.

## Verdict

**Phase-3 review agent: PASS.** The `tech-writing` subagent was **dispatched**
(1× `Agent` tool_use, `subagent_type: tech-writing`), **caught all three planted
flaws** (mode-mix, house-style "We"/"click here", signature drift), returned a
**structured findings digest** conforming to the return contract, and left
`bad-guide.md` **untouched**. No REFACTOR signal from this probe: the agent
honored "review only — never author", produced fix directions not rewrites, and
verified each claim against `calc.py`/`test_calc.py` (code+tests win over prose).

## Integration gate (deterministic)

- `AGENT_INSTALLED`: **yes** (`.claude/agents/tech-writing.md` in the consumer).
- `upskill lint --strict`: **0 findings** (4 files checked).
- `just lint`: **0 errors** (dprint check clean; markdownlint 14 files, 0;
  `upskill lint skills --strict` 24 files, 0).

### Glob coverage finding (side question)

**AGENTS.md's claim is stale.** It states "markdown under `tests/` is formatted
by `dprint` (its glob is recursive)". It is not:

- `dprint.json` `includes`: `["*.md", "docs/**/*.md"]` — `tests/**/*.md` is in
  neither pattern (`skills/**` is in `excludes`, but `tests/**` is simply never
  matched).
- `.markdownlint-cli2.jsonc` `globs`: `["*.md", "docs/**/*.md"]` — same; the live
  run printed `Finding: *.md docs/**/*.md …` and linted 14 files, none under
  `tests/`.

So neither tool actually covers `tests/**/*.md`. This results file (under
`tests/`) is therefore **out of `just fmt`/`just lint` scope** — it is authored
by hand to the house style and is neither reformatted nor linted by the gate.
The AGENTS.md sentence should be corrected to say `tests/**` markdown is **not**
in the dprint/markdownlint globs (or the globs widened to include it, if that is
the intent).
