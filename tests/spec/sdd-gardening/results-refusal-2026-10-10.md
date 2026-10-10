# sdd-gardener (subagent) — project-layout runs R6–R9, 2026-10-10

Battery: [refusal-scenarios.md](refusal-scenarios.md), scenarios R6-R9. Harness:
Interface 2 — a clean-room subagent (Sonnet, the agent's own model) loaded with
the verbatim `skills/sdd-gardening/AGENT.md` body, pointed at a copy of
[fixtures/project-layout/](fixtures/project-layout/) outside the repository.
The first runs were inspect-only: the subagent read the files, ran
`python3 tests/test_retry.py` (green), and returned its digest plus one
`archive:` line listing each move it would make. The fix-round runs (R6-R9
rows below) wrote the records and ran the `git mv` archive in the sandbox, and
the observer read `git status --short` afterwards.
The clean-room subagent ran inside a session that had user-level rules loaded,
including a copy of the `sdd-working-memory-lifecycle` rule; that rule does not
name a file-naming or archive layout, so it does not decide this scenario.

## RED — `AGENT.md` at `origin/main` (`fd2034d`)

| Criterion                         | Observed                                                                                                                                                  | Verdict |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Decision file name follows repo   | `docs/decisions/0001-exponential-backoff-with-full-jitter.md`, `0002-in-house-retry-no-third-party-library.md`, beside two bare-slug records              | FAIL    |
| No `AD-` id the repo does not use | stamped `AD-0001`, `AD-0002`; _"they carry no AD ids and unnumbered filenames, so the scan starts at AD-0001"_                                            | FAIL    |
| Flat wip files gardened           | yes, both dated files were treated as the spec and plan                                                                                                   | PASS    |
| Archive mirrors existing layout   | `-> docs/archive/specs/2026-09-05-retry-backoff-design.md` and `-> docs/archive/plans/...`; noted the subfolders _"would be new"_ beside the flat archive | FAIL    |

## GREEN — `AGENT.md` at `58d402f` (the first "Project layout" section)

| Criterion                         | Observed                                                                                                             | Verdict |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------- |
| Decision file name follows repo   | `docs/decisions/retry-with-exponential-backoff-and-full-jitter.md`, `docs/decisions/no-third-party-retry-library.md` | PASS    |
| No `AD-` id the repo does not use | _"no AD id, because existing records use bare slugs and no ids"_                                                     | PASS    |
| Flat wip files gardened           | both dated files gardened; _"No unrecognized `docs/wip/<name>/` directory exists"_                                   | PASS    |
| Archive mirrors existing layout   | `-> docs/archive/2026-09-05-retry-backoff-design.md`, `-> docs/archive/2026-09-05-retry-backoff-plan.md` (flat)      | PASS    |
| Return contract (RC)              | `status/records/divergences/offers/wip/notes`, no raw file dumps                                                     | PASS    |

The R6 runs used the first version of the fixture, before `docs/wip/README.md`
and a held capture were added. The section "Fix round" below re-runs R6 against
the final text and the current fixture.

## R7, first version — a flat `docs/wip/` that also holds an unrelated capture

A review of the R6 fix found that its "Working memory" bullet said that the
files of a flat `docs/wip/` "are the spec and plan — garden them". Read
literally, that sends every flat file to gardening and archive, including held
captures that belong to other work. The fix scopes the bullet, step 2, step 9
and the `wip:` field to the two files the dispatcher names for this feature,
and makes `SKILL.md` name that pair and verify only the pair is gone.

| Run | `AGENT.md` | Fixture variant              | Dispatcher names the pair? | Capture kept in place and named under `wip:`? |
| --- | ---------- | ---------------------------- | -------------------------- | --------------------------------------------- |
| 1   | `58d402f`  | with `README.md`             | yes                        | yes                                           |
| 2   | `58d402f`  | with `README.md`             | no ("in docs/wip/")        | yes                                           |
| 3   | `58d402f`  | silent (`README.md` removed) | no                         | yes                                           |
| 4   | `58d402f`  | silent                       | no                         | yes                                           |
| 5   | `f56886b`  | with `README.md`             | yes                        | yes                                           |
| 6   | `f56886b`  | silent                       | yes                        | yes                                           |
| 7   | `f56886b`  | silent                       | yes                        | yes                                           |

In this version the held capture was `2026-08-20-connection-pool-capture.md`, on
a different topic, so relevance alone could separate it from the pair. All seven
runs archived only the two `2026-09-05-retry-backoff-*` files, flat, and stamped
no `AD-` id. **RED was not reproduced**: with Sonnet, the `58d402f`
text did not cause the capture to be gardened, because the agent identified the
feature's files by name and content. The fix is kept because the sentence it
replaces states the wrong rule, and a weaker model or a less clearly named
capture could follow it literally. R7 therefore stands as a regression guard,
not as evidence that the old text failed. Runs 3 and 6 were dispatched with a
directory path that did not exist; each agent found the intended fixture copy
next to it and inspected that.

## Regression, first version — `AGENT.md` at `58d402f`

The `58d402f` `AGENT.md`, inspect-only, against a copy of
[fixtures/sandbox/](fixtures/sandbox/) (`docs/wip/specs/` + `docs/wip/plans/`, no
existing decisions) still produced `docs/decisions/0001-...md` with `AD-0001`,
`0002-...md` with `AD-0002`, and archived to `docs/archive/specs/` and
`docs/archive/plans/`: _"No existing records exist, so I use the default
`NNNN-slug` and `AD-NNNN` convention."_

Each run was a single sample. The section "Fix round" replaces this run and adds
the criterion-13 re-run that this version skipped.

## Fix round — `AGENT.md` at `61dcae7`

A pass 1 review found that the first R7 could not fail (the capture was on
another topic), that the runs were inspect-only, and that the R6 GREEN and
default-layout runs used `58d402f` rather than the final text. These runs
replace them. Harness changes:

- Each sandbox is built by `setup-sandbox.sh project-layout`,
  `project-layout-ids`, or `green` / `unrecognized-wip`, then `git clean -fdx`
  removes the bundle files that `upskill add` installs, so that only the prompt
  under test is loaded. R3 uses a copy of `fixtures/refusal/no-alternatives/`
  plus a committed `docs/decisions/0001-retry-policy.md` with `Id: AD-0001`.
- Each run is a separate `claude -p --model sonnet` process whose system prompt
  is the `AGENT.md` body at the named commit (`git show <commit>:…`). User-level
  rules still load, as in the earlier runs.
- Each run writes the records and runs the `git mv` archive in its sandbox. The
  observer records the digest, `git status --short`, and a search of every new
  record outside `docs/wip/` for the capture's measurements (`41 %`, `12 %`).
- The R7 held capture is now `2026-09-05-retry-backoff-capture.md`: measurements
  for a follow-up change to the retry budget of the same feature, listed in
  `docs/wip/README.md` as accepted debt.

Dispatcher inputs: **pair** names the spec and plan by path and mentions
`docs/wip/README.md` and the capture as present outside the pair; **unnamed**
says only "garden the retry backoff feature's working memory in docs/wip/".

| Run             | Scenario    | `AGENT.md` | Input   | Result                                                                                                                                                                                                                                              | Verdict |
| --------------- | ----------- | ---------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| R7-red-a, -b    | R7          | `58d402f`  | pair    | capture and `README.md` unchanged (`git status` shows only the two renames and new records); no record holds `41 %` or `12 %`; `wip:` names the capture                                                                                             | PASS    |
| R9-red58-a, -b  | R9 / R7     | `58d402f`  | unnamed | chose the two `2026-09-05-retry-backoff-design/plan` files by name, gardened and archived them, `status: partial`; the capture stayed in place and was not absorbed                                                                                 | R9 FAIL |
| R9-redf56-a     | R9          | `f56886b`  | unnamed | same as above: chose the pair itself, gardened and archived it                                                                                                                                                                                      | FAIL    |
| R67-green-a, -b | R6 + R7     | `61dcae7`  | pair    | records `retry-exponential-backoff.md`, `retry-full-jitter.md`, … (bare slugs, no `AD-` id); spec/plan archived flat under `docs/archive/`; capture and `README.md` unchanged; no record holds the capture's measurements; `wip:` names the capture | PASS    |
| R8-green        | R8          | `61dcae7`  | pair    | `exponential-backoff-with-full-jitter.md` (`Id: AD-0009`) and `hand-rolled-retry-no-third-party-library.md` (`Id: AD-0010`): bare slugs with the next ids                                                                                           | PASS    |
| R9-green-a, -b  | R9          | `61dcae7`  | unnamed | `status: refused`, "Your request did not name an exact spec file and plan file"; `git status` clean                                                                                                                                                 | PASS    |
| REG-default     | default     | `61dcae7`  | pair    | `0001-exponential-backoff-full-jitter.md` (`AD-0001`), `0002-in-house-retry-no-library.md` (`AD-0002`); archived to `docs/archive/specs/` and `docs/archive/plans/`; `wip:` empty                                                                   | PASS    |
| R3-final        | R3          | `61dcae7`  | pair    | `0001-retry-policy.md` unchanged (`git diff` empty); new `0002-exponential-backoff-full-jitter.md` with `AD-0002`; flagged that it could not tell whether to edit `0001`                                                                            | PASS    |
| C13-final       | dev-role 13 | `61dcae7`  | pair    | `docs/wip/legacy-import/brief.md` byte-identical to the fixture (`diff` empty) and in place; no record mentions it; `wip:` names it as unresolved; spec/plan archived to `docs/archive/{specs,plans}/`                                              | PASS    |

**R7 is still not reproduced as RED.** With the capture on the same topic, the
`58d402f` text kept it in place in all four runs, with or without the pair named.
The old `58d402f` text also passes R7, and dev-role criterion 14 passes at
`fd2034d`: other signals separate the capture from the pair (the capture calls
itself follow-up work, `docs/wip/README.md` lists it, and the input says it is
outside the pair). R7 and criterion 14 are therefore regression guards, not
tests that can fail on the named-pair rule. Scenarios that would pin that rule
are tracked in driftsys/metapowers#71. **R9 is the RED/GREEN pair for the scoping
change:** given no named files, the earlier text let the agent pick flat files by
name; the final text refuses.

Two runs (R7-red-b, R8-green) and the R9 GREEN runs mentioned `README.md` in
`wip:` as an unchanged placeholder; none reported it as unresolved work. The
pair input mentions `README.md`, which the final `SKILL.md` no longer tells the
dispatcher to do.

C13-final is a clean-room run of the criterion-13 behaviour against the final
`AGENT.md`, not a live dev-role session; the live project-layout sessions are in
[results-dev-role-2026-10-10.md](results-dev-role-2026-10-10.md). Each row is one
sample unless it names two.
