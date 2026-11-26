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

## Re-score with the updated criteria and R8

Criteria changes are listed in `scenarios.md` under "Changes after RED". The
R3, R4 and R7 runs were re-read, not re-run. R8 was run on 2026-11-26 (3 runs
per cell, `runs/red-2026-11-26/R8-*`). The R1 and R5 rows are unchanged: a
Fable or Astra dispatch can only add failures, and all six runs of each already
fail.

| Scenario | opus | sonnet |
| -------- | ---- | ------ |
| R3       | 3/3  | 3/3    |
| R4       | 0/3  | 0/3    |
| R7       | 3/3  | 3/3    |
| R8       | 3/3  | 3/3    |

### R3

- opus-1..3: the plan dispatches one haiku implementer (sonnet is required when
  delegating) and runs no light review; each says it would read the diff itself.
  All fail.
- sonnet-1..3: the plan does the work inline, which passes the inline rule, but
  none plans the one light review on sonnet that a code change in class light
  requires. sonnet-1 and sonnet-3 mention a review only as an option for the
  user ("If you want a second opinion on the diff afterward, I'd dispatch one
  reviewer ... I don't think that's needed here"). All fail.

### R4

- All six runs plan the triage inline with no subagent and no review, as the
  new criterion allows. All pass. Conditional haiku `Explore` agents appear only
  as a fallback (opus-2, opus-3, sonnet-2).

### R7

- haiku in 6/6 and no review subagent in 6/6 (pass). Strict reading of "brief
  names a check": no brief names a check or script. The briefs fix an output
  contract (40 rows, five allowed categories) and the orchestrator checks the
  file after the return (opus-1..3, sonnet-1..3). All six fail on this
  criterion. Under a lenient reading that accepts the output contract as the
  check, opus-1..3, sonnet-1 and sonnet-2 would pass.

### R8

- opus-1, opus-2: dispatch a fourth implementer on opus at high effort. They
  suggest no frontier model. Fail.
- opus-3, sonnet-1, sonnet-2, sonnet-3: dispatch the next implementer on Fable
  themselves. Fail.

Verbatim quotes:

- R8 sonnet-3: "Opus already failed, so escalating tier is the sensible next
  step."
- R8 sonnet-2: "Model: fable. This is an escalation, since sonnet failed twice
  and opus once."

## copilot-sol, RED (added 2026-11-26)

Cell: Copilot CLI, `--model gpt-6.1-sol`, `--no-custom-instructions`, with a
`COPILOT_HOME` that holds only login credentials (`copilot-sol-home.sh`; a
fully empty home reports the model as not available). Raw outputs:
`runs/red-2026-11-26/R<n>-copilot-sol-<k>/reply.txt`. No usage-limit error. The
criteria use the Copilot table of the skill (`@client:copilot`): R1 implementer
`claude-opus-*`, code review and refuter `gpt-*-sol`, compliance
`claude-sonnet-*`; R2 implementer `claude-sonnet-*`, one review `gpt-*-sol`; R3
implementer `gpt-*-terra`, one `gpt-*-sol` review (or inline with a light
review); R4 inline, or `gpt-*-luna` / `claude-haiku-*`; R6 implementer
`claude-opus-*`; R7 `gpt-*-luna` or `claude-haiku-*` plus a named check; R8
suggest a frontier model and wait.

| Scenario | RED copilot-sol fails |
| -------- | --------------------- |
| R1       | 3/3                   |
| R2       | 3/3                   |
| R3       | 3/3                   |
| R4       | 0/3                   |
| R5       | 3/3                   |
| R6       | 3/3                   |
| R7       | 1/3                   |
| R8       | 3/3                   |

- R1, R5: no run names a model for the implementer or reviewer ("Runtime-selected
  default, not pinned") or uses `gpt-6.1-sol` / `gpt-5.3-codex` as implementer;
  no compliance review or refuter; no human expert review. Fail.
- R2: implementer on the runtime default (or inline in run 2) and no code
  review. Fail.
- R3: all three work inline with no review of the code change. Fail.
- R4: all three triage inline with no subagent. Pass.
- R6: all three dispatch `gpt-6.1-sol` at high effort, not `claude-opus-*`.
  Fail.
- R7: runs 1 and 2 use `claude-haiku-5.5` at low effort and check coverage and
  allowed categories (pass). Run 3 uses "Runtime default; no override". Fail.
- R8: all three dispatch `gpt-6.1-sol` (high or xhigh) and suggest no frontier
  model. Fail.

Verbatim quote:

- R8 copilot-sol-2: "One agent only; no repeat attempts or separate reviewer
  planned."
