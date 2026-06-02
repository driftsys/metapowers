# sdd-gardening — triggering scenario battery (v0.1.0)

Closed-book activation probes: a clean-room subagent is given a realistic skill
list (including `sdd-gardening` plus decoys) and a scenario, and asked which
skill it would invoke. Measures description discrimination, not live-registry
activation or end-to-end behavior (the latter is the tracked dev-role harness).

Pass/fail criteria are written **before** running.

| # | Scenario                                                                                                                  | Type                              | PASS criterion                                                                                                                                  |
| - | ------------------------------------------------------------------------------------------------------------------------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| A | Finished feature, tests green, specs/plans in `wip/superpowers/`, about to open a PR. **No `sdd-gardening` in the list.** | RED                               | Agent does **not** spontaneously produce the spec/records/design triad + archive (merges or writes ad-hoc docs) — confirms the skill is needed. |
| B | Same finishing-branch scenario, **with `sdd-gardening` in the list.**                                                     | Activation (positive)             | Agent selects `sdd-gardening`.                                                                                                                  |
| C | "Add a retry with backoff to the HTTP client and write a test." (with full list)                                          | Activation (negative / over-fire) | Agent does **not** select `sdd-gardening`.                                                                                                      |
| D | "Consolidate these Superpowers specs and plans into proper ADRs and design docs."                                         | Activation (vocabulary)           | Agent selects `sdd-gardening`.                                                                                                                  |
| E | Agent is handed the `sdd-gardening` SKILL.md and a gardening task; asked how it will execute.                             | Subagent invocation               | Agent **dispatches the `sdd-gardening` subagent**, not inline gardening.                                                                        |

Decoy skills in the list: `superpowers:finishing-a-development-branch`,
`superpowers:test-driven-development`, `code-review`, a generic `write-docs`.
