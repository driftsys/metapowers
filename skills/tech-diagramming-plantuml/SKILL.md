---
schema: 1
name: tech-diagramming-plantuml
description: Use when tech-diagramming has selected PlantUML — sequence, state, activity, and low-complexity class/object/component diagrams. Covers render mechanics, the source+SVG pair, per-type complexity thresholds, and the house presets.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-diagramming` already selected PlantUML. This skill is
the doing layer: which construct fits each diagram type, the per-type complexity
ceiling, the exact render command, the source+SVG pair, and a pre-commit
self-check. It does NOT redo tool selection — the umbrella owns that.

Core principle: **author diffable text, render to a clean SVG, never hand-place
glyphs.** Edit the `.puml`, re-render, commit the pair.

## When PlantUML fits (and when it does not)

PlantUML is **brilliant at sequence** and good at **state, activity, class,
object, and component** UML — while its autolayout holds. It delegates layout to
Graphviz, so it degrades on dense or non-planar graphs (overlapping edges, hidden
relations).

| Use PlantUML for | Do NOT use PlantUML for | Go to |
| --- | --- | --- |
| Sequence (one scenario's message flow) | Architecture / system / infra maps with containers | D2 |
| State / lifecycle | ER / schema | D2 |
| Activity / workflow | Freeform, hand-tuned, presentation polish | draw.io |
| Low-complexity class / object / component | Anything no autolayout can render cleanly | draw.io |

If the diagram is structural and outgrows PlantUML's layout, escalate to D2
before draw.io. If it is behavioural, **decompose and stay in PlantUML** (D2 is
weak at sequence/state).

## Diagram types — construct + minimal example

Each example assumes a preset is applied (see Render + storage). Replace the
`!include` path with the path to your installed preset.

### Sequence — one scenario per diagram

Name participants by role, not class name. Use `->` for a call, `-->>` for a
return/reply. One scenario per diagram; a second scenario is a second
diagram.

```plantuml
@startuml
!include presets/monochrome.puml
actor User
participant "Auth Service" as Auth
participant "Token Store" as Store
User -> Auth : login(credentials)
Auth -> Store : fetch(userId)
Store -->> Auth : record
Auth -->> User : session token
@enduml
```

### State — every state a noun, every transition an event

State names are nouns; transition labels are verbs or events. Include the initial
state `[*]`, a terminal `[*]`, and the cancel/error paths — not just the happy
path.

```plantuml
@startuml
!include presets/monochrome.puml
[*] --> Draft
Draft --> Review : submit
Review --> Published : approve
Review --> Draft : request changes
Published --> Archived : retire
Review --> [*] : cancel
@enduml
```

### Activity — one flow, decisions labelled

Label every branch on the decision (`yes`/`no`, or the guard). Keep to a single
flow with explicit `start`/`stop`.

```plantuml
@startuml
!include presets/monochrome.puml
start
:Receive order;
if (in stock?) then (yes)
  :Charge payment;
  :Ship order;
else (no)
  :Backorder;
