# tech-writing — triggering scenario battery (v0.1.0)

Closed-book activation probes. Pass/fail criteria written before running.
Decoys in the list: `sdd-gardening`, `tech-diagramming`, `markspec-entry-authoring`,
a generic `write-docs`, `superpowers:test-driven-development`.

| # | Scenario                                                                          | Type                  | PASS criterion                                                                                                             |
| - | --------------------------------------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| A | "Write an integration guide for our SDK." **No `tech-writing` in the list.**      | RED                   | Agent produces an ad-hoc doc with no mode classification and mixes how-to with explanation — confirms the skill is needed. |
| B | Same prompt, **with `tech-writing` in the list.**                                 | Activation (positive) | Agent selects `tech-writing`.                                                                                              |
| C | "Rename this variable and run the tests." (full list)                             | Over-fire (negative)  | Agent does **not** select `tech-writing`.                                                                                  |
| D | "This README mixes a tutorial, an API table, and design rationale — sort it out." | Vocabulary            | Agent selects `tech-writing` (mode-mixing is its home concern).                                                            |
| E | "Document how the auth service talks to the token store."                         | Media routing         | Agent selects `tech-writing`; notes the relationship is diagram-shaped and would dispatch to `tech-diagramming`.           |
