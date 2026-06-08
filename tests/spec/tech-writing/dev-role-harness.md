# tech-writing — live-registry dev-role harness

Tests genuine activation + behavior (not description discrimination). A fresh
`claude -p` session runs with cwd in a sandbox built by `setup-sandbox.sh`.

## Run

```bash
SB=$(mktemp -d)/sandbox
bash tests/spec/tech-writing/setup-sandbox.sh green "$SB"      # or: red
( cd "$SB" && claude -p "Update docs/usage.md to match the code, and add a short integration guide." \
    --allowedTools "Read,Write,Edit,Bash,Glob,Grep,Skill,TodoWrite" )
```

To bound the run, wrap the `claude -p` command with `gtimeout 420` (coreutils) or
`timeout 420` where available — macOS ships neither by default, so the bare
command above is the portable form.

Inspect the transcript under `~/.claude/projects/<munged-cwd>/*.jsonl` to confirm
a `Skill` invocation of `tech-writing` (GREEN only).

## Pass/fail (write results to results-YYYY-MM-DD.md)

| Probe       | RED (no items) expected                                    | GREEN (bundle) expected                                                  |
| ----------- | ---------------------------------------------------------- | ------------------------------------------------------------------------ |
| House style | uses "we", future tense, Title-Case headings, "click here" | second person, present tense, sentence-case headings, descriptive links  |
| Mode purity | integration guide mixes how-to steps with design rationale | one mode; rationale split out or linked, not inlined                     |
| Drift (L2)  | copies/keeps the stale signature from the drifted doc      | corrects the doc to the **current** code signature; notes code+tests win |
| Media       | describes the auth↔token relationship in prose             | flags it as diagram-shaped (dispatch to tech-diagramming)                |

> **Media probe not yet exercisable.** The current fixture has no
> component-relationship for the model to flag as diagram-shaped, so the Media
> row cannot be tested as written. It needs a fixture carrying a
> component-relationship (e.g. an auth service ↔ token store) — deferred to a
> fixture-hardening follow-up; do not rely on this row until then.

> **Known limitation — fixture under-stresses `tech-writing-style`.** A strong
> base model passes the House-style and Drift probes without the rule installed
> (RED ≈ GREEN), so this fixture does not prove the rule is load-bearing.
> Hardening it — a longer, stickier drifted doc the base model is more likely to
> copy verbatim — is a tracked follow-up.
