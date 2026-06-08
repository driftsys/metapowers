---
schema: 1
name: tech-writing
description: Use when writing or reviewing any technical document — a tutorial, how-to, integration or usage guide, runbook, API/CLI/config reference, changelog, specification, architecture or design doc, concept note, ADR, or README.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

This is the **entry point and decision layer** for every technical document. It
owns the cross-cutting decisions — **which Diátaxis mode**, **how to structure
it**, **which medium carries each idea**, **how to keep it from drifting** — then
**dispatches** to a per-mode skill for the depth. It does not teach
tutorial, how-to, reference, or explanation craft itself.

**Core principle: _one document, one Diátaxis mode._** A document that mixes
modes confuses its reader; classify first, then keep it pure.

**Inherited principle: _documentation describes code+tests; it never drives
them._** Tests are the spec, code is the implementation, and the doc is derived
from both. When prose and code+tests disagree, code+tests win. The verify phase
(§5) actively guards this.

Activate when you are about to write or review a technical document. Run the
phases in order: **classify → structure & media → style → verify → dispatch**
(§§1–6). Classify spans two sections: the genre→mode routing table (§1) and the
one-mode rule it enforces (§2).

## 1. Classify — the genre→mode routing table

The user names a genre; this table maps it to its dominant Diátaxis mode. A
secondary mode is allowed **only** as a clearly separated section or a link-out,
never woven through.

| Genre                                                 | Primary mode                  | Defers to / generated from                                                                |
| ----------------------------------------------------- | ----------------------------- | ----------------------------------------------------------------------------------------- |
| Tutorial / getting-started / quickstart               | tutorial                      | —                                                                                         |
| Integration guide                                     | how-to (+ reference link-out) | —                                                                                         |
| Usage guide / task recipe / runbook / troubleshooting | how-to                        | —                                                                                         |
| API / CLI / configuration reference                   | reference                     | generate from OpenAPI / `--help` / schema                                                 |
| Changelog / release notes                             | reference                     | Keep a Changelog / conventional commits                                                   |
| Specification (requirements)                          | reference (normative)         | **`markspec-*`** owns entry syntax                                                        |
| Architecture / design                                 | explanation (+ reference)     | **`sdd-gardening`** places it in `docs/design`                                            |
| Concept / "why" / background                          | explanation                   | —                                                                                         |
| Decision record (ADR)                                 | explanation + reference       | **`sdd-gardening`** (`docs/decisions`), MADR shape                                        |
| README                                                | front-door blend              | **special case: route, don't contain** — pitch + quickstart link + links out to the modes |

Two deferrals are mandatory, not optional:

- **Specification → `markspec-*`.** Shape the surrounding document, but hand the
  requirement-entry syntax (EARS, Gherkin, IDs, traceability) to `markspec-*`.
- **Architecture / design and ADR → `sdd-gardening`.** Shape the prose, but let
  `sdd-gardening` decide which durable record exists and where it lives
  (`docs/design`, `docs/decisions`). Use the MADR shape for an ADR.

## 2. The one-mode rule (Diátaxis)

The four modes sit on two axes — **action ↔ cognition** (doing vs thinking) and
**acquisition ↔ application** (study vs work):

| Mode        | Axes                    | Reader's stance         |
| ----------- | ----------------------- | ----------------------- |
| Tutorial    | action + acquisition    | learning by doing       |
| How-to      | action + application    | a goal-oriented recipe  |
| Reference   | cognition + application | information for work    |
| Explanation | cognition + acquisition | understanding the "why" |

**Cardinal rule: one document serves one mode.** Detect mixing and fix it.

- **Detect** the common mixes: a step list inside an explanation, a digression
  into theory inside a tutorial, a how-to recipe wedged into a reference entry,
  a "why we built it this way" essay inside a quickstart.
- **Fix** by **splitting** the document into one file per mode, or **linking
  out** to the mode that owns the displaced content. Never resolve a mix by
  weaving the second mode through the first.

## 3. Structure & media

### (a) Genre structure

Each genre has a standard shape — a tutorial's numbered, choice-free arc; a
how-to's goal-titled task; a reference's consistent per-entry structure; an
explanation's discursive argument. The umbrella names the shape and **dispatches
the detail to the mode skill** (§6). Do not invent a structure when the genre
already has one.

### (b) Media selection

Pick the medium that carries the idea with the least reader effort and the least
maintenance cost — **every non-prose artifact is a drift surface.** Ask, in
order:

