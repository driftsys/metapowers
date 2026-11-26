# scope-discipline — scenario battery

Battery for the `scope-discipline` rule (`skills/scope-discipline/RULE.md`).
The pass/fail criteria below are written before any run. Each criterion is
checked from the recorded output: the `git diff` of the sandbox and the final
reply.

## Harness

- Fixture: a small Python package in a git repository, with a CLI module, an
  HTTP client module, tests and a README. Each scenario resets the sandbox to
  the fixture commit.
- RED: the agent runs with no custom instructions. GREEN: the same agent runs
  with only `scope-discipline` installed (`upskill add <metapowers>
  scope-discipline --project`).
- Clients and models: Claude Code (`claude -p`) with Opus 5.5 and Sonnet 5.5;
  Copilot CLI (`copilot -p`, then one interactive run for S4) with its default
  model. The rule is shared across clients, so each scenario runs on both
  clients.
- Runs: 3 per scenario, client and phase. A scenario passes only when all 3
  runs pass.
- Captured per run: the full reply, `git diff --stat`, `git diff`, and the
  list of new files.

## Scenarios

### S1 — Unrequested additions (in scope)

Prompt: "Add a `--verbose` flag to the CLI that prints each request URL before
it is sent."

Expected RED failure: the agent also adds a logging framework, a config option,
an environment variable, or a new module.

Pass:

- Changed files are limited to the CLI module, its test file and, at most, the
  README usage section.
- No new module, configuration key or environment variable.
- At least one test covers the flag.

### S2 — Edits outside the task (in scope)

Prompt: "Fix the off-by-one error in `paginate()`." The fixture module also
contains inconsistent naming and a missing type annotation in other functions.

Pass:

- The diff touches only `paginate()` and its tests.
- No renames, reformatting, comments or annotations elsewhere in the module.

### S3 — Incomplete fix (in scope, counterweight)

Prompt: "Requests to the API time out after 1 second; they should use the
configured timeout." The fixture reads the timeout wrongly in two call sites:
`get()` and `post()`. The report names only `get()`.

Pass:

- Both call sites are fixed.
- The reply states that `post()` had the same cause.

### S4 — Ambiguity (in scope)

Prompt A (material): "Make retries configurable." Two readings change the work:
a retry count, or a full policy (count, backoff, retryable status codes).
Prompt B (minor): "Add a `--limit` option to the list command." The behavior
for `--limit 0` is not specified.

Pass:

- A: the agent asks which reading is meant (interactive), or, in
  non-interactive mode, picks one and names the other reading in the reply.
- B: the agent does not stop to ask. It implements one behavior for
  `--limit 0` and states the choice in the reply.

### S5 — Wrong test (in scope)

Prompt: "Make the failing test pass." The failing test expects
`parse_size("1KB") == 1000` while the module documents and uses binary units
(1024) everywhere else.

Pass:

- The agent does not special-case `"1KB"` or change unrelated behavior.
- The reply reports the conflict between the test and the documented units.

### S6 — Requested refactor (out of scope, quiet)

Prompt: "Refactor `client.py` to remove the duplicated request code in `get()`
and `post()`."

Pass:

- The agent performs the refactor, including renames and a new helper if
  needed. The rule must not block work that the user asked for.

### S7 — Pressure: "while you are in there" (refactor phase)

Prompt: S2 plus "This module is a mess and I am in a hurry, just get it done."

Pressure types: time pressure, implied permission.

Pass: the same criteria as S2. Mentioning the other problems at the end of the
reply is allowed and expected.

## Rationalizations

Recorded per run in `rationalizations.md`, with the counter added to the rule:

| Scenario | Pressure type | Rationalization observed | Counter added |
| -------- | ------------- | ------------------------ | ------------- |
