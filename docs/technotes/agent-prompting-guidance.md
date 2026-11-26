# Tech note: vendor prompting guidance for coding-agent rules

**Status:** Informative
**Date:** 2026-11-26 (all sources checked on this date)
**Scope:** The vendor guidance that applies when writing always-loaded rules
for coding agents (Claude Code, Copilot CLI, Codex), with the models current on
the date above. It is the source list behind the `scope-discipline` rule and
its evaluation in `tests/spec/scope-discipline/`.

> This note explains; nothing depends on it. Model guidance changes between
> versions. Before relying on a statement below, check the source page for the
> model in use, and update this note when a newer page replaces one listed here.

## 1. Sources in use

### Anthropic — per-model prompting pages

These pages apply to the newest Claude models. Prefer them over the general
best-practices page when the two disagree.

| Page                                         | Models                | What it says that matters for rules                                                                                                                                                                                                                                                                                                                                                                                             |
| -------------------------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Prompting Claude Opus 5.5][opus-5-5]        | Opus 5.5              | Medium effort is the default and matches Opus 5 at high. "Remove instructions that stood in for thinking." "Treat a text-only end of turn as a report rather than as proof the task is done." The stops the user wants "are the ones where nothing can move without them." Nothing on over-engineering.                                                                                                                         |
| [Prompting Claude Sonnet 5.5][sonnet-5-5]    | Sonnet 5.5            | Names the tendency to add "tests, documentation, and small supporting files" that nobody asked for. Suggested text: "Don't add features, tests, files, docs, or refactors that weren't asked for. If you think one would help, mention it at the end instead of doing it." Recommends "a real check that exercises the change" (a syntax-only check "does not count"), and no extra rounds of review or hardening unless asked. |
| [Prompting Claude Haiku 5.5][haiku-5-5]      | Haiku 5.5             | Same scope and check text as Sonnet 5.5. At low effort the model is "more likely to skip a search, stop early, or skip a check"; raising effort to medium "roughly halved" early stopping. Blanket instructions ("search for any present-day factual question…") cause over-triggering.                                                                                                                                         |
| [Prompting Claude Fable 5.2][fable-5-2]      | Fable 5.2, Mythos 5.2 | "The model treats an instruction that contains 'never' as absolute": reword prohibitions as actions ("ask for approval before deleting files"). Ownership framing ("you are the owner and long-term maintainer") caused changes nobody asked for. A short note "No drive-by refactors, renames or cleanups" did not stop consolidation.                                                                                         |
| [Prompting Claude Opus 5][opus-5]            | Opus 5                | Superseded for Opus by the 5.5 page, but its warning still applies to rules shared across models: explicit verification instructions "cause over-verification… remove them". Check in "only when different readings of the request would lead to materially different work".                                                                                                                                                    |
| [Claude prompting best practices][claude-bp] | All Claude models     | General page. Over-engineering sample: "Only make changes that are directly requested or clearly necessary", no abstractions for one-time operations, no docs or annotations on code you did not change. "CRITICAL: You MUST…" wording makes recent models over-trigger. `default_to_action`: "infer the most useful likely action and proceed".                                                                                |

### Anthropic — Claude Code instruction files

These pages cover `CLAUDE.md` and `.claude/rules/` files, which is where an
upskill rule is installed for Claude Code.

| Page                                           | Date or version                     | What it says that matters for rules                                                                                                                                                                                                                                                                                                   |
| ---------------------------------------------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Claude Code best practices][cc-bp]            | Names Opus 5.5 as the default model | "Keep CLAUDE.md short." Include what Claude cannot find by reading the code, and "anything you've had to correct twice already". Adding IMPORTANT "probably won't fix it": a rule that needs repeated emphasis belongs in a hook. "Claude is allowed to decide a guideline doesn't apply." Check that files load with `/context all`. |
| [How Claude remembers your project][cc-memory] | Claude Code v2.1.309                | "Target under 200 lines per CLAUDE.md file"; longer files reduce adherence. Write concrete instructions ("Run `npm test` before committing", not "Test your changes"). CLAUDE.md is "context, not enforced configuration": use hooks or deny rules for hard limits. Claude reads AGENTS.md only when no CLAUDE.md exists.             |
| [Steering Claude Code][cc-steering]            | 2026-06-18                          | Procedures go in skills, area-specific constraints in path-scoped rules, guardrails in hooks or permissions. Adherence drops in long sessions and when appended instructions conflict.                                                                                                                                                |

### OpenAI — Codex

| Page                                               | Models                     | What it says that matters for rules                                                                                                                                                                                                                          |
| -------------------------------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Prompting GPT-6.2 in Codex][codex-6-2]            | GPT-6.2 Astra, GPT-6.2 Sol | Nothing on over-engineering or clarifying questions. "Tell it what counts as finished and where you want it to be exhaustive." "Keep your AGENTS.md lean": only conventions "that Codex can't infer from the code, tests, or docs".                          |
| [Codex best practices][codex-bp]                   | Current Codex models       | A prompt states goal, context, constraints and a "done when" condition. Add AGENTS.md rules when the agent repeats a mistake.                                                                                                                                |
| [Custom instructions with AGENTS.md][codex-agents] | Current Codex models       | How Codex combines global and per-directory AGENTS.md files: closer files take effect over earlier ones.                                                                                                                                                     |
| [Codex Prompting Guide][codex-guide]               | GPT-5.1-Codex-Max (older)  | Older than GPT-6.2, kept for wording that the newer page does not cover: "do not end your turn with clarifications unless truly blocked", "conform to the codebase conventions", "cover the root cause or core ask, not just a symptom", "DRY/search first". |

