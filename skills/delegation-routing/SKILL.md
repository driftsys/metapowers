---
schema: 1
name: delegation-routing
description: Use when dispatching a subagent for a planned task, choosing the model or reasoning effort of an implementer, reviewer, refuter or ops subagent, or deciding how many reviews a task needs.
license: MIT
metadata:
  version: 0.1.0
---

The class of a task decides which roles run, which model runs each role, and at
what reasoning effort. The `delegation-classes` rule gives each task its class;
this skill turns that class into dispatch settings.

## Roles and reviews per class

| Class    | Implementer     | Reviews before merge                    | Human         |
| -------- | --------------- | --------------------------------------- | ------------- |
| critical | strongest model | code review, compliance review, refuter | expert review |
| standard | versatile model | one code review                         | normal review |
| light    | versatile model | one light code review                   | normal review |
| ops      | ops model       | none; output is checked by tools        | none          |

- Dispatch the code reviewer and the refuter from the other model family than
  the implementer when the client offers both families.
- Give ops models read-only work: triage, log reading, exploration, merge
  request descriptions, tool runs.
- Give production code only to implementer models from the table in "Models".

## Reasoning effort

| Work                                            | Effort |
| ----------------------------------------------- | ------ |
| Local change that follows a pattern in the code | low    |
| Any other implementation, design, gardening     | medium |
| Code review, refuter, debugging a root cause    | high   |

Medium is the ceiling for implementation. Higher effort costs more for no
better result.

## Briefs

- Implementer: the spec section, the requirement ids, the failing test, and
  the task's class.
- Reviewer and refuter: the spec, the requirement, the plan task, the merge
  request description, and the diff as a file computed from the base recorded
  before the task started.

## Escalation

After two failed attempts at a task, dispatch the next attempt with the
strongest implementer model of the client.

## Overrides

Settings resolve in this order, and the later one wins: this skill, the
"Delegation" section of AGENTS.md, the user's request for the task. Write each
override in the plan task, for example
`Routing: refuter skipped (user, 2026-11-26)`.

## Models

Use the newest version of each named family that the client offers.

<!-- @client:claude -->

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

<!-- @endclient -->

<!-- @client:copilot -->

As of 2026-11-22. `copilot help config` lists the models the CLI accepts.

| Role                         | critical        | standard        | light       | ops        |
| ---------------------------- | --------------- | --------------- | ----------- | ---------- |
| Implementer                  | claude-opus-*   | claude-sonnet-* | gpt-*-terra | —          |
| Code review, refuter         | gpt-*-sol       | gpt-*-sol       | gpt-*-sol   | —          |
| Compliance review            | claude-sonnet-* | —               | —           | —          |
| Gardening: docs, specs, ADRs | claude-sonnet-* | gpt-*-terra     | gpt-*-terra | —          |
| Ops                          | claude-haiku-*  | gpt-*-luna      | gpt-*-luna  | gpt-*-luna |

When the implementer is a GPT model, dispatch the code reviewer and the
refuter with `claude-opus-*`.

<!-- @endclient -->

<!-- @client:codex -->

As of 2026-11-22.

| Role                         | critical    | standard    | light       | ops        |
| ---------------------------- | ----------- | ----------- | ----------- | ---------- |
| Implementer                  | gpt-*-sol   | gpt-*-sol   | gpt-*-terra | —          |
| Code review, refuter         | gpt-*-sol   | gpt-*-sol   | gpt-*-sol   | —          |
| Gardening: docs, specs, ADRs | gpt-*-terra | gpt-*-terra | gpt-*-terra | —          |
| Ops                          | gpt-*-luna  | gpt-*-luna  | gpt-*-luna  | gpt-*-luna |

Codex offers one model family. Write `Routing: no cross-family review` in each
critical task, so the human expert knows the review gap.

<!-- @endclient -->

Source: technote "AI coding for embedded production software: model choice
and SDD flow", data as of 19–22 November 2026. Re-assess this table monthly.

## Common mistakes

| Mistake                                          | Correction                                                         |
| ------------------------------------------------ | ------------------------------------------------------------------ |
| Choosing the model with the lowest cost per task | Use the table; cheap models need many attempts per working program |
| Giving the reviewer only the diff                | Add the spec, the requirement and the merge request description    |
| Raising effort above medium for implementation   | Raise effort only for review, refuter and debugging                |
| Letting an ops model edit production code        | Dispatch an implementer model from the table                       |
