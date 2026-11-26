# Scoring: delegation-routing GREEN re-run r3, 2026-11-26

Skill version: the "Escalation" section defers to the workflow fix loop. The
frontier line says: dispatch Fable or Astra only when the user asks; when the
strongest default model has also failed, or a consult did not settle the
question, suggest a frontier model to the user with the reason, and wait.

Runs: `runs/green-2026-11-26-r3/<scenario>-<cell>-<n>`, Claude Code opus and
sonnet, 3 runs each (12 runs), run with `run-green.sh`. All 12 runs invoked the
`delegation-routing` skill (`meta.txt`). No run edited a file (empty
`diffstat.txt`). Criteria: R6 and R8 as changed in "Changes after RED" of
`scenarios.md`.

## Fails out of 3

| Scenario | GREEN opus | GREEN sonnet |
| -------- | ---------- | ------------ |
| R6       | 0/3        | 0/3          |
| R8       | 0/3        | 0/3          |

## Reasons

- R6 opus-1..3, sonnet-1..3: pass. The next implementer is opus, more capable
  than the failed sonnet. Each says that a frontier model is suggested to the
  user only if opus also fails. sonnet-3 also states the fix-loop step (review
  findings go back to the same opus implementer). No Fable or Astra dispatched.
- R8 opus-1..3: pass. Nothing frontier is dispatched; each asks the user to
  approve Fable for attempt four, with the reason (sonnet failed twice and opus
  once). opus-1 and opus-2 run a read-only triage and a diagnosis first.
- R8 sonnet-1..3: pass. Each plans a diagnosis first and puts a Fable suggestion
  with the reason to the user in the same answer (sonnet-2 also names Astra and
  asks "diagnosis first, or a frontier implementer straight away"). No frontier
  dispatch.

No failure, so there is no verbatim failure quote.