1. A sequence of actions? → **numbered list** (or a runnable code block if the
   steps are commands).
2. Items sharing a fixed set of attributes to compare or look up? → **table**
   (≥ 3 items × ≥ 2 attributes, or parallel sentences trying to escape prose).
3. How things connect, flow, or change state — relationships dominate? →
   **diagram → dispatch to `tech-diagramming`** (more than ~3 relationships in
   prose is a graph the reader is reconstructing; draw it).
4. The exact artifact to copy? → **code block** (runnable and tested per §5).
5. Term → meaning pairs? → **description list**.
6. Reasoning, the "why", narrative? → **prose** (the default and connective
   tissue).

| Medium           | Reach for it when                                 | Avoid it when                               |
| ---------------- | ------------------------------------------------- | ------------------------------------------- |
| Prose            | reasoning, the "why", narrative, tradeoffs        | listing parallel facts (→ table/list)       |
| Numbered list    | ordered steps; order matters                      | unordered peers (→ bullets)                 |
| Bulleted list    | a handful of unordered peer items                 | items share comparable attributes (→ table) |
| Table            | ≥ 3 items × ≥ 2 shared attributes; lookup/compare | one dimension (→ list); narrative (→ prose) |
| Diagram          | structure / flow / state — relationships dominate | a table or short list already conveys it    |
| Code block       | exact commands/config/API to copy                 | conceptual content (→ prose)                |
| Description list | term → definition pairs                           | > 2 columns of data (→ table)               |

Meta-rules:

- **One medium per idea.** Never state the same thing in prose _and_ a table —
  the duplicate is a pure drift surface.
- **The medium leans with the mode.** Reference favours tables and code;
  explanation favours prose and diagrams; how-to favours numbered lists and
  code; tutorial favours numbered steps and expected-output blocks.

When the answer is a diagram, this skill stops at the _decision_ — dispatch the
diagram itself to `tech-diagramming`, which owns tool, storage, render, and
style.

## 4. Style — defer to `tech-writing-style`

The `tech-writing-style` rule is always loaded and governs voice, person, tense,
headings, lists, accessibility, and link text. Do not restate it here. It
defers word-list and capitalization rulings in precedence order: the consumer
repo's own house style, then the Google developer documentation style guide,
then the Chicago Manual of Style. Apply the rule as written.

## 5. Verify — checklist + drift (tooling optional)

The gate is a **checklist you apply**, plus **human review for load-bearing
docs**. Three layers:

**Layer 0 — Mode purity.** Is the document exactly one Diátaxis mode (§2)? If a
second mode has crept in, split or link out before shipping.

**Layer 1 — Conformance.** Checklist:

- [ ] **House style holds** — every `tech-writing-style` rule (§4): second
      person, active voice, present tense, sentence-case headings, consistent
      locale, code in code formatting.
- [ ] **Genre structure holds** — the document follows the standard shape for
      its genre (§3a).
- [ ] **Accessibility holds** — alt text on every image, descriptive link text
      (never "click here"), no skipped heading levels under a single `<h1>`.

**Layer 2 — Derived / no-drift** (the metapowers-specific layer):

- [ ] **Every code sample is runnable and matches the current API** —
      executable in CI where possible (doctest / rustdoc / mdBook), else traced
      to a real test.
- [ ] **No stale signatures, flags, or version numbers** — reference content is
      generated from source (OpenAPI / `--help` / schema) where possible.
- [ ] **The doc ships in the same PR** as the code it describes.
- [ ] **Code+tests win.** If prose and code+tests disagree, update the prose;
      never edit the code to match the doc.

**Optional CI gate.** Vale (Google package) + markdownlint + a link checker
catch Layer-1 and stale-link issues mechanically. Offer them as an **optional**
gate the consumer repo opts into — never a hard dependency, and never a blocker
for shipping a doc.

## 6. Dispatch

Once the mode is fixed, **follow the per-mode skill** for the genre's structure
and prose depth:

| Mode        | Skill                      |
| ----------- | -------------------------- |
| Tutorial    | `tech-writing-tutorial`    |
| How-to      | `tech-writing-howto`       |
| Reference   | `tech-writing-reference`   |
| Explanation | `tech-writing-explanation` |

These mode skills do not exist yet (Phase 2). If a mode skill is **absent**, do
not block: apply §§2–5 inline — keep the document to one mode, choose the
medium, obey `tech-writing-style`, run the verify checklist — and use general
knowledge for the genre's structure. The umbrella's decisions stand on their
own; the mode skills only add depth.
