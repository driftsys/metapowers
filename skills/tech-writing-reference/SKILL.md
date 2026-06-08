---
schema: 1
name: tech-writing-reference
description: Use when tech-writing has classified the document as reference — an API reference, CLI reference, configuration reference, or changelog or release notes.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-writing` classified this document as **reference**.
Reference exists for **looking things up** during work. It is exhaustive,
austere, and predictable: the reader knows what they want and needs to find it
fast and trust it completely.

Reader's stance: **cognition + application** — consulting, while at work. The
reader is not reading the document end to end; they jump to one entry, take the
fact, and leave.

## The shape

Reference is the standard shape for an API reference, a CLI reference, a
configuration reference, and a changelog or release notes. Build every one this
way:

- **Consistent per-entry structure.** Every entry carries the **same fields in
  the same order** — name, signature, parameters, return, errors, example, or
  whatever the kind demands. Predictability is the whole value: the reader learns
  the pattern once and applies it everywhere.
- **Complete coverage.** Document every endpoint, flag, and option. A reference
  with gaps cannot be trusted, and an untrustworthy reference is worse than none.
- **Terse, neutral descriptions.** State what each thing is and does in the
  fewest words. No narrative, no persuasion.
- **Generate from the source of truth where possible.** Derive an API reference
  from OpenAPI, a CLI reference from `--help`, a configuration reference from the
  schema. For a changelog, follow [Keep a Changelog](https://keepachangelog.com)
  and drive entries from conventional commits. Generated reference does not drift;
  hand-written reference does.

## Do

- **Be exhaustive and consistent.** Same fields, same order, every entry, nothing
  omitted.
- **Generate from source.** Prefer a derived reference over a hand-maintained one
  wherever a source of truth exists.

## Don't

- **Don't teach or argue.** No tutorials, no rationale. If the reader needs to
  learn the concept, link out to an explanation; if they need to accomplish a
  task, link out to a how-to.
- **Don't editorialise.** No "conveniently", no "simply", no opinion. State the
  fact and stop.

## Mandatory deferral — requirement entries are `markspec-*`'s job

When the reference document is a **specification (requirements) document**, this
skill shapes the **surrounding reference document** — its structure, grouping,
and completeness — but it does **not** own the requirement entries. **Defer the
requirement-entry syntax to `markspec-*`**: EARS and Gherkin phrasing, entry IDs,
and traceability are `markspec-*`'s domain. Shape the document; let `markspec-*`
shape the entries inside it.

## Where the boundary blurs

- **vs `tech-writing-explanation`.** Reference is for **looking things up** ("what
  this flag does"); an explanation is for **understanding** ("why it works this
  way"). If you catch yourself explaining reasoning or weighing tradeoffs, that
  content belongs in an explanation — see `tech-writing-explanation` — and the
  reference links to it.

## Verify

Apply the cross-cutting verify checklist in the `tech-writing` umbrella (§5):
mode purity, house style, accessibility, and the no-drift checks — especially
**no stale signatures, flags, or version numbers**, and reference content
generated from source where possible.