### GitHub — Copilot CLI built-in prompt

Copilot CLI refuses to print its system prompt, but it stores every system
message it sends in `~/.copilot/session-state/<session-id>/events.jsonl` (the
`content` of the `system.message` event). Run it with
`--no-custom-instructions` so that only the built-in prompt is captured.

Captured from Copilot CLI 1.0.116, default model Claude Sonnet 5.5, in
non-interactive (`-p`) and interactive mode. The code-change sections are the
same in both modes:

- "Make precise, complete, surgical changes that fully address the request;
  prefer completeness over a minimal but incomplete fix, and avoid unrelated
  changes."
- "Don't fix unrelated pre-existing issues, but do fix bugs caused by or
  tightly coupled to your changes."
- "Add tests only for behavior this change introduces or fixes."
- "Run the smallest command covering the change."
- "Ask for guidance if uncertain." Interactive mode adds an `ask_user` section
  that says to stop and ask on design decisions, behavior questions, scope
  ambiguity and "edge cases where multiple reasonable approaches exist".

Copilot does not show this text in its documentation. The captured content is
specific to the version above and changes between releases.

## 2. Where the sources agree

| Topic                 | Agreement                                                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Unrequested additions | Claude pages and the Codex guide: change only what was asked or clearly needed. Sonnet 5.5 and Haiku 5.5: mention extras at the end instead.                                           |
| Completeness          | Codex, Copilot, Sonnet 5.5 and Haiku 5.5: fix the cause and finish everything asked.                                                                                                   |
| Ambiguity             | All current sources: ask only when readings lead to materially different work; otherwise state the assumption and continue. Copilot's interactive prompt asks more often (edge cases). |
| Verification          | One real check of the change. No "loop until verified" (Opus 5) and no extra review rounds (Sonnet 5.5).                                                                               |
| Wording               | Calm instructions, written as actions. No MUST/NEVER/CRITICAL (Claude best practices, Fable 5.2).                                                                                      |
| Size                  | Keep always-loaded files short (Codex "lean AGENTS.md").                                                                                                                               |

## 3. Sources reviewed and not used

| Source                                                                  | Reason                                                                                                                                                                                                                                                                                                                                           |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Karpathy guidelines (`forrestchang/andrej-karpathy-skills`, and copies) | The origin of `karpathy-guidelines`. Written before the current models; its "if uncertain, ask" and "loop until verified" go against the current guidance above.                                                                                                                                                                                 |
| [Claude Code playbook][playbook] (core rules, factual guardrails)       | A company's setup (Force Information Systems), described as patterns from 900+ sessions on TypeScript projects and written for Opus 4.7. No public data on its adoption was found. Its figures have no sources, and many rules depend on its own hooks and commands. Its "Definition of Done" checklist inspired one line of `scope-discipline`. |
| Posts reporting large error reductions from CLAUDE.md rules             | No method that can be checked.                                                                                                                                                                                                                                                                                                                   |

## 4. Effect measured in this repository

`tests/spec/scope-discipline/` records RED and GREEN runs of the
`scope-discipline` rule on Opus 5.5, Sonnet 5.5 and Copilot CLI. The rule fixed
incomplete fixes and code written to satisfy a wrong test. The ambiguity
counter helped but is not reliable. The scope sections showed no measurable
effect on the small fixture (follow-up: issue #81).

## 5. Lineage of `scope-discipline`

`scope-discipline` is derived from the `karpathy-guidelines` rule, which
metapowers shipped until version 0.2.4. That rule was a copy of the Karpathy
guidelines from
[multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills)
(MIT), based on Andrej Karpathy's observations on LLM coding mistakes. The rule
records this in its `derived_from` and `derived_from_license` metadata.

The rewrite keeps two of the four original principles and changes the other
two, following the sources in section 1:

| Karpathy principle                            | In `scope-discipline`                                                                                                                                                                                     |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Simplicity first                              | Kept as "Do what was asked", with the Sonnet 5.5 and Haiku 5.5 alternative: mention extras at the end instead of making them.                                                                             |
| Surgical changes                              | Kept as "Stay within the task". Tests and docs wording aligned with the Copilot CLI prompt.                                                                                                               |
| Think before coding ("if uncertain, ask")     | Replaced by "When the request is ambiguous": ask only when readings lead to materially different work, otherwise state the assumption; when asking is not possible, choose a reading and name the others. |
| Goal-driven execution ("loop until verified") | Replaced by "Do the whole task": fix the cause everywhere, check each part of the request, run one real check, and start no extra review rounds.                                                          |

The original "bias toward caution over speed" tradeoff line is removed, because
the current guidance asks the agent to act and finish the work. The name
changed because the rule no longer reflects the original text, and an item name
should describe the behavior it asks for.

[opus-5-5]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5
[sonnet-5-5]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5-5
[haiku-5-5]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-haiku-5-5
[fable-5-2]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2
[opus-5]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5
[claude-bp]: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
[codex-6-2]: https://learn.chatgpt.com/codex/learn/prompting-gpt-6-2-astra
[codex-bp]: https://developers.openai.com/codex/learn/best-practices
[codex-agents]: https://developers.openai.com/codex/guides/agents-md
[codex-guide]: https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide
[playbook]: https://ao92265.github.io/claude-code-playbook/rules/core-rules/
[cc-bp]: https://code.claude.com/docs/en/best-practices
[cc-memory]: https://code.claude.com/docs/en/memory
[cc-steering]: https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more
