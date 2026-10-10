# sdd-gardening — dev-role runs, project-layout mode, 2026-10-10

Harness: [dev-role-harness.md](dev-role-harness.md), automated headless session
(`claude -p` with the verbatim dev-role prompt and the documented
`--allowedTools` list), sandbox mode `project-layout`. The dispatcher-side `SKILL.md` change on this branch (the dispatcher names the
spec/plan pair; step 6 no longer requires an empty `docs/wip/` and points at the
lifecycle rule's accepted-debt clause) produced no RED of its own in these runs;
see the note under the table and driftsys/metapowers#71. User-level rules loaded in both
sessions, as in earlier dev-role runs.

- **RED:** `setup-sandbox.sh project-layout` run from a detached checkout of
  `fd2034d` (`origin/main`), with only the new `setup-sandbox.sh` and the
  `project-layout` and `sandbox` fixtures copied in, so the bundle that
  `upskill add` installed carried the `fd2034d` `SKILL.md` and `AGENT.md`.
- **GREEN:** the same mode run from this branch at `61dcae7`.

| #  | Criterion        | RED (`fd2034d`)                                                                                                                                      | GREEN (`61dcae7`)                                                                                                   |
| -- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 1  | Activation       | PASS — `Skill sdd-gardening` (after `superpowers:finishing-a-development-branch`)                                                                    | PASS — `Skill sdd-gardening`                                                                                        |
| 2  | Delegation       | PASS — one `Agent` call, `subagent_type: sdd-gardener`                                                                                               | PASS — one `Agent` call, `subagent_type: sdd-gardener`                                                              |
| 3  | Return contract  | PASS — all six fields, no file dumps; about 34 lines, above the ~25-line guide                                                                       | PASS — all six fields, no file dumps; about 30 lines, above the ~25-line guide                                      |
| 4  | Records produced | **FAIL** — `0001-exponential-backoff-over-fixed-interval.md`, `0002-full-jitter.md`, `0003-…` with `AD-0001`–`AD-0003`, beside two bare-slug records | PASS — `exponential-backoff-schedule.md`, `full-jitter-on-retry-delay.md`, `in-house-retry-wrapper.md`, no `AD-` id |
| 5  | Archive          | **FAIL** — `docs/archive/specs/` and `docs/archive/plans/` created beside the flat archive                                                           | PASS — `docs/archive/2026-09-05-retry-backoff-design.md` and `-plan.md`, flat                                       |
| 14 | Named pair only  | PASS — capture and `README.md` unchanged; no record holds `41 %` or `12 %`; `wip:` names the capture                                                 | PASS — same                                                                                                         |

Both parents named the pair by path in the dispatch and listed the capture as
outside it, so the `fd2034d` `SKILL.md` already led Sonnet to name the pair:
**the dispatcher-side change did not produce a RED of its own.** The RED is in
criteria 4 and 5, which the `AGENT.md` "Project layout" section decides. Both
parents committed the gardened records and, with the WIP-gate still at 1 because
of the capture, told the human that the capture must be accepted as debt or
moved; neither wrote a debt marker. The GREEN parent also listed `README.md` to
the gardener as a placeholder, which `SKILL.md` step 2 now says it need not do.

Observer checks (both runs): `git status --short` after the run showed only the
untracked bundle files; `git ls-files docs/wip/` listed
`2026-09-05-retry-backoff-capture.md` and `README.md`; the WIP-gate exited 1
before and after (criterion 6 does not apply in this mode). Each column is a
single sample.