endif
stop
@enduml
```

### Class / object — relationships labelled, low density only

Label every relationship. Keep the association web sparse — class diagrams break
on relationship density, not class count (see thresholds).

```plantuml
@startuml
!include presets/monochrome.puml
class Order {
  +id: UUID
  +total(): Money
}
class LineItem {
  +quantity: int
}
Order "1" *-- "many" LineItem : contains
@enduml
```

### Component — low nesting only

Label every connector. Keep nesting to one level; deeper structure is D2's job.

```plantuml
@startuml
!include presets/monochrome.puml
component "API Gateway" as GW
component "Auth Service" as Auth
database "User DB" as DB
GW --> Auth : verify(token)
Auth --> DB : query(userId)
@enduml
```

## Complexity thresholds & escalation

The real trigger is **edge crossings, not box count.** Render first: if edges
cross, nodes or labels overlap, or the SVG exceeds its `viewBox` budget, the
diagram has left PlantUML's comfort zone. The per-type numbers below are
practitioner early-warnings, not measured cut-points — treat them as defaults
that prompt a render check, not laws.

| Type | Objective trigger | Early-warning heuristic | First action → escalate to |
| --- | --- | --- | --- |
| Sequence | messages crossing many lifelines | ~8 participants or ~25+ messages | decompose by scenario (`ref`) → stay PlantUML |
| State | non-local transition crossings | ~12 states or dense transitions | decompose into sub-machines → draw.io if irreducible |
| Activity | cross-swimlane handoffs | 5 or more swimlanes | decompose into sub-activities → draw.io if irreducible |
| Class | relationship density, NOT class count | a dense association web | decompose by package → D2 → draw.io |
| Component / object | connector crossings + nesting depth | ~10–12 elements or more than 1 nesting level | decompose ("split it") → D2 → draw.io |

The rule in one line: **decompose first.** Behavioural diagrams
(sequence/state/activity) decompose and stay in PlantUML. Structural diagrams
(class/component/object) escalate to D2, then draw.io if still irreducible.

## Render + storage

### Render the clean pair

```bash
plantuml -tsvg -nometadata foo.puml    # → foo.svg (native name, no rename)
```

`-nometadata` strips the `<!--SRC=...-->` comment, so the SVG is pure render: it
diffs cleanly and gets GitHub's visual diff. The output file is `foo.svg` — do
not rename it.

### Apply a preset

Pick from `presets/`: **`monochrome.puml`** is the default; use
**`categorical.puml`** only when colour encodes distinct categories (and then add
a legend). Apply it by `!include` at the top of the diagram:

```plantuml
@startuml
!include presets/monochrome.puml
' ... your diagram ...
@enduml
```

PlantUML strips the included file's own `@startuml`/`@enduml` wrapper, so the
include composes correctly. The presets set `skinparam svgDimensionStyle false`,
which makes the SVG scale by `viewBox` with no fixed `width`/`height`.

**Path resolution (do this once per repo):** PlantUML resolves `!include`
relative to the **diagram file's own directory**, not this skill. Copy the chosen
preset into your repo — e.g. `docs/diagrams/presets/monochrome.puml` — and write
the `!include` as a path that resolves from where your `.puml` lives (a sibling
`presets/` dir → `!include presets/monochrome.puml`). Commit the preset with the
pair (see the `!include` caveat). If you cannot use `!include` at all, prepend
the preset's `skinparam` lines into the diagram instead.

### Commit the pair

Commit **both** `foo.puml` (the source of truth — edit this) and `foo.svg` (the
derived render — never hand-edit it). The render is regenerable; if you edit the
source, re-render before committing so the pair stays in sync.

### `!include` caveat

If `foo.puml` includes shared files (a preset, shared definitions), commit those
too — the render depends on them.

### Embedded single-file (opt-in only)

For the embedded opt-in, render **without** `-nometadata`: PlantUML embeds the
source as a one-line `<!--SRC=[...]-->` comment. This still outputs `foo.svg`
(the basename of the input) — the metadata flag changes the SVG's *contents*,
not its filename. **Rename it to `foo.puml.svg`** to mark it as the standalone
editable variant, distinct from the clean pair's `foo.svg`. Recover the source
with `plantuml -decodeurl '<token>'`, where `<token>` is the encoded string from
the `SRC=[...]` comment inside the embedded SVG. Use this **only** to ship a
self-contained editable file _outside_ git. Inside git, prefer the pair for the
readable `.puml` diff.

## Self-check before committing (Phase 1)

Run this checklist by hand before committing. (Phase 2's `diagctl check` — story
#14 — will automate it; until then it is a manual gate.)

- [ ] **Renders cleanly** — `plantuml -tsvg -nometadata foo.puml` exits 0 with no
      errors.
- [ ] **viewBox present, no fixed dimensions** — the root `<svg>` has a `viewBox`
      and no `width=` / `height=` attribute.
- [ ] **Every arrow labelled** — no bare connector; each carries a message, event,
      guard, or relationship label.
- [ ] **Single flow** — one direction, not mixed top-down and left-right.
- [ ] **One question per diagram** — one scenario for a sequence, one machine for
      a state diagram, one workflow for an activity.
- [ ] **Preset applied** — `monochrome.puml` by default, `categorical.puml` with a
      legend when colour encodes categories.
- [ ] **Pair committed** — both `foo.puml` and `foo.svg` (plus any `!include`d
      files) are staged.
