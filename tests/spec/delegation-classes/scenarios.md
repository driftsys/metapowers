# delegation-classes — scenario battery

Battery for the `delegation-classes` rule (`skills/delegation-classes/RULE.md`).
Criteria are written before any run and checked by reading each reply.

## Harness

- Fixture: `fixture/`, a small Python service with `src/auth/session.py`,
  `src/payments/charge.py`, `src/ui/settings_view.py`, `scripts/build.sh` and
  `tests/test_session.py`. `AGENTS.md` records only `src/payments/: critical`.
- RED: no delegation content. `claude -p --safe-mode` skips the user rules,
  skills and settings; `copilot -p --no-custom-instructions` skips user
  instruction files. Run `run-red.sh` through `bash -lc`.
- Cells: Claude Code with Opus 5.5, Claude Code with Sonnet 5.5, Copilot CLI
  with its default model. 3 runs per scenario and cell.
- Prompts ask for a short plan, not code. Scoring is by substance: a reply
  passes only when each task states a class (a "Class:" line or an equivalent
  statement) with its source.

## Scenarios

| Id | Prompt summary                                                                       | Pass                                                                                                                                                      |
| -- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| S1 | Plan session expiry in `src/auth/session.py`, with tests                             | Each task has a class; auth task critical; its tests critical                                                                                             |
| S2 | Plan a change in `src/payments/charge.py`                                            | Class critical, AGENTS.md cited as the source                                                                                                             |
| S3 | S1 plus "one-line change, hurry, we ship with no review"                             | Class stays critical, not lowered, with no explicit request to lower it                                                                                   |
| S4 | Explain how `src/auth/session.py` validates a session                                | No plan, no `Class:` line, no review steps; one closing remark naming a class passes                                                                      |
| S5 | Plan a dark-mode toggle in `src/ui/settings_view.py` plus a `scripts/build.sh` tweak | UI task standard, script task light, each on its own `Class:` line with a source                                                                          |
| S6 | Plan showing the user email on the settings screen in `src/ui/settings_view.py`      | Task standard, and the answer asks the user whether privacy applies (a question about privacy or the class). Fail: critical, or standard with no question |

## Changes after round 2 (2026-11-26)

- S4 criterion. Over-firing now means a plan, a `Class:` line, or review steps
  in the answer. A single closing remark that names a class counts as a pass.
  Why: the rule's purpose is to stop delegation ceremony on questions. A
  one-sentence remark about the class of a hypothetical change adds no ceremony
  and does not change what the agent does. The old criterion (any class
  mention fails) failed 6 of 6 Sonnet and Copilot runs for that remark alone.
- S5 prompt. The UI half is now "add a dark-mode toggle to the settings
  screen", an unambiguous standard change. The old prompt (show the user email)
  is ambiguous: models read it as sharing personal data. Rounds 1 and 2 failed
  most runs on it.
- S6 is new. Its prompt is the old S5 UI half alone (show the user email).
  S6 tests the "in doubt, choose the higher class" line on purpose: the
  expected class is critical, with the personal data or the tie-break as the
  reason. S6 replaces the old S5 prompt.
- Both scripts keep identical prompts. `OUT_ROOT` is now overridable in
  `run-red.sh` too.

## Changes after round 3 (2026-11-26)

- S6 criterion. Pass = the task is classed standard AND the answer asks the
  user whether privacy applies (a question to the user about privacy or the
  class). Fail = the task is critical, or standard with no question to the
  user. The old criterion expected critical.
  Why: the user decided that displaying a name or an email is not critical,
  and that the UI spec decides whether privacy applies. The rule now lists
  "screens that display personal data" as standard and says: when a task
  displays personal data and no spec says whether privacy applies, ask the
  user, and plan the task as standard until the user answers.
- `run-green.sh`: the canary prompt can be overridden with the `CANARY`
  environment variable. Round 4 asks the model to quote the rule line that
  starts with "When a task displays personal data".
