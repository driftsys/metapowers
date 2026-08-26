---
schema: 1
name: tech-diagramming-ascii
description: Use when tech-diagramming has selected ASCII — inline monospace diagrams in code comments, READMEs, and console/CLI output. Covers the scratch vs durable split, shape routing, grid-code width discipline, charset rules, and the Phase-1 self-check.
license: MIT
metadata:
  version: 0.2.3
---

## Overview

You are here because `tech-diagramming` already selected ASCII. This skill is the
doing layer for **inline monospace diagrams** — in code comments, READMEs,
console/CLI help, and plain-text docs. It does NOT redo tool selection; the
umbrella owns that.

Core principle: **render, don't draw.** ASCII alignment errors are a structural
LLM failure — you generate token-by-token with no 2D model, and **token count is
not column count.** So do not draw a picture and hope it lines up. **Compute the
widths, then emit exactly those characters.**

## Two modes — know which one you are in

| Mode        | Where                                                       | Bar                                                             | Tooling                              |
| ----------- | ----------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------ |
| **Scratch** | `.scratch/`, thinking out loud                              | freehand is fine, disposable                                    | none — no validation                 |
| **Durable** | README, in-code comments, console/CLI help, maintainer docs | **must be perfectly aligned** — it renders in monospace forever | this skill's discipline + self-check |

Scratch is throwaway: misaligned is acceptable because nobody keeps it. Everything
below is for **durable** ASCII. If the diagram is scratch, stop reading and
freehand it.

## ASCII stays simple — route by shape

Inline ASCII is for **a few boxes, a pipeline, a tree, a table, a byte layout** —
nothing that needs auto-layout. A graph complex enough to need layout
**escalates to a PlantUML or D2 SVG, it does not get crammed into ASCII** (there is
no external ASCII renderer). Route by shape:

| Shape                                      | Fits ASCII?       | Example                                    |
| ------------------------------------------ | ----------------- | ------------------------------------------ |
| Small node-edge graph (≤ ~6 boxes)         | yes               | a 3-stage pipeline                         |
| Tree / hierarchy                           | yes               | a module or call tree                      |
| Table / grid                               | yes               | a state-transition table                   |
| Byte / packet layout                       | yes               | a wire-format header                       |
| Complex / dense graph (auto-layout needed) | **no → escalate** | back to `tech-diagramming` → PlantUML / D2 |

## The two levers against miscounting

**Lever 1 — grid-code: do not make the AI count; compute widths.**
**grid-code** — compute every position and width rather than eyeballing them.
Scope: ≤ 3 boxes may freehand; **≥ 4 boxes use grid-code** (computed widths).
Before drawing:

1. Find the longest label.
2. Set a fixed cell width = longest label + 2 (one space of padding each side).
3. Pad every label to that exact width.
4. Emit each border as **exactly** that many characters.
5. **State the widths in your reasoning before you draw the diagram.**

(Phase 2 `diagctl ascii`, story #14, will do this counting deterministically — the
AI will supply only structure. Nothing here depends on it yet.)

**Lever 2 — charset by who emits it.** When **you hand-emit** (Phase 1 — always
right now): use **ASCII `+ - |`** only. Each is 1 byte and 1 column, so it is
countable. Unicode box-drawing (`┌ ─ │`) is reserved for when a tool emits it
(Phase 2). **Never mix charsets in one diagram.** **Forbid wide / ambiguous-width
characters** — no `→` (write `->`), no emoji, no CJK; they render at unpredictable
widths per terminal and destroy alignment.

## Worked example — box-and-arrow pipeline

Longest label is `Filter` (6). Cell width = 6 + 2 = **8**. Each box top/bottom
border is `+--------+` (1 `+` + 8 `-` + 1 `+`). Labels padded to 8: `Source`,
`Filter`, `Sink`.

```text
+--------+      +--------+      +--------+
| Source | ---> | Filter | ---> |  Sink  |
+--------+      +--------+      +--------+
```

The three top borders, label rows, and bottom borders are
character-for-character identical, and the `--->` connectors are ASCII only.

## Worked example — tree

A tree needs no box widths — only that each `|` sits in a fixed column and each
branch uses `+--` (a `+` then two `-`) to reach its child:

```text
auth
+-- handlers
|   +-- login
|   +-- logout
+-- store
    +-- session
```

The `|` continuation under `handlers` sits in the same column as the `+` of
`+-- handlers`; the last child of each level uses spaces (not `|`) before its
`+--` so no dangling vertical edge is left.

## Verify (Phase 1) — self-check, then human

There is no renderer to catch you in Phase 1. Run this self-check on every durable
diagram:

- [ ] **Per-box width** — each box's top border, label row, and bottom border have
      the **same character count**. Count them.
- [ ] **Vertical-edge columns** — scan each column that holds a `|` or `+`
      top-to-bottom; every character in that column must be `|` or `+`, never a
      stray space or letter.
- [ ] **Connectors land** — trace each `->`, `--->`, or `+--` unbroken from its
      source to a box edge or child; no connector points into empty space.
- [ ] **Charset** — only `+ - |` (Phase 1); no Unicode box-drawing, no `→`, no
      emoji/CJK; charsets not mixed.

**On any failure: recompute the widths and regenerate the whole diagram. Never
hand-patch a single character** — a hand-patched glyph hides the miscount instead
of fixing it.

**Human reviews load-bearing diagrams** — anything a reader will rely on to
understand the system. You cannot fully trust your own column count; have a human
confirm the alignment on the diagrams that matter.

(Phase 2 `diagctl ascii` renders deterministically and `diagctl check` validates
width-aware — story #14. Until then this checklist plus human review is the gate.)
