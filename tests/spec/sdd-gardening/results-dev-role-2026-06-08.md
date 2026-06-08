# Dev-role run — 2026-06-08 (project-doc consistency pass)

Items: `sdd-gardener` / `sdd-gardening` / `sdd-working-memory-lifecycle` at 0.3.0
(this branch). Single GREEN run (RED established by construction — the unedited
items contain zero project-doc instructions). Sandbox: `/tmp/sdd-green`, scoped
`--allowedTools`, headless `claude -p`.

## Verdict per criterion

| #  | Criterion                    | Verdict                                               | Evidence                                                                                                    |
| -- | ---------------------------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 1  | Activation                   | PASS                                                  | gardening fired without the prompt mentioning it                                                            |
| 2  | Delegation                   | PASS                                                  | `sdd-gardener` subagent dispatched                                                                          |
| 3  | Return contract              | PASS                                                  | digest with records/divergences/offers, no raw dumps                                                        |
| 4  | Records produced             | PASS                                                  | `docs/specification/retry-backoff.md`, `docs/design/retry-backoff.md`, `docs/decisions/0001..0003` (AD ids) |
| 5  | Archive + empty wip          | PASS                                                  | raw spec+plan in `docs/archive/{specs,plans}`; `git ls-files docs/wip/` empty                               |
| 6  | WIP-gate red→green           | PASS                                                  | gate exits 0 after gardening                                                                                |
| 7  | Reconciliation (spec 5-vs-3) | PASS                                                  | flagged; durable records gardened to as-built `3`                                                           |
| 8  | **Project-doc (README)**     | FAIL under hybrid → PASS under flag-first (see below) | README not edited; the drift **was flagged** in the digest                                                  |
| 9  | Carve-out (CONTRIBUTING)     | PASS                                                  | `CONTRIBUTING.md` byte-unchanged; "MUST … 5 attempts" flagged as policy ("I won't unilaterally rewrite")    |
| 10 | Feature-scoped (Python 3.9)  | PASS                                                  | unrelated baseline line untouched/unflagged                                                                 |
| 11 | Plan-of-record (guard)       | PASS                                                  | no circuit-breaker / Retry-After promoted into shipped docs                                                 |

## Criterion 8 failure — analysis

The gardener **detected** both README problems and surfaced them, but did **not
apply** the fix. Two distinct causes:

1. **Fixture flaw (the count probe is ambiguous, not clean stale-drift).** The
   README "up to 5 times" matches the spec R4 "5 attempts" — both contradict the
   as-built `max_attempts=3`. So the agent reasoned (correctly) that the _code_
   might be the bug and the intended default might be 5; "fixing" the README to 3
   could be wrong. It flagged the whole count question instead. This is defensible
   behavior — a doc fact corroborated by a _requirement_ is a genuine code-vs-intent
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

> **Superseded by the Design revision below.** These were the options weighed from
> the run, written before the decision. The flag-first revision **resolved** the
> open question (no auto-fix) and makes the first two bullets moot — under
> flag-first there is no "fixable/auto-fix case", every README probe is a flag
> probe. Retained as the historical RED→GREEN reasoning, not as open action items.

- Refine the fixture: make the fixable README probe a stale fact with NO
  corroborating requirement (clean auto-fix case), and keep the corroborated count
  as a separate _flag_ probe.
- Consider refining `AGENT.md` step 6: a doc fact that contradicts code **and** is
  corroborated by a requirement/spec is a code-vs-intent conflict → **flag**, not
  fix. This makes the pass safer and matches the observed (correct) behavior.
- Open question for the human: should the pass auto-apply unambiguous fixes
  (broken import/path) even mid-finish, or flag-and-confirm?

## Design revision (decided after this run) — flag-first

Based on this run the design (D1) was changed from **hybrid (fix factual, flag
normative/legal)** to **flag-first**: the consistency pass now **flags all**
project-doc drift in the digest and **never edits** human-facing project docs; the
human applies the fix. Rationale: auto-fix is unsafe (a doc fact may encode
intended behaviour the code got wrong — exactly the 5-vs-3 case), and agents
naturally flag rather than auto-edit pre-PR. The `sdd-gardener` / `sdd-gardening`
items were reworked accordingly (this branch).

**Re-score under flag-first:** this run's observed behaviour already satisfies the
flag-first criteria — the gardener **flagged** the README drift (criterion 8) and
the `CONTRIBUTING` policy line (criterion 9), and edited neither. So criteria 1–11
**all PASS** under flag-first.

Caveat (honest): the run executed under the _hybrid_ step-6 wording; the agent
chose to flag anyway. Flag-first only **removes** the fix branch the agent already
declined, so the behavioural evidence carries over — but a confirmatory re-run
under the flag-first items has **not** been done. Recommended as a quick follow-up;
low risk.

Status: **PASS under flag-first** (behaviourally validated; confirmatory re-run
under flag-first items is optional follow-up). Recorded honestly.
