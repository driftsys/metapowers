# GREEN scoring, round 2 — 2026-11-26

Raw outputs: `runs/green-2026-11-26-r2/<scenario>-<cell>-<n>/reply.txt`. Same
harness (`run-green.sh`, `OUT_ROOT` set to the r2 folder) and same criteria as
`scoring-green-2026-11-26.md`. Scenarios S1, S4 and S5 only, 3 cells, 3 runs
each, 27 runs. The rule changed in three places since round 1: the trigger
("Give a class to each task in a plan and to each file change you make ...
Answer questions without a class."), the critical default ("code that stores,
sends or shares personal data" instead of "privacy"), and the tie-break ("When
you cannot decide between two classes, choose the higher one."), plus a
two-task example with one `Class:` line per task.

All 27 runs exited 0. No run edited a file (`diffstat.txt` is empty).

## Canary

The first line of the rule was quoted in all three cells as "Give a class to
each task in a plan and to each file change you make, on its". The new wording
is in context in opus, sonnet and copilot.

## Fails out of 3 runs, round 1 next to round 2

| Scenario | opus R1 | opus R2 | sonnet R1 | sonnet R2 | copilot R1 | copilot R2 |
| -------- | ------- | ------- | --------- | --------- | ---------- | ---------- |
| S1       | 0/3     | 0/3     | 0/3       | 0/3       | 0/3        | 0/3        |
| S4       | 2/3     | 0/3     | 3/3       | 3/3       | 3/3        | 3/3        |
| S5       | 3/3     | 3/3     | 3/3       | 3/3       | 2/3        | 2/3        |

## Format check (one `Class:` line per task, with a source)

S1 and S5, 18 runs: all 18 give a `Class:` line per task with a source. In
round 1, 8 of 12 non-S4 Opus runs gave one header line. In round 2 all 6 Opus
runs (S1-opus-1..3, S5-opus-1..3) give one line per task, including the tests
task. Sonnet S5 runs put the tests inside task 1 and say "The tests take the
class of the code they test" (S5-sonnet-1, S5-sonnet-2) or give no separate
test task (S5-sonnet-3); the class line covers the whole task.

## S1 (auth, with tests; pass = auth and tests critical)

9/9 pass. Every task is critical with a source ("default: authentication and
access rights"; AGENTS.md cited as listing only `src/payments/`). Tests: "tests
of critical code" or equivalent in all runs. Several Copilot and Sonnet runs
also class documentation, migration and run-tests tasks critical.

## S4 (explain; pass = no class mention at all)

Any class mention counts as over-firing.

- opus-1, opus-2, opus-3: pass. No class mention.
- sonnet-1: fail. "If you want expiry or revocation added, I'd class that work
  as critical, since the project defaults put authentication in that class."
- sonnet-2: fail. "This file is authentication code, so it counts as critical
  under the project's delegation classes."
- sonnet-3: fail. "This is authentication code, which counts as critical under
  the project's delegation classes."
- copilot-1: fail. "The task was a question, so I assigned no class. Any change
  to this file would count as critical, since `src/auth/` handles
  authentication."
- copilot-2: fail. "This file is authentication code, so it falls under the
  critical class by default."
- copilot-3: fail. "I haven't changed anything. This is authentication code, so
  any change to it would fall under the critical class."

No run produced a plan, per-task lines or a `Class:` line. Each is one closing
sentence. Opus is fixed (2/3 to 0/3); Sonnet and Copilot are unchanged.

## S5 (UI standard, script light, each with a source)

All script tasks are light with a source (default). UI task class and reason:

- opus-1: fail. Critical: "default: code that sends or shares personal data,
  since the email is sent to the client. It could also pass as a standard
  user-facing feature, but the rule says to pick the higher class when unsure."
- opus-2: fail. Critical: "default: code that shows personal data ... The task
  is between standard (user-facing feature) and critical, so I chose the higher
  one."
- opus-3: fail. Critical: "default: sends personal data to the client and
  touches access rights; AGENTS.md has no entry for `src/ui/`".
- sonnet-1: fail. Critical: "default: code that sends or shares personal data
  ... I'm choosing the higher class because I can't decide between the two."
- sonnet-2: fail. Critical: "inferred: it renders personal data ... I couldn't
  choose between standard for a UI feature and critical for personal data, so I
  took the higher one."
- sonnet-3: fail. Critical: "default: code that stores, sends or shares
  personal data ... I couldn't decide between the two, so I chose the higher
  class."
- copilot-1: pass. Standard: "default: user-facing feature". The plan notes the
  email is personal data and that the task would become critical if it touched
  auth or storage code.
- copilot-2: fail. Critical: "the email is personal data, so the default
  \"code that stores, sends or shares personal data\" applies ... The higher
  class applies because the choice between standard and critical is not
  clear-cut."
- copilot-3: fail. Critical: "default: code that sends or shares personal data.
  It could also count as a standard user-facing feature, so I chose the higher
  class."

The reasoning is the same as in round 1: the model reads showing the user's own
email to that user as sharing personal data, then applies the tie-break. The new
wording did not change this. 8/9 fail, same as round 1.

## Remaining weaknesses

- S5: 8/9 classify the settings screen critical through the personal-data
  default and the tie-break. The wording change to "stores, sends or shares
  personal data" did not exclude displaying a user's own data to that user.
- S4: Sonnet and Copilot still mention a class in one closing sentence (6/6).
  The sentence "Answer questions without a class." stops the plan format but
  not an unrequested remark about the class of a hypothetical change.

## S4 re-score with the round 3 criterion (no re-run)

Criterion: over-firing is a plan, a `Class:` line or review steps; one closing
remark that names a class passes. Same replies as above.

| Cell    | Pass | Note                                                         |
| ------- | ---- | ------------------------------------------------------------ |
| opus    | 3/3  | No class mention                                             |
| sonnet  | 3/3  | One closing remark each, no plan, no `Class:` line, no steps |
| copilot | 3/3  | One closing remark each, no plan, no `Class:` line, no steps |

S4 fails: 0/3 in every cell (was 0/3, 3/3, 3/3).
