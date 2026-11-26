---
name: delegation-routing
description: Use when dispatching a subagent for a planned task, choosing the model or reasoning effort of an implementer, reviewer, refuter or ops subagent, or deciding how many reviews a task needs.
---

The class of a task decides which roles run, which model runs each role, and at
what reasoning effort. The `delegation-classes` rule gives each task its class;
this skill turns that class into dispatch settings. The class sets the reviews
for all work, done inline or delegated. The model tables apply to the work you
delegate; you may do light and ops work yourself.

Dispatch a frontier model (Fable, Astra) only when the user asks for one.
When the strongest default model has also failed a task, or a consult in doubt
did not settle the question, suggest a frontier model to the user with the
reason, and wait for the answer.

## Roles and reviews per class

| Class    | Implementer     | Reviews before merge                    | Human         |
| -------- | --------------- | --------------------------------------- | ------------- |
| critical | strongest model | code review, compliance review, refuter | expert review |
| standard | versatile model | one code review                         | normal review |
| light    | versatile model | one light code review                   | normal review |
| ops      | ops model       | none; output is checked by tools        | none          |

- Dispatch the code reviewer and the refuter from the other model family than
  the implementer when the client offers both families.
- Give ops models two kinds of work:
  - Read-only work: triage, log reading, exploration, summaries, merge request
    descriptions, tool runs.
  - Bulk mechanical work: classification, tagging and extraction across many
    files or records, and edits that change no behavior. Name the tool that
    checks each edit (formatter, linter, compiler, tests) in the brief. Split
    the work into batches only when it does not fit in one subagent's context.
- Give a change that needs a decision to an implementer model; it takes the
  class of its code.
- Give production code only to implementer models from the table in "Models".

## Reasoning effort

| Work                                            | Effort |
| ----------------------------------------------- | ------ |
| Local change that follows a pattern in the code | low    |
| Any other implementation, design, gardening     | medium |
| Code review, compliance review, refuter         | high   |
| Debugging a root cause                          | high   |
| Read-only ops work, bulk mechanical work        | low    |

Medium is the ceiling for implementation. Higher effort costs more for no
better result.

## Briefs

- Implementer: the spec section, the requirement ids, the failing test, and
  the task's class.
- Reviewer and refuter: the spec, the requirement, the plan task, the merge
  request description, and the diff as a file computed from the base recorded
  before the task started.

## Escalation

Follow the fix loop of the workflow you run, for example the one in
`superpowers:subagent-driven-development`, for when to move a task to a more
capable model. This skill decides which model each class starts with.

## Consult a deep-thinking model in doubt

When the session runs on a model below the strongest of the client, consult
the strongest model in a subagent before you plan in these cases: the class of
a task stays uncertain after the `delegation-classes` rule, a critical task has
no clear design, or two routings both look valid. Give it the task, the class
and the question, and follow its answer or report the disagreement to the user.

## Overrides

Settings resolve in this order, and the later one wins: this skill, the
"Delegation" section of AGENTS.md, the user's request for the task. Write each
override in the plan task, for example
`Routing: refuter skipped (user, 2026-11-26)`.

## Vendor recommendations

Use these when no table in "Models" covers the work, for example a new kind of
task or a model the tables do not name. Sources fetched 2026-11-26.

| Family | The vendor recommends it for                                                                   |
| ------ | ---------------------------------------------------------------------------------------------- |
| Fable  | Demanding reasoning, agent sessions that run for hours, when Opus at higher effort falls short |
| Opus   | Most workloads; long-running agentic coding, large-scale refactoring, complex systems          |
| Sonnet | Everyday coding, agent and enterprise work; subagents under an Opus orchestrator               |
| Haiku  | High-volume, latency-sensitive work: classification, routing, extraction, subagent tasks       |
| Astra  | The hardest projects; long-horizon coding with continuous planning                             |
| Sol    | Complex coding, computer use, professional work                                                |
| Terra  | Everyday agentic coding and terminal work; clear writing                                       |
| Luna   | Focused, high-volume, cost-sensitive tasks                                                     |

- Anthropic: an Opus orchestrator with Sonnet subagents cost about a third less
  and scored about the same as Opus alone. Haiku subagents are "an alternative
  to lowering effort, not better". Keep one dependent chain of work in one
  session instead of splitting it across subagents.
- Anthropic: tuning effort is often a better lever than switching models.

Sources: platform.claude.com/docs/en/about-claude/models/choosing-a-model,
platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence,
developers.openai.com/api/docs/models,
docs.github.com/en/copilot/reference/ai-models/model-comparison.

## Models

Use the newest version of each named family that the client offers.

As of 2026-11-22. Set the model with the `model` parameter of the `Agent`
tool.

| Role                         | critical | standard | light  | ops   |
| ---------------------------- | -------- | -------- | ------ | ----- |
| Implementer                  | opus     | sonnet   | sonnet | —     |
| Code review, refuter         | opus     | opus     | sonnet | —     |
| Compliance review            | sonnet   | —        | —      | —     |
| Gardening: docs, specs, ADRs | sonnet   | sonnet   | sonnet | —     |
| Ops                          | haiku    | haiku    | haiku  | haiku |

Claude Code offers one model family. Write
`Routing: no cross-family review` in each critical task, so the human expert
knows the review gap.

Source: technote "AI coding for embedded production software: model choice
and SDD flow", data as of 19–22 November 2026. Re-assess this table monthly.

## Common mistakes

| Mistake                                          | Correction                                                         |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| Choosing the model with the lowest cost per task | Use the table; cheap models need many attempts per working program |
| Giving the reviewer only the diff                | Add the spec, the requirement and the merge request description    |
| Raising effort above medium for implementation   | Raise effort only for review, refuter and debugging                |
| Letting an ops model edit production code        | Dispatch an implementer model from the table                       |
