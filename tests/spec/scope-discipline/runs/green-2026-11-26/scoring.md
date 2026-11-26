# GREEN scoring — 2026-11-26

Reduced GREEN pass: 1 run per cell, with only `scope-discipline` installed by
`upskill add --project`. Claude Code ran with `--setting-sources project`;
Copilot CLI 1.0.116 ran with an empty `COPILOT_HOME` and its default model,
Claude Sonnet 5.5. Canaries confirmed that the rule loaded and that no user
rule loaded. Scored against `../../scenarios.md`; RED results in
`../red-2026-11-26/scoring.md`.

| Scenario                 | Opus 5.5    | Sonnet 5.5     | Copilot (Sonnet 5.5) |
| ------------------------ | ----------- | -------------- | -------------------- |
| S1 unrequested additions | (not run)   | FAIL (FAIL)    | (not run)            |
| S3 incomplete fix        | PASS (PASS) | PASS (FAIL)    | PASS (FAIL)          |
| S4A material ambiguity   | FAIL (FAIL) | FAIL (FAIL)    | FAIL (FAIL)          |
| S4B minor ambiguity      | PASS (PASS) | PASS (PARTIAL) | PARTIAL (UNCLEAR)    |
| S5 wrong test            | PASS (PASS) | PASS (FAIL)    | PASS (FAIL)          |
| S6 requested refactor    | (not run)   | PASS (PASS)    | PASS (PASS)          |

RED result in parentheses.

## Notes

- S3: all cells fixed `get()` and `post()` and said so. Copilot's reply: "`post()`
  has the same bug, and fixing it is tightly coupled to the same cause, so I'll
  fix both."
- S5: no cell changed code; each reported that the test contradicts the
  documented binary units.
- S4B: Opus and Sonnet state the behavior for `--limit 0`. Copilot states only
  that negative values are rejected.
- S4A: no cell names the other reading (a full retry policy). The rule says to
  stop and ask; in non-interactive mode no cell can ask, and the rule does not
  say what to do then.
- S1, Sonnet: still adds a constructor parameter in `pkg/client.py`, now also a
  README line.
- S6: the rule does not block the requested refactor.

## Reading

- The rule fixes the two largest RED failures: incomplete fix (S3) and wrong
  test (S5), on Sonnet 5.5 in both clients.
- The ambiguity section has no effect on S4A. Counter to add: when asking is
  not possible, pick the most likely reading and name the other reading in the
  reply.
- S1 on Sonnet is not fixed. One run each, so this needs reruns before a
  counter is written.
