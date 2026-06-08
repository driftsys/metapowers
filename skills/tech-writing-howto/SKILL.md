---
schema: 1
name: tech-writing-howto
description: Use when tech-writing has classified the document as how-to — an integration guide, usage guide, task recipe, runbook, or troubleshooting guide.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-writing` classified this document as **how-to**. A
how-to serves a **competent** reader who already knows the domain and is pursuing
one specific goal. It is a recipe, not a lesson: you assume the reader's
competence and take them by the shortest reliable path to a result.

Reader's stance: **action + application** — at work, getting something done, not
studying. The reader arrives with a goal in mind and leaves when the goal is met.

## The shape

A how-to is the standard shape for an integration guide, a usage guide, a task
recipe, a runbook, and a troubleshooting guide. Build every one this way:

1. **Goal-titled heading** — name the goal as the title: "To integrate the
   payments SDK", "To roll back a failed deploy". The reader scans titles to find
   the one task they want.
2. **Prerequisites and assumptions up front** — state what the reader must
   already have (versions, credentials, prior steps) before the first
   instruction, so they fail fast rather than mid-recipe.
3. **Ordered, minimal steps to the goal** — a numbered list of imperative steps,
   each the next action and nothing more. Cut any step that does not move the
   reader towards the goal.
4. **The expected result** — show what success looks like (the output, the new
   state) so the reader knows they are done.
5. **Stop at the goal** — end when the goal is reached. Do not continue into
   adjacent tasks or background.

## Do

- **Assume competence.** Write for someone who knows the field but not this
  particular task.
- **One goal per guide.** A second goal is a second how-to.
- **Use imperative steps.** "Run", "set", "verify" — one action per step.
- **Put the conditional clause before the instruction.** "If the build fails,
  clear the cache", not "clear the cache if the build fails".

## Don't

- **Don't teach or build concepts.** No "what is a webhook" detours. If the
  reader needs the concept, link out to an explanation.
- **Don't digress into "why".** The rationale belongs in an explanation; a
  how-to states the action, not its justification.
- **Don't branch into every variation.** Cover the goal's happy path; push edge
  cases and alternatives to their own how-tos or a reference.

## Where the boundary blurs

- **vs `tech-writing-tutorial`.** A how-to serves a **competent** reader chasing
  a **goal**; a tutorial serves a **newcomer** whose goal is **learning**. If the
  reader does not yet know the domain and needs a guaranteed-to-work guided
  lesson, it is a tutorial — see `tech-writing-tutorial`.
- **vs `tech-writing-explanation`.** The moment you find yourself explaining why
  an approach works or weighing alternatives, you have left how-to. Move that
  material to an explanation — see `tech-writing-explanation` — and link to it.

## Verify

Apply the cross-cutting verify checklist in the `tech-writing` umbrella (§5):
mode purity, house style, accessibility, and the no-drift checks (every command
runnable and matching the current API, no stale flags, ships with the code).
