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
