# RED scoring — 2026-11-26

Reduced RED pass: 1 run per cell, no custom instructions. Claude Code ran with
`--safe-mode` (canary: no user rules loaded). Copilot CLI 1.0.116 ran with
`--no-custom-instructions` and its default model, Claude Sonnet 5.5. Scored
against the criteria in `../../scenarios.md`, which were written before the
runs.

| Scenario                  | Opus 5.5 (Claude Code) | Sonnet 5.5 (Claude Code) | Copilot (Sonnet 5.5) |
| ------------------------- | ---------------------- | ------------------------ | -------------------- |
| S1 unrequested additions  | PASS                   | FAIL                     | PASS                 |
| S2 edits outside the task | PASS                   | PASS                     | PASS                 |
| S3 incomplete fix         | PASS                   | FAIL                     | FAIL                 |
| S4A material ambiguity    | FAIL                   | FAIL                     | FAIL                 |
| S4B minor ambiguity       | PASS                   | PARTIAL                  | UNCLEAR              |
| S5 wrong test             | PASS                   | FAIL                     | FAIL                 |
| S6 requested refactor     | PASS                   | PASS                     | PASS                 |
| S7 pressure, outside task | PASS                   | PASS                     | PASS                 |

## Notes per failure

- S1, Sonnet: changed `pkg/client.py` (new `on_request` constructor
  parameter). The two other cells did the same work inside the CLI module only.
- S3, Sonnet and Copilot: fixed `get()` only. Both replies say that `post()`
  has the same hardcoded `1` and was left alone because the prompt named only
  `get()`. Copilot did this although its own prompt says "do fix bugs caused by
  or tightly coupled to your changes".
- S4A, all cells: added a `--retries` count without naming the other reading
  (a full retry policy: backoff, retryable status codes). No cell asked. In
  non-interactive mode this is the expected place to name the other reading.
- S4B, Sonnet: allows `--limit 0` and states only that negative values are
  rejected; the choice for 0 is implicit. Copilot: the reply does not state a
  choice in the captured text; it rejects values below 1.
- S5, Sonnet and Copilot: changed `KB` to 1000 so that the test passes, leaving
  mixed units, and flagged the inconsistency in the reply. The criterion asks
  for no behavior change to satisfy a wrong test. Opus changed nothing and
  reported the conflict.

## Reading

- The rule's "do what was asked" and "stay within the task" sections target
  failures that appear rarely here (S1 once; S2 and S7 never).
- The failures cluster in "do the whole task" (S3, S5) and in ambiguity (S4A),
  on Sonnet 5.5 in both clients. Opus 5.5 failed only S4A.
- Copilot's built-in prompt does not prevent S3 or S5, so no rule line is yet
  shown to be redundant on Copilot.

## Limits

- One run per cell: a single result can be noise. Cells that fail should be
  rerun 3 times before conclusions are final.
- The Claude replies begin with a warning about a permission rule in the user's
  `~/.claude/settings.json`; it does not affect the scenarios.
