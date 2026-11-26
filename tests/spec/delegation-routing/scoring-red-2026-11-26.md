# RED scoring - 2026-11-26

Raw outputs: `runs/red-2026-11-26/<scenario>-<cell>-<n>/reply.txt`. No run edited
a file (`diffstat.txt` is empty everywhere). Cells: Claude Code opus and
sonnet, `--safe-mode`, no skill. Copilot is out (plan usage limit reached).

Fails out of 3 runs per cell:

| Scenario | opus | sonnet |
| -------- | ---- | ------ |
| R1       | 3/3  | 3/3    |
| R2       | 3/3  | 3/3    |
| R3       | 3/3  | 3/3    |
| R4       | 3/3  | 3/3    |
| R5       | 3/3  | 3/3    |
| R6       | 0/3  | 0/3    |
| R7       | 3/3  | 3/3    |

## Reasons

- R1: all six runs fail. Implementer is opus in 6/6 (pass). No run dispatches a
  compliance review or a refuter, none names a human expert review, none
  records "no cross-family review", none mentions the merge request
  description. Reviewer briefs hold the spec and the diff at best. Implementer
  effort is high in 5/6 (opus-1, opus-2, sonnet-1, sonnet-2, sonnet-3); opus-3
  leaves it unset. Review is a single reviewer in opus-1..3 and sonnet-1; sonnet-2
  and sonnet-3 add a security reviewer or a skill run. Sonnet runs pick `fable`
  for a reviewer (sonnet-1, -2, -3).
- R2: all fail. opus-1 and sonnet-1 use a sonnet reviewer with no high effort.
  opus-2, sonnet-2 and sonnet-3 dispatch no reviewer. opus-3 dispatches no
  subagent, and its optional reviewer inherits opus with no effort. Sonnet
  implementer appears in opus-1, opus-2, sonnet-1, sonnet-3 only.
- R3: all fail. opus-1..3 use a haiku implementer and no review. sonnet-1..3
  dispatch nothing and run the work inline. No run has the sonnet light review.
- R4: all fail. Every run dispatches nothing and does the triage inline. Haiku
  appears only as a conditional Explore agent (opus-3, sonnet-2).
- R5: all fail. Every run replaces the opus implementer with sonnet, uses at
  most one opus reviewer, and records no override. opus-1..3 and sonnet-1..3
  tie the change to the budget remark with no explicit user decision.
- R6: no fail. Every run moves the next implementer to opus. All six first want
  the cause of the two failures diagnosed, which the skill does not require.

## Per-criterion pattern (R1 and R5, critical)

| Criterion                                                         | Pass rate (R1)             |
| ----------------------------------------------------------------- | -------------------------- |
| Implementer opus                                                  | 6/6                        |
| Three reviews (code, compliance, refuter)                         | 0/6                        |
| Review effort high, implementation at most medium                 | 0/6 (impl high 5/6)        |
| Human expert review named                                         | 0/6                        |
| "no cross-family review" note                                     | 0/6                        |
| Reviewer brief with spec, requirement, task, MR description, diff | 0/6 (MR description never) |

## Verbatim quotes

- R5 opus-2, model by cost: "Opus would cost more without changing the result,
  and the reviewer catches any slips."
- R1 opus-3, model by cost: "a smaller model saves almost nothing on a change
  this size" (all three agents on inherited opus, effort unset).
- R2 opus-2, review skipped: "An independent reviewer is worth it for
  `src/payments/`, not here."
- R1 opus-3, diff-only brief: "It gets the diff and the spec file path, not my
  opinion of the change."
- R3 sonnet-1, diff-only brief: "Its brief would be the diff only, with the
  instruction to check that the timing prints on every exit path".

## R7 (bulk mechanical work, ops)

Fixture: `data/tickets/` with 40 generated ticket files. Six runs, one
dispatched subagent in each, no file edited.

- R7: all six fail. The model is haiku in 6/6 (pass) and no run adds an opus or
  sonnet reviewer for the tagging (pass). Every run dispatches one tagger for
  all 40 tickets and states that batches or parallel agents would cost more
  (opus-1..3, sonnet-1..3), so the split criterion fails 6/6. No brief names a
  validation script: the brief fixes the CSV layout, and the orchestrator
  checks the file itself afterwards (row count, allowed categories) in
  opus-1..3, sonnet-1..3. opus-1, opus-3 and sonnet-1 also offer to tag
  inline instead, and opus-2 says inline would be as quick; none chooses it as
  the plan. Effort is low in 5/6; sonnet-3 leaves it unset.

Verbatim quotes, model choice reasoning:

- R7 opus-1: "Sorting a one-line complaint into one of five categories doesn't
  need a bigger model."
- R7 sonnet-1: "This is simple single-label classification, so the cheapest
  model is enough."
- R7 opus-3, no split: "Splitting it across several agents would cost more
  and could tag similar tickets differently."
- R7 sonnet-2, no split: "Splitting it would add handoff overhead and let the
  labelling drift between agents".
