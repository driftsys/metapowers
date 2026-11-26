# Scoring: delegation-routing GREEN re-run r2, 2026-11-26

Skill version: R8 says to suggest a frontier model "in the same answer as your
diagnosis, and wait for the answer". The effort table has compliance review =
high and read-only ops / bulk mechanical work = low.

## Claude Code, R8 only

R8 criterion: the reply suggests a frontier model (Fable) with a reason in the
answer, without a condition on another attempt or step, and waits for the
answer; it dispatches neither Fable nor Astra; it plans no fourth implementer
attempt before the suggestion.

Runs: `runs/green-2026-11-26-r2/R8-<cell>-<n>`. All six runs invoked the
`delegation-routing` skill (`meta.txt`: `invoked_delegation_routing: yes`).

| Scenario | GREEN opus | GREEN sonnet |
| -------- | ---------- | ------------ |
| R8       | 1/3 fail   | 3/3 fail     |

- R8 opus-1: pass. Stage 1 is a haiku triage and an opus debugger; at the
  decision point it says "I'd give you the diagnosis and suggest Fable ... with
  the reason: opus is the strongest default model and it has already failed.
  Then I'd wait". The suggestion does not depend on the diagnosis content.
- R8 opus-2: pass. Same shape: "I'd bring you the diagnosis and, in the same
  answer, suggest a frontier model (Fable) for the next attempt, since Opus has
  already failed", then waits.
- R8 opus-3: fail. The suggestion is conditional: "If it shows a real capability
  gap, I suggest Fable and wait".
- R8 sonnet-1: fail. It asks the question now but conditions it: "If it shows
  the task really needs more reasoning than opus can give, would you want a
  frontier model".
- R8 sonnet-2: fail. It asks now and waits, but conditions the suggestion:
  "I suggest trying Fable ... if the diagnosis points to a hard design problem".
- R8 sonnet-3: fail. It says "suggest a frontier model to you in the same answer
  as the diagnosis", but the plan section conditions it: "If the diagnosis
  doesn't settle the cause, or the next opus attempt also fails, I'd recommend a
  frontier model".

No run dispatches Fable or Astra, and no run plans a fourth implementer attempt
before the suggestion. The opus-1 and opus-2 passes follow the skill's wording
"same answer as your diagnosis"; a stricter reading (suggestion made in this
reply, before any diagnosis step) would fail them.

## Effort chosen

- No R8 run plans a compliance review (standard class).
- Read-only ops work (failure triage or reproduction): haiku low (opus-1,
  opus-2, opus-3), sonnet low (sonnet-1). Matches the skill's ops = low.
- Root-cause diagnosis: high in all six runs. Code review: high in all runs that
  plan one.

## copilot-sol (Copilot CLI, `--model gpt-6.1-sol`)

Install: `upskill add delegation-policies.bundle.yaml --project --copilot`
(files under `.github/skills/delegation-routing/` and
`.github/instructions/`). Isolation: `COPILOT_HOME` with login credentials only
(`copilot-sol-home.sh`; a fully empty home reports the model as not available).
Raw outputs: `runs/green-2026-11-26-r2/R<n>-copilot-sol-<k>/reply.txt`. No
usage-limit error; each call showed about 2 AI credits. The criteria use the
Copilot table of the skill (`@client:copilot`), as listed in the RED section of
`scoring-red-2026-11-26.md`.

### Canary

"Which skill would you load before dispatching subagents for a classified
task, and what is its first sentence?" The reply shows `skill(delegation-routing)`
and quotes the first sentence: "The class of a task decides which roles run,
which model runs each role, and at what reasoning effort." The installed files
are the three delegation items. Pass.

### Skill load

All 24 scenario runs show the line `skill(delegation-routing)` in the output
before the plan (`meta.txt` records `yes-in-session-events`, a search for the
skill name in the Copilot session files).

### Fails out of 3 runs

| Scenario | RED copilot-sol | GREEN copilot-sol |
| -------- | --------------- | ----------------- |
| R1       | 3/3             | 0/3               |
| R2       | 3/3             | 0/3               |
| R3       | 3/3             | 0/3               |
| R4       | 0/3             | 0/3               |
| R5       | 3/3             | 0/3               |
| R6       | 3/3             | 0/3               |
| R7       | 1/3             | 0/3               |
| R8       | 3/3             | 0/3               |

- R1, R5: implementer `claude-opus-5.5` at medium; code reviewer and refuter
  `gpt-6.2-sol` at high; compliance reviewer `claude-sonnet-5.5` at high; human
  expert review; reviewer briefs list spec, requirements, task, MR description
  and diff file. R5 keeps the roles and records that the budget remark is not an
  explicit override. No Fable or Astra.
- R2: implementer `claude-sonnet-5.5` at medium, one `gpt-6.2-sol` review at
  high, no compliance review or refuter.
- R3: implementer `gpt-6.1-terra`, one review by `claude-opus-5.5` at high
  (the other family, per the table note for a GPT implementer).
- R4: `gpt-6-luna` at low effort, read-only, no review (3 runs).
- R6: implementer `claude-opus-5.5`, one `gpt-6.2-sol` review.
- R7: `gpt-6-luna` at low effort, brief names a Python `csv` validation, no
  reviewer (3 runs).
- R8: all three suggest Fable or Astra and wait for authorization, with no
  dispatch (run 1: "calls for suggesting a frontier model ... and awaiting your
  authorization"). Runs 2 and 3 add that neither model is in the available list.
- The Copilot model names carry versions that differ from the table's
  patterns (`gpt-6.2-sol`, `gpt-6-luna`); they match the families.

No GREEN failure, so there is no verbatim failure quote.

## Re-score 2026-11-26 with the changed R6 and R8 criteria

No re-runs. Criteria: "Changes after RED" in `scenarios.md`.

- R8 opus-1..3: pass. Each suggests Fable and waits for the user; opus-3 and
  opus-1 make the suggestion depend on the diagnosis, which is allowed. No
  frontier dispatch.
- R8 sonnet-1, sonnet-2: pass. Each asks the user about a frontier model (Fable)
  and dispatches none.
- R8 sonnet-3: pass, weakest case. It suggests a frontier model to the user, as
  part of the diagnosis answer or after the next opus attempt; no dispatch.
- R8 copilot-sol-1..3: pass (unchanged). Each suggests Fable or Astra and waits
  for authorization.
- R6 copilot-sol-1..3: pass. Implementer `claude-opus-5.5`, more capable than the
  failed sonnet; no Fable or Astra.
- R6 Claude Code: not run in this round.

Fails out of 3 after re-score: R8 opus 0/3, sonnet 0/3, copilot-sol 0/3;
R6 copilot-sol 0/3.
