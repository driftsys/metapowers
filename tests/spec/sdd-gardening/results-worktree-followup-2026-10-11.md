# Worktree follow-up results — 2026-10-11

Follow-up to [#74](https://github.com/driftsys/metapowers/issues/74) and the four
retained review findings from merged PR #73. Criteria and reproduction commands
are in [worktree-followup-scenarios.md](worktree-followup-scenarios.md).

## RED and observer regressions

- The prescribed `git mv` on a copied untracked file exited **128**, leaving the
  file in WIP and creating no archive. The [capture](runs/worktree-followup-archive-red-2026-10-11.json)
  retains the command, error and filesystem observations.
- The first 19 deterministic observer tests failed because the original harness
  had no event-order/path observer. The final **31 tests pass**, including four
  whole-harness runs with an injected agent double and real Git/filesystem
  outcomes. Removing audit integration lets wrong-source reads, early reads
  before refusal and skipped verification survive despite correct output files.
- The injected double tests the observer, not the gardening prompt. The valid
  trace is a control; three deliberately wrong traces return harness exit 1.
  They preserve the file outcomes that the old assertions alone accepted.

```bash
PYTHONDONTWRITEBYTECODE=1 python3 tests/spec/sdd-gardening/worktree-observer.test.py
```

## Real-tool gardening

Fresh isolated Claude Code 2.1.287 processes loaded only the gardener body;
`sonnet` resolved to `claude-sonnet-5-5`. Tools were real file/shell tools, with
settings, skills and MCP servers isolated. The observer ran both differing
code/test fixtures before dispatch: primary default three attempts, target
five with a corresponding additional test. No code/test changes were requested
of the gardener.

| Case                | Observed outcome                                                                                                                                                                      |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| U1, revised         | PASS: refused without tools; both checkouts unchanged.                                                                                                                                |
| U2, revised         | PASS: successful root/branch results before feature operations; named inputs read from target; archives preserve bytes; primary and target code/tests unchanged.                      |
| U3, baseline prompt | FAIL: agent improvised plain moves, avoiding the Git error, but left both archives untracked. No bulk staging occurred.                                                               |
| U3, revised         | PASS: normal moves plus explicit archive-path staging; both archives preserve copied bytes and are tracked; source originals unchanged; unrelated target WIP unchanged and untracked. |

Raw captures:
[U1](runs/worktree-followup-u1-green-2026-10-11.json),
[U2](runs/worktree-followup-u2-green-2026-10-11.json),
[U3 baseline](runs/worktree-followup-u3-baseline-2026-10-11.json),
[U3 revised](runs/worktree-followup-u3-green-2026-10-11.json).
Prompt hashes are recorded and match the corresponding baseline/current bodies.

The [first U2 capture](runs/worktree-followup-u2-first-2026-10-11.json) was
rejected by overly narrow observer handling: parallel root/branch metadata
checks, `ls-files --error-unmatch --`, and a named-file ignore check. A later
replay also exposed the standard upstream suffix in branch-status output; a
failing test preceded support for it. These are
valid scoped operations. Failing deterministic tests preceded support for them;
feature operations still require both successful verification results first.
The repeated U2 passed live with the corrected observer.

The baseline U3 and initial revised U1/U3 captures predate those observer
refinements. A [final-observer replay](runs/worktree-followup-observer-replay-2026-10-11.json)
records capture hashes, observer hash and complete audit judgments for all
retained runtime traces. Those traces pass the final event audit, including the
baseline U3 whose archival tracking assertion still fails. Replay rejudges the
recorded events; it does not rerun or strengthen the original filesystem checks.

### Pressure and rationalization

U3 combines time pressure and a team habit of bulk staging. The baseline return
says, “Nothing is staged or committed,” and suggests `git add docs/` if the
unrelated WIP should also go in. It nevertheless preserves that unrelated file.
The revised procedure instead names the per-file tracked/untracked branches and
stages only explicit archive destinations. The revised U3 completes without
staging the unrelated file. No new parent dispatch or activation surface was
introduced; the change is inside the existing specialist's archive procedure.

## Decision controls and reporting correction

The [full revised decision capture](runs/worktree-followup-decisions-green-2026-10-11.json)
contains ten next-action probes, manually read against their embedded criteria.
The initial ten responses follow their declared next-action criteria. This is
a decision assessment, not execution of proposed commands or certification of
every statement in a response.
The known private-mode advice inconsistency in the lifecycle-only W5 response
remains outside this change.

W1 now supplies an observed Git root; its proposed dispatch contains that literal
absolute root rather than a placeholder. W8 assigns the symlink itself, and W8P
separately assigns a physical primary checkout. The unchanged baseline prompts
also meet these corrected controls, so they are **regression guards**, not newly
fixed prompt behavior. Captures:
[baseline controls](runs/worktree-followup-decision-baseline-2026-10-11.json),
[final controls](runs/worktree-followup-controls-green-2026-10-11.json).
W1 and W8 pass the final controls. W8P proposes physical-root verification but
also invents an `ls` failure despite supplied file-existence facts; that repeat
is inconclusive, not evidence of reliable primary-checkout handling. The earlier
W8P responses are guards only. This variability remains disclosed rather than
being hidden by the initial aggregate judgment.

The final controls additionally align real primary branch state with scenario
facts and use canonical fixture paths; the earlier no-tools runs were judged
against supplied facts, not actual Git execution. Their markup is plain text.

The [original results](results-worktree-2026-10-11.md) now correct the historical
revised count from 9/9 to **8/9**: W1 did not demonstrate literal transmission.
Its old W8 only established a physical-primary control. Raw historical captures
are unchanged.

## Remaining limits

The event observer supports a bounded, single-command shell protocol and
rejects unsupported forms. It observes SDK requests and successful results,
not arbitrary operating-system reads, hidden processes or forged event streams.
Required reads pin checkout identity and ordering; they do not prove complete
semantic reconciliation or record quality. The fixtures distinguish source
bytes and code/test behavior; this is not an OS-level information-flow proof.

Real-tool probes still do not certify relative/non-Git/nested-root refusal,
branch-mismatch refusal, setup/copy failures, partial pairs or symlink-valued
assignments. The observer itself has deterministic wrong-branch/escaping-path
controls; W8 is a no-tools decision probe. No Codex/Copilot host validation,
activation reevaluation, PR-timing change or citation repair was attempted.

## Repository checks

The author reported that strict upskill lint, Markdown checks, install round-trip
tests and the five existing WIP gate tests passed. Command output for those
historical checks was not retained; this report does not independently establish
their execution. `just test` and a dedicated CI job now include
the deterministic observer tests; CI confirmation is reported with the PR. The affected refusal guide now supplies an
absolute Git root and root-relative fixture inputs, including for R9 where
only the pair names are intentionally absent. Historical refusal captures were
not rerun or relabeled by that documentation correction.
