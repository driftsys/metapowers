---
schema: 1
name: tech-diagramming-d2
description: Use when tech-diagramming has selected D2 — architecture, system, and infra diagrams with containers/nesting, plus ER schemas. Covers diagram kinds, the dagre/elk/tala layout engines, render mechanics, the source+SVG pair, and the Phase-1 self-check.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-diagramming` already selected D2. This skill is the
doing layer: which D2 construct fits each diagram kind, which layout engine to
pick, the exact render command, the source+SVG pair, and a pre-commit self-check.
It does NOT redo tool selection — the umbrella owns that.

Core principle: **author diffable text, render to a clean SVG, never hand-place
glyphs.** Edit the `.d2`, re-render, commit the pair.

## When D2 fits (and when it does not)

D2's strength is the middle rung of the complexity escalator: **architecture and
system diagrams with containers** that stay readable where PlantUML's autolayout
has already collapsed — without paying draw.io's manual-editing cost. It also
owns **ER / schema** diagrams via `sql_table`. Its syntax is the cleanest of the
text tools, and it is a single static Go binary — no Java, so it is also the pick
when Java is unavailable.

| Use D2 for                                                | Do NOT use D2 for                         | Go to    |
| --------------------------------------------------------- | ----------------------------------------- | -------- |
| Architecture / system / infra maps with containers        | Sequence (one scenario's message flow)    | PlantUML |
| ER / schema (`sql_table`)                                 | State / lifecycle                         | PlantUML |
| Service / component graphs that outgrew PlantUML's layout | Freeform, hand-tuned, presentation polish | draw.io  |
|                                                           | Anything no autolayout can render cleanly | draw.io  |

D2 is weak at behavioural diagrams (sequence, state) — PlantUML wins those
decisively. If an architecture diagram grows too dense for any layout engine,
escalate to draw.io.

## Diagram kinds — construct + minimal example

Both examples below render with `d2` at exit 0 (verified, D2 0.7.x).

### Architecture / system — containers and nesting

Containers are what system diagrams _are_: a service holds components, a boundary
holds services. Nest with `parent: Label { child: ... }`, reference nested nodes
by dotted path, and label every edge.

```d2
gateway: API Gateway {
  router: Router
  authz: Authorizer
}
services: Services {
  auth: Auth Service
  orders: Order Service
}
db: Postgres {
  shape: cylinder
}

