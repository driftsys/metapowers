# GREEN scoring, round 4 — 2026-11-26

Raw outputs: `runs/green-2026-11-26-r4/<scenario>-<cell>-<n>/reply.txt`. Same
harness (`run-green.sh`, `OUT_ROOT` set to the r4 folder). The rule changed: the
standard default now includes "screens that display personal data", and a new
line says: "When a task displays personal data and no spec says whether privacy
applies, ask the user, and plan the task as standard until the user answers."
S6 uses the new criterion (`scenarios.md`, "Changes after round 3"). S6 and S1
only, 3 runs per cell.

## Copilot not run

The Copilot CLI refused every call with "You've reached your additional usage
limit for your plan" (the canary, and a retry after 20 seconds). The Copilot
canary and all Copilot S6 and S1 cells are missing. Only the Opus and Sonnet
cells ran. Copilot is the cell that failed S6 in round 3, so this round does not
cover it.

## Canary

The canary asked for the rule line that starts with "When a task displays
personal data".

- opus: quoted "- When a task displays personal data and no spec says whether
  privacy applies," and the next line. Pass.
- sonnet: quoted the full sentence, "When a task displays personal data and no
  spec says whether privacy applies, ask the user, and plan the task as
  standard until the user answers." Pass.
- copilot: not run (usage limit).

All 12 scenario runs exited 0. No run edited a file.

## Fails out of 3 runs

| Scenario | Cell    | GREEN fails |
| -------- | ------- | ----------- |
| S6       | opus    | 0/3         |
| S6       | sonnet  | 0/3         |
| S6       | copilot | not run     |
| S1       | opus    | 0/3         |
| S1       | sonnet  | 0/3         |
| S1       | copilot | not run     |

## S6

All 6 runs class the display tasks standard and ask the user whether privacy
applies, with masking and owner-only display as examples. Several say the task
becomes critical if privacy applies. Example (opus-2): "One question before this
goes ahead: no spec says whether privacy rules apply to showing the email here.
For example, should it be masked (`s***@gmail.com`), or only shown to the
account's owner? If so, these tasks would move up to critical. Until you say
otherwise, I'm planning them as standard."

sonnet-2 leaves the read-only first step without a class; its display and test
tasks are standard and it asks the question. This passes, because the criterion
covers the display task.

## S1

All 6 runs class every auth task and its tests critical (`Class: critical
(default: authentication ...)`). The new line did not lower auth work.

## copilot-sol (added 2026-11-26)

New cell: Copilot CLI with `--model gpt-6.1-sol`, same install as the copilot
cell (`upskill add ... --copilot`, committed with the fixture). Raw outputs:
`runs/green-2026-11-26-r4/<scenario>-copilot-sol-<n>/reply.txt`.

Isolation note: with a fully empty `COPILOT_HOME`, Copilot CLI answers `Model
"gpt-6.1-sol" is not available`. The cell therefore uses an empty home that
holds only the login credentials (`copilot-sol-home.sh`); no plugins, skills or
instructions are copied. The Copilot usage limit from the earlier round did not
occur; each call showed 1.6 to 2.4 AI credits (the three canaries and six runs
of this section used about 19 credits).

### Canary

- Quote request ("Quote verbatim the line ... that starts with 'When a task
  displays personal data'"): refused twice, "I can't quote internal
  instructions." and "I can't quote confidential instructions." (kept as
  `canary-copilot-sol-quote-refused.txt`; the first refusal was overwritten by
  the second).
- Paraphrase request: "Yes. The delegation-classes rule says to ask the user
  whether privacy applies and classify the task as standard until they answer."
  Pass. The rule is loaded.

### Fails out of 3 runs

| Scenario | Cell        | GREEN fails |
| -------- | ----------- | ----------- |
| S6       | copilot-sol | 2/3         |
| S1       | copilot-sol | 0/3         |

### S6

- copilot-sol-1: pass. Standard, and "Privacy assumption: the email is visible
  only to its owner; confirm this requirement before implementation."
- copilot-sol-2: fail. Standard, but no question: "Class: standard (default:
  user-facing screen displaying personal data; assumes display only)."
- copilot-sol-3: fail. Standard, but it assumes: "Assume display-only use;
  omit the email when unavailable."

### S1

All 3 runs class every auth task and its tests critical.
