---
schema: 1
name: tech-writing-explanation
description: Use when tech-writing has classified the document as explanation — an architecture or design narrative, a concept or "why" or background note, or a decision record (ADR).
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-writing` classified this document as **explanation**.
An explanation builds **understanding**: the "why", the background, the
tradeoffs. The reader is studying, not doing — sitting back to grasp how
something works and why it is the way it is, away from the keyboard.

Reader's stance: **cognition + acquisition** — thinking, to understand. The
reader is not trying to accomplish a task right now; they want the mental model
that makes later tasks make sense.

## The shape

An explanation is the standard shape for an architecture or design narrative, a
concept or "why" or background note, and a decision record (ADR). Write every one
this way:

- **Discursive prose.** Connected paragraphs that develop an argument, not a
  list of facts. Prose is the medium of explanation.
- **Admit alternatives and tradeoffs.** Name the options that were considered and
  say honestly why this one was taken and what it costs. An explanation that
  pretends there was only one choice teaches nothing.
- **Give context and consequences.** Place the topic in its surroundings — what
  led here, what depends on it, what follows from it.
- **No step lists, no numbered procedures.** The moment you write "Step 1", you
  have drifted into how-to or tutorial territory.

## Do

- **Explain one topic.** Keep the document to a single subject and follow its
  argument through.
- **Discuss alternatives honestly.** Show the roads not taken and the reasoning,
  so the decision survives the people who made it.
- **Connect to the bigger picture.** Relate the topic to the system around it and
  the forces that shaped it.

## Don't

- **Don't slip into instructions.** If you start telling the reader what to do
  next, that content belongs in a how-to or tutorial — link out to it.
- **Don't dump reference material.** Exhaustive field-by-field tables belong in a
  reference — see `tech-writing-reference`; an explanation cites them, it does not
  become one.

## Decision records — the MADR shape

For a decision record (ADR), use the **MADR** shape: **context → decision →
consequences**. State the forces and constraints at play, the decision taken, and
what that decision binds and costs downstream.

## Mandatory deferral — placement is `sdd-gardening`'s job

This skill shapes the **prose**. It does not decide which durable record exists
or where it lives. For an architecture or design narrative and for an ADR, **defer
placement to `sdd-gardening`** — it owns whether the record belongs in
`docs/design` or `docs/decisions`, the file naming, and the traceability. Write
the explanation well; let `sdd-gardening` garden it into the right home.

## Where the boundary blurs

- **vs `tech-writing-reference`.** An explanation is for **understanding** ("why
  it works this way"); a reference is for **looking things up** ("what this flag
  does"). If the reader wants a fact mid-task rather than a mental model, it is
  reference — see `tech-writing-reference`.

## Verify

Apply the cross-cutting verify checklist in the `tech-writing` umbrella (§5):
mode purity, house style, accessibility, and the no-drift checks (any code or
signatures cited match the current API, nothing stale, ships with the code).