gateway.router -> services.auth: verify token
gateway.router -> services.orders: place order
services.auth -> db: query users
services.orders -> db: write orders
```

### ER / schema — `sql_table`

A `sql_table` shape lists `column: type` rows; `constraint` marks keys. Draw
relationships as edges between dotted column paths.

```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  email: varchar
  org_id: int {constraint: foreign_key}
}
orgs: {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar
}
users.org_id -> orgs.id: belongs to
```

## Layout engines — pick one

D2 ships two engines and supports a third proprietary one. Pick with `--layout`
(or `D2_LAYOUT`):

| Engine    | Availability                      | Use for                                                                                                                       |
| --------- | --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **dagre** | bundled (default)                 | the default; fine for small/simple graphs                                                                                     |
| **elk**   | bundled                           | **recommended for architecture** — better container/hierarchical layout, fewer crossings on nested system diagrams            |
| **tala**  | proprietary, **separate install** | tuned for architecture/whiteboard layouts; not bundled — install separately if you want it. Do not depend on it being present |

```bash
d2 --layout elk foo.d2 foo.svg     # recommended for container-heavy architecture
```

`d2 layout` lists the engines actually installed in your environment.

## Render + storage

### Render the clean pair

```bash
d2 --layout elk --omit-version foo.d2 foo.svg    # → foo.svg (D2's native output)
```

D2's default output is `foo.svg` if you pass a `.svg` path — do not rename it.
`--omit-version` drops the `data-d2-version="…"` attribute from the root `<svg>`,
which otherwise churns the SVG spuriously across D2 versions (the analogue of
PlantUML's `-nometadata`). Use it so the render diffs cleanly.

### What D2's SVG looks like (verified, D2 0.7.x)

These are measured facts on the rendered output, not assumptions:

- **viewBox: yes.** The **root** `<svg>` carries `viewBox="0 0 W H"` and
  `preserveAspectRatio="xMinYMin meet"` but **no `width`/`height`** — so it
  **scales** to its container. This is the element that governs how the SVG
  renders when embedded, so the house "scalable viewBox, no fixed dimensions"
  rule is satisfied at the level that matters, with no extra flag.
- **Caveat — a nested inner `<svg>` does carry fixed `width`/`height`.** D2 wraps
  its content in an inner `<svg class="d2-svg" width="W" height="H" viewBox=…>`.
  Those fixed dimensions are on the inner content layer, not the root, so they do
  not stop the diagram from scaling — but it is **not** literally true that the
  file contains zero `width`/`height` attributes. State it that way honestly: the
  scaling root is clean; an inner fixed-size layer exists.

### Known house-style gap — fonts

D2 **embeds its default font (Source Sans Pro) as base64 WOFF** in the SVG; it
does **not** emit the IBM Plex Sans fallback chain the house style names. This is
an honest gap, not conformance.

You can swap the embedded font to IBM Plex Sans **if you supply the `.ttf` files**:

```bash
d2 --layout elk --omit-version \
  --font-regular IBMPlexSans-Regular.ttf \
  --font-bold IBMPlexSans-SemiBold.ttf \
  --font-italic IBMPlexSans-Italic.ttf \
  foo.d2 foo.svg
```

Only the **regular / bold / italic** faces are swapped this way; the **mono and
semibold** faces stay D2 defaults unless you also pass `--font-semibold` and
`--font-mono*`.

Without those `.ttf` files, D2 ships Source Sans Pro embedded — so unless you pass
the fonts, treat the IBM Plex Sans requirement as **not met** and say so in
review rather than claiming conformance. (Phase 2 `diagctl check` — story #14 —
will make the font check deterministic.)

For monochrome-first output, render with a greyscale theme:
`--theme 1` (Neutral Grey) or `--theme 301` (Terminal Grayscale). Reserve colour
for distinct categories and add a legend when it encodes meaning.

### Commit the pair

Commit **both** `foo.d2` (the source of truth — edit this) and `foo.svg` (the
derived render — never hand-edit it). The render is regenerable; if you edit the
source, re-render before committing so the pair stays in sync (freshness).

### No embedded single-file

**D2 does NOT embed its source in the SVG** — there is no embedded single-file
opt-in (unlike PlantUML's `foo.puml.svg` or draw.io's `foo.drawio.svg`). D2 is
**always the two-file pair**: `foo.d2` + `foo.svg`. The `.d2` source is the only
editable artifact, so never delete it.

## Self-check before committing (Phase 1)

Run this checklist by hand before committing. (Phase 2's `diagctl check` — story
#14 — will automate the conformance parts; until then it is a manual gate.)

- [ ] **Renders cleanly** — `d2 --layout elk --omit-version foo.d2 foo.svg`
      exits 0 with no errors.
- [ ] **Pair committed** — both `foo.d2` and `foo.svg` are staged.
- [ ] **Scaling root is clean** — root `<svg>` has `viewBox` and no
      `width=`/`height=` (the nested inner `<svg>`'s fixed dims are expected).
- [ ] **Font honestly scoped** — either IBM Plex Sans `.ttf` files were passed via
      `--font-*`, OR the SVG ships D2's default font and you have flagged the font
      gap in review. Do not claim IBM Plex Sans conformance you did not produce.
- [ ] **Every edge labelled** — no bare connector; each `->` carries a verb or
      relationship label.
- [ ] **Single intent** — one question per diagram (one system view, one schema);
      if it answers two, split it.
- [ ] **Containers used for grouping** — services/components/boundaries are nested,
      not a flat soup of boxes.
