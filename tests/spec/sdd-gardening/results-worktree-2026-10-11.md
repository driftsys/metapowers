# Worktree boundary results — 2026-10-11

## Method

The predefined [nine scenarios](worktree-scenarios.json) compare baseline
`21639c0` with the revised item bodies. Each decision probe uses a fresh Claude
process and a disposable primary checkout plus linked worktree. Claude Code
2.1.287 resolved `sonnet` to `claude-sonnet-5-5`. The harness isolates settings,
skills and MCP servers and supplies only the item body and scenario.

Judgments below are manual against the declared criteria. Decision probes have
no tools: proposed commands and dispatches are text, not evidence of execution.
The separate filesystem probes use real shell and file tools. Each scenario
was sampled once per reported revision; these are local observations, not a
statistical reliability estimate or cross-client certification.

## Decision probes

| Scenario                             | Baseline | Revised | Observation                                                         |
| ------------------------------------ | -------- | ------- | ------------------------------------------------------------------- |
| W1 explicit dispatch                 | PASS     | PASS    | Absolute root and named pair passed to gardener.                    |
| W2 different initial cwd             | PASS     | PASS    | Assigned root checked before feature reads.                         |
| W3 unavailable assigned root         | PASS     | PASS    | Refused fallback despite release pressure.                          |
| W4 documented setup                  | PASS     | PASS    | Documented setup preferred over bootstrap guesses.                  |
| W5 private memory transfer           | FAIL     | PASS    | Selected files copied with source originals preserved.              |
| W6 destination conflict              | FAIL     | PASS    | Existing plan preserved; conflict surfaced before dispatch.         |
| W7 unrelated question                | PASS     | PASS    | No gardening or setup invoked.                                      |
| W8 primary and symlink compatibility | PASS     | PASS    | Explicit primary assignment and equivalent physical paths accepted. |
| W9 missing assignment                | FAIL     | PASS    | Refused instead of adopting initial cwd.                            |

Baseline: **6/9**. Revised: **9/9** for the declared worktree criteria.
Existing passing cases are regression guards, not newly demonstrated failures.

Raw captures:
[baseline](runs/worktree-red-2026-10-11.json),
[revised](runs/worktree-green-2026-10-11.json).
The captures include full responses, criteria, CLI/model metadata and prompt
hashes. An early probe with inconsistent directory facts was discarded and
replaced with real disposable Git checkouts before authoring the changes.

### Observed rationalizations

| Baseline response                                                                | Failure prevented                                                        |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| W5: “Prefer moving over copying. A move leaves one authoritative copy.”          | Removing private working memory from the source checkout.                |
| W6: “Yes” to dispatching immediately after selecting the newer destination plan. | Resolving differing copies implicitly under time and bulk-copy pressure. |
| W9: “I garden only this checkout” without an assigned root.                      | Treating initial cwd as authorization to select a checkout.              |

The revised W5 copies only the selected pair and preserves originals. W6
requests a plan choice before dispatch. W9 refuses without reading feature
material. W3 also retains refusal under time and social pressure.

These judgments cover the worktree criteria only. In W5 the revised response
also volunteers later archive/PR advice inconsistent with private mode. That
pre-existing lifecycle issue is outside #64; this result does not certify all
statements in a passing response.

## Filesystem probes

| Run                              | Observed outcome                                                                                                                    |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| U1 baseline, no assignment       | FAIL: gardener inferred the linked feature checkout and changed it. The primary stayed clean and byte-identical.                    |
| U1 revised, no assignment        | PASS: refused; both checkouts stayed clean and primary tracked bytes were unchanged.                                                |
| U2 revised, explicit linked root | PASS: records written and both working files archived in the target; primary clean and byte-identical; target code/tests unchanged. |

Raw captures include tool events and observer assertions:
[U1 baseline](runs/worktree-runtime-red-2026-10-11.json),
[U1 refusal](runs/worktree-runtime-refusal-2026-10-11.json),
[U2 assigned root](runs/worktree-runtime-green-2026-10-11.json).
The target code/test byte comparison was added before the final revised runs;
it is not present in the baseline U1 artifact. These checks establish file placement
and preservation, not complete semantic correctness of the gardened records.

## Host directory observation

The [host probe](runs/worktree-host-cwd-2026-10-11.json) launched a real Claude
`general-purpose` child from a linked worktree without supplying the child a
path. Both child commands, `pwd` and `git rev-parse --show-toplevel`, reported
that linked worktree. The alleged default-cwd failure was **not reproduced**
on this installed host. Explicit assignment still prevents silent checkout
selection when the dispatch lacks an authority boundary, as U1 demonstrates.
No Codex or Copilot host behavior was tested. Partial pairs, branch mismatch,
nested roots, symlink escapes and setup/copy conflicts were not exercised with
real file tools; relevant decision probes do not replace those runtime checks.

## Decision and reproduction

[AD-0004](../../../docs/decisions/0004-gardening-worktree-boundary.md) records
why the guardrail lives in the existing metapowers items. Upstream Superpowers
setup/transfer guidance is a separate contribution, not delivered here.

See [the scenario guide](worktree-scenarios.md) for all reproduction commands.
No activation descriptions or bundle manifests changed. Broader routing,
private-mode lifecycle and record-layout behavior remain outside this battery.
