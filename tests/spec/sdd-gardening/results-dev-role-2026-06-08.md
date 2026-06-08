# Dev-role run — 2026-06-08 (project-doc consistency pass)

Items: `sdd-gardener` / `sdd-gardening` / `sdd-working-memory-lifecycle` at 0.3.0
(this branch). Single GREEN run (RED established by construction — the unedited
items contain zero project-doc instructions). Sandbox: `/tmp/sdd-green`, scoped
`--allowedTools`, headless `claude -p`.

## Verdict per criterion

| # | Criterion | Verdict | Evidence |
| - | --------- | ------- | -------- |
| 1 | Activation | PASS | gardening fired without the prompt mentioning it |
| 2 | Delegation | PASS | `sdd-gardener` subagent dispatched |
| 3 | Return contract | PASS | digest with records/divergences/offers, no raw dumps |
| 4 | Records produced | PASS | `docs/specification/retry-backoff.md`, `docs/design/retry-backoff.md`, `docs/decisions/0001..0003` (AD ids) |
| 5 | Archive + empty wip | PASS | raw spec+plan in `docs/archive/{specs,plans}`; `git ls-files docs/wip/` empty |
| 6 | WIP-gate red→green | PASS | gate exits 0 after gardening |
| 7 | Reconciliation (spec 5-vs-3) | PASS | flagged; durable records gardened to as-built `3` |
| 8 | **Project-doc fix (README)** | **FAIL** | README still reads `from backoff import retry` and "up to 5 times" — not fixed |
| 9 | Carve-out (CONTRIBUTING) | PASS | `CONTRIBUTING.md` byte-unchanged; "MUST … 5 attempts" flagged as policy ("I won't unilaterally rewrite") |
| 10 | Feature-scoped (Python 3.9) | PASS | unrelated baseline line untouched/unflagged |
| 11 | Plan-of-record (guard) | PASS | no circuit-breaker / Retry-After promoted into shipped docs |

## Criterion 8 failure — analysis

The gardener **detected** both README problems and surfaced them, but did **not
apply** the fix. Two distinct causes:

1. **Fixture flaw (the count probe is ambiguous, not clean stale-drift).** The
   README "up to 5 times" matches the spec R4 "5 attempts" — both contradict the
   as-built `max_attempts=3`. So the agent reasoned (correctly) that the *code*
   might be the bug and the intended default might be 5; "fixing" the README to 3
   could be wrong. It flagged the whole count question instead. This is defensible
   behavior — a doc fact corroborated by a *requirement* is a genuine code-vs-intent
   conflict, not stale documentation. The fixture should have used an unambiguous
   stale fact with no parallel requirement (e.g. a stale path/symbol only).

2. **The clean fixable case (broken import) was also flagged, not auto-applied.**
   `from backoff import retry` is an unambiguous, requirement-free runtime error
   that step 6 classifies as fixable → edit. The agent offered to patch it but
   asked first, in pre-PR finishing mode ("divergences I shouldn't silently
   resolve before opening the PR"). Net: the README import stayed broken. Whether
   that caution is desirable, or the consistency pass should auto-apply unambiguous
   fixes even when finishing a branch, is the open design question.

## Lesson (RED-GREEN-REFACTOR — GREEN exposed a design/fixture gap)

- Refine the fixture: make the fixable README probe a stale fact with NO
  corroborating requirement (clean auto-fix case), and keep the corroborated count
  as a separate *flag* probe.
- Consider refining `AGENT.md` step 6: a doc fact that contradicts code **and** is
  corroborated by a requirement/spec is a code-vs-intent conflict → **flag**, not
  fix. This makes the pass safer and matches the observed (correct) behavior.
- Open question for the human: should the pass auto-apply unambiguous fixes
  (broken import/path) even mid-finish, or flag-and-confirm?

Status: **GREEN incomplete (criterion 8 open).** Recorded honestly; not claimed as
a pass.
