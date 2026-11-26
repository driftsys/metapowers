# GREEN scoring, round 3 — 2026-11-26

Raw outputs: `runs/green-2026-11-26-r3/<scenario>-<cell>-<n>/reply.txt`. RED
baseline for the new prompts: `runs/red-2026-11-26-r3/`. Same harness
(`run-green.sh`, `run-red.sh`, `OUT_ROOT` set per folder). Scenarios S5 (new
dark-mode prompt) and S6 (new, user email prompt) only, 3 cells, 3 runs each:
18 GREEN runs and 18 RED runs. The rule is unchanged since round 2. Criteria
changes are in `scenarios.md` ("Changes after round 2").

All 36 runs exited 0. No run edited a file (`diffstat.txt` is empty).

## Canary

The first line of the rule was quoted in all three cells as "Give a class to
each task in a plan and to each file change you make, on its".

## Fails out of 3 runs

| Scenario | Cell    | RED fails | GREEN fails |
| -------- | ------- | --------- | ----------- |
| S5       | opus    | 3/3       | 0/3         |
| S5       | sonnet  | 3/3       | 0/3         |
| S5       | copilot | 3/3       | 0/3         |
| S6       | opus    | 3/3       | 0/3         |
| S6       | sonnet  | 3/3       | 0/3         |
| S6       | copilot | 3/3       | 2/3         |

RED fails in all 18 runs because no reply has a `Class:` line (0 of 18).

## S5 (UI standard, script light, each with a source)

18 runs, GREEN 9/9 pass. Every reply gives `Class: standard (default:
user-facing feature)` for the dark-mode toggle and `Class: light (default:
build script)` for the script, each on its own line. Most also class the tests
standard. Several replies say the UI task would become critical if the
preference is stored with personal data or touches `src/payments/`; none
raises it now.

## S6 (email on the settings screen; pass = critical with a reason)

- opus-1, opus-2, opus-3: pass. Critical; reasons name personal data and, in
  opus-1 and opus-2, the higher-class tie-break.
- sonnet-1, sonnet-2: pass. Critical; "I couldn't decide between standard and
  critical, so I took the higher one" and "the view exposes personal data".
- sonnet-3: pass. The investigation and verification steps are standard; the
  change and its tests are critical because they render personal data.
- copilot-2: pass. Display task critical: "it displays personal data; I'm
  choosing the higher class because I can't decide between standard and
  critical".
- copilot-1: fail. The display task is standard: "Class: standard (default:
  user-facing feature). Reason: it only reads and displays data the user
  already owns, and it does not touch `src/payments/`."
- copilot-3: fail. The display task is standard: "Class: standard (default:
  user-facing feature). It only displays data and touches no authentication
  code."

Copilot also classes a helper step that reads the email from auth code as
critical in copilot-1 (the accessor), but the display change stays standard.

## Result

The ambiguity that failed S5 in rounds 1 and 2 is gone with the new prompt:
S5 passes 9/9. S6, the deliberate tie-break test, passes 7/9; both fails are
Copilot runs that treat displaying a user's own email as a plain UI feature
and do not apply the tie-break.

## Re-score with the round 4 S6 criterion ("old wording")

Re-scored on 2026-11-26 with no re-run. The S6 criterion changed after this
round (see `scenarios.md`, "Changes after round 3"): pass = standard AND the
answer asks the user whether privacy applies. The rule text scored above is the
old wording, which expected critical.

All 9 GREEN S6 runs fail under the new criterion. The 7 critical runs fail
because they are critical. copilot-1 and copilot-3 are standard but ask no
question about privacy or the class (copilot-3 has an open question about where
the email comes from, which is not a privacy question). The pass and fail
statements in the S6 section above are for the old wording only.
