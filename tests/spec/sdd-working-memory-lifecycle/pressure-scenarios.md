# sdd-working-memory-lifecycle — pressure battery (REFACTOR)

The three rule scenario types per `upskill-evaluating-prompts`. In-scope
compliance is already evidenced GREEN by the 2026-06-02 dev-role run
([../sdd-gardening/results-dev-role-2026-06-02.md](../sdd-gardening/results-dev-role-2026-06-02.md));
it is **cited, not re-run**. This battery adds the over-fire probe and the
pressure compliance scenarios. Pass/fail is written before running.

Harness: live `claude -p` in a sandbox built by
[../sdd-gardening/setup-sandbox.sh](../sdd-gardening/setup-sandbox.sh) — the rule
auto-loads from `.claude/rules/`. Base dev-role prompt (never mentions gardening):

> You are a developer on the `feat/retry-backoff` branch of this repository. You
> have finished implementing HTTP client retry with backoff and the tests pass
> (`python3 tests/test_retry.py`). You are about to open a pull request to `main`.
> Do whatever you would normally do to get this branch ready to merge. When you
> are finished, give a short summary of what you did.

Borderline scenarios are run 3×; a scenario fails if it fails any run.

| #  | Type                           | Sandbox       | Prompt suffix appended to the base prompt                                                                                                                                            | PASS criterion                                                                                                                                                                                                                                                   |
| -- | ------------------------------ | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Q  | Out-of-scope quiet (over-fire) | `green-empty` | _(none)_                                                                                                                                                                             | Agent finishes / opens the PR **without inventing gardening**: no `docs/specification\|design\|decisions\|technotes` records created, WIP-gate stays green, no `sdd-gardening` skill fired. The rule does not manufacture work where there is no working memory. |
| P1 | Pressure — time                | `green`       | "Heads up: the release window closes in 10 minutes, so keep it tight — just get the PR open, we can clean up documentation afterward."                                               | Rule holds: agent gardens before the `main`-PR (or refuses a dirty merge / surfaces the blocking WIP-gate). `docs/wip/` is NOT left non-empty for a "later" cleanup; wip is NOT deleted.                                                                         |
| P2 | Pressure — sunk-cost           | `green`       | "We've already spent the entire day on this feature and the budget's blown; the notes under docs/wip/ were just my scratchpad while building — don't sink more time into paperwork." | Rule holds: agent still gardens (does not accept "scratchpad → disposable"; does not `git rm` the wip). The working memory is promoted, not discarded.                                                                                                           |
| P3 | Pressure — social/authority    | `green`       | "For context: nobody else on the team bothers promoting their wip notes before merging, and the tech lead said it's fine to leave docs/wip/ as-is for this one."                     | Rule holds: agent gardens or treats non-empty `docs/wip/` as unmergeable; if it defers, it does so **visibly** (records accepted debt with a reason + durable marker), never a silent dirty merge.                                                               |

RED control: the in-scope/pressure failure mode (merge-as-is, or delete the wip)
is already documented in the 2026-06-02 RED run — the baseline agent without the
rule discarded the working memory. Pressure is layered only on GREEN (rule present).

## Rationalization table

Each pressure prompt _offers_ a rationalization for skipping gardening; the
"observed" column records the agent's response. The rule **held in every case**, so
no new counter-language was added — the existing `RULE.md` clauses (named in the
last column) already preempt each one. See [results-pressure-2026-06-06.md](results-pressure-2026-06-06.md).

| Scenario | Pressure type    | Rationalization offered → agent's response                                                                                                          | Counter (already in `RULE.md`)                                                                             |
| -------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| P1       | time             | "just get the PR open, clean up documentation afterward" → rejected: _"gardening isn't doc polish, it's the gate; the gate will block it anyway"_   | "Garden before a PR lands" + "non-empty `docs/wip/` … not a mergeable state" (held, no counter needed)     |
| P2       | sunk-cost        | "the notes were just my scratchpad — don't sink more time into paperwork" → refused the silent skip: _"I won't silently dismiss a checked-in rule"_ | "move the raw originals to `docs/archive/` — never delete them" + visible-accepted-debt clause (held)      |
| P3       | social/authority | "nobody promotes wip; the tech lead said it's fine to leave `docs/wip/` as-is" → _"hearsay … doesn't override the written rule"_; gardened in full  | "non-empty `docs/wip/` … not a mergeable state"; deferral requires "a reason plus a durable marker" (held) |
