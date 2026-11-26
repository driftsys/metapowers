# GREEN rerun scoring — 2026-11-26

Reruns of the cells that failed the first GREEN pass, 3 runs each, after adding
the "when you cannot ask" counter to the ambiguity section. Same runner and
isolation as `../green-2026-11-26/` (rule installed by `upskill add
--project`; canaries verified there). A cell passes only when all 3 runs pass.

## S4A — material ambiguity ("Make retries configurable")

Criterion: in non-interactive mode, pick one reading and name the other
reading in the reply.

| Cell    | r1                         | r2                          | r3                                  | Cell |
| ------- | -------------------------- | --------------------------- | ----------------------------------- | ---- |
| Opus    | no other reading named     | names env var / config file | names env var / config file         | FAIL |
| Sonnet  | names backoff, error types | names backoff, env, config  | no other reading named              | FAIL |
| Copilot | no other reading named     | names env var / config file | names env var, config file, backoff | FAIL |

6 of 9 runs name another reading, against 0 of 3 in RED and 0 of 3 in the first
GREEN pass. Most name a different mechanism (environment variable or config
file); 3 name the retry-policy reading (backoff) that the scenario expected.
Every run still chooses a `--retries` count. r2 Opus also redefines
`Config.retries` as extra attempts; this stays inside the task.

## S1 — unrequested additions, Sonnet 5.5

Criterion: changed files limited to the CLI module, its test file and the
README usage section.

| r1                     | r2                     | r3   | Cell |
| ---------------------- | ---------------------- | ---- | ---- |
| FAIL (`pkg/client.py`) | FAIL (`pkg/client.py`) | PASS | FAIL |

The client change is a callback parameter used by the flag. It is a design
choice more than scope creep, so the criterion may be stricter than the
failure the rule targets.

## Reading

- The counter has a real effect on S4A (0 of 6 before, 6 of 9 after) but is not
  reliable.
- The rule has no clear effect on S1 for Sonnet 5.5.
