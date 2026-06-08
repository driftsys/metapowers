---
schema: 1
name: tech-diagramming
description: Use when creating or reviewing any technical diagram — selects the right tool (ASCII/PlantUML/D2/draw.io) by journey and complexity, sets the source+SVG storage convention and house style, and dispatches to the per-format skill.
license: MIT
metadata:
  version: 0.2.1
---

## Overview

This is the **entry point and decision layer** for every technical diagram. It
owns four cross-cutting decisions — **which tool**, **how to store it**, **how it
should look**, **how to verify it** — then **dispatches** to a per-format skill
for the syntax. It does not teach PlantUML, D2, or draw.io syntax.

**Core principle: _render, don't draw._** Author diagrams as diffable text,
render to the target medium, never hand-place glyphs or pixels. The one exception
is throwaway scratch ASCII.

Activate when you are about to create, edit, or review a diagram — in a README,
in code comments, in design docs, in a PR. First ensure the renderer is present
(§6 Install — a prerequisite, not a phase: it degrades gracefully and never
blocks). Then run the phases in order:
**select → store → style → verify → dispatch** (§§1–5).

## 1. Tool selection — by diagram kind × complexity

The organizing axis is **how good a tool is at a _kind_ of diagram, at a given
_complexity_.** Within any auto-layout kind: **decompose first, escalate second.**
Measure **edge crossings, not box count.**

### Critical user journeys → tool

| #      | Journey                                                                       | Durability               | Who edits next                              | → Tool                                                                |
| ------ | ----------------------------------------------------------------------------- | ------------------------ | ------------------------------------------- | --------------------------------------------------------------------- |
| **J1** | **Scratch sketch** (thinking out loud, `.scratch/`)                           | throwaway                | nobody                                      | **ASCII** freehand — _no tooling_                                     |
| **J2** | **Durable inline** (README, in-code, console/CLI help, maintainer docs)       | durable                  | reader · text                               | **ASCII** — _must be perfect_ (grid-code + validate)                  |
| **J3** | Document an **interaction** (one scenario's message flow)                     | durable                  | agent/eng · text                            | **PlantUML** sequence                                                 |
| **J4** | Document a **lifecycle** (states + transitions)                               | durable                  | agent/eng · text                            | **PlantUML** state                                                    |
| **J5** | Document a **workflow / structural UML** (activity, class, object, component) | durable                  | agent/eng · text                            | **PlantUML** (while autolayout holds)                                 |
| **J6** | **Map the system** (architecture / service / infra, with containers)          | durable, often-revisited | agent/eng · text                            | **D2**                                                                |
| **J7** | **Model the data** (ER / schema)                                              | durable                  | agent/eng · text                            | **D2** (`sql_table`)                                                  |
| **J8** | **Fancy / complex / presentation** (hand-tuned, or beyond any autolayout)     | durable, polished        | agent **hand-authors** → **human polishes** | **draw.io** (icon-rich / pixel-tuned); graph-shaped & unattended → D2 |

**draw.io produces no auto-layout.** Its CLI export just renders whatever
coordinates the source carries — so draw.io is the right pick when the layout is
supplied by hand, for the niche it owns (icon-rich, hand-tuned, presentation):

- **agent hand-authors** the coordinates (tiers / grids), resolving vendor icons (the
  `mxgraph.*` style strings), then flags "NEEDS HUMAN POLISH"; and/or
- **a human** lays out / polishes in `app.diagrams.net` (zero install).

**Graph-shaped and unattended (no human) → prefer D2**, not draw.io: D2's always-on
ELK auto-lays-out graph work, and that is the larger, cheaper-to-maintain default.
Reach for draw.io when the diagram is icon-rich / pixel-tuned / presentation-grade:

- **Architecture / structural (graph-shaped)** → **D2** (always-on bundled ELK).
- **Behavioural (sequence / state / activity)** → **stay in PlantUML and
  decompose**, or hand to a human — **not** D2 (D2 is weak at behavioural layout).
- **Freeform / non-graph illustration** → emit a source stub and **flag for a
  human**; route to the forthcoming `tech-diagramming-svg` skill (issue #24) —
  **never** D2 (ELK lays out graphs, not free-floating art).

Never emit an unlaid-out `.drawio`.

Cross-cutting: **Maintain** (re-edit → re-render, keep synced) favours
agent-authorable text (PlantUML/D2); draw.io needs a human. **Review** → the pair
(clean SVG visual + source intent diff).

### The complexity escalator

```text
behavioural/structural UML:   PlantUML ──autolayout breaks──▶ decompose ──still hard──▶ draw.io
architecture / system:        D2 ──────────too dense/needs hand-tuning───────────────▶ draw.io
```

PlantUML and D2 are auto-layout (agent-authorable, text). draw.io is the top
rung — manual, powerful, **costly to edit → reserve for fancy/complex/presentation
work or what no autolayout can render.** Behavioural diagrams
(sequence/state/activity) **decompose and stay in PlantUML**; if a decomposed
piece is still irreducible it escalates to **draw.io** (hand-authored or
human-polished) — **never to D2**, which is weak at behavioural layout. **Structural**
diagrams (class/component) escalate to **D2** before draw.io.

draw.io has no auto-layout — its layout is supplied by hand (the agent computes
coordinates, and/or a human polishes in `app.diagrams.net`). So when the work is
**graph-shaped and unattended**, prefer **D2** (always-on bundled ELK) rather than
forcing draw.io; behavioural work stays in PlantUML and decomposes (or a human takes
over); freeform/non-graph work goes to a human or the forthcoming
`tech-diagramming-svg` skill (#24). Reach for draw.io when the deliverable must be an editable `.drawio` for a human,
or needs pixel-tuned / presentation polish — an unattended icon-rich _architecture_
is still graph-shaped, so it routes to **D2** (which auto-lays-out and can carry
vendor icons).

### When to escalate — measure crossings, not boxes

The trigger is **edge crossings, not element count** (Purchase et al.'s
graph-drawing readability studies found crossings to be the dominant readability
predictor — a 30-node tree with zero crossings reads fine; a 12-node graph with
40 crossings does not). **Decompose first, switch second.**

**Two-layer rule:**

1. **Objective trigger (mechanical):** render → if edge crossings appear, or any
   node/label overlap, or the SVG exceeds its `viewBox` budget → the diagram has
   left its tool's comfort zone. This is the real "looks bad" detector.
2. **Per-type early-warning (pre-render heuristic):** the numbers below are
   practitioner defaults, **not measured cut-points** — treat as early warnings,
   not laws.

| UML type               | Real trigger (measure)                     | Heuristic early-warning             | First action → escalate to                                                                      |
| ---------------------- | ------------------------------------------ | ----------------------------------- | ----------------------------------------------------------------------------------------------- |
| **Sequence**           | messages crossing many lifelines           | ≥ ~8 participants / ~25+ messages   | **decompose by scenario** (`ref`) → _stay PlantUML_ (D2 weaker)                                 |
| **State**              | non-local transition crossings             | ~12 states / dense transitions      | decompose into sub-machines → **draw.io** if irreducible (hand-authored or human; **not** D2)   |
| **Activity**           | cross-swimlane handoffs                    | ≥ 5 swimlanes                       | decompose into sub-activities → **draw.io** if irreducible (hand-authored or human; **not** D2) |
| **Class**              | **relationship density — NOT class count** | dense association web               | decompose by package → **D2** (containers) → draw.io                                            |
| **Component / object** | connector crossings + nesting depth        | ~10–12 elements / > 1 nesting level | decompose ("split it") → **D2** → draw.io                                                       |

### Fallback when the renderer won't install

**The source is the human-editable deliverable; the render is derived and
deferrable. Never block on a renderer — emit the source, defer the render.** A
cross-tool swap is allowed _only_ when the diagram type also fits the substitute.

| Chosen tool            | Fallback chain                                                                                                                                        |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ASCII**              | grid-code (AI computes positions) → renders/validates — no external renderer, zero install                                                            |
| **PlantUML** (no Java) | ① server render _if online & non-sensitive_ (privacy caveat) → ② Docker → ③ **commit `.puml`, render in CI.** Never silently swap to D2.              |
| **D2**                 | ① `install.sh` user-space (no sudo) → ② PlantUML _only if the type also fits_ (arch, not sequence) → ③ **commit `.d2`, render in CI**                 |
| **draw.io**            | ① **commit `.drawio`; human edits/renders in the free web app `app.diagrams.net` — zero install** → ② Docker headless → ③ commit source, render in CI |

## 2. Storage convention — source + clean SVG (pair)

**Default = the pair:** plain-text source (the diffable intent reviewers read) +
a **clean rendered SVG** (no embedded source). The render is **derived — never
hand-edit it.**

| Tool     | Source (SoT, edit this)         | Committed render  | Embedded opt-in      |
| -------- | ------------------------------- | ----------------- | -------------------- |
| PlantUML | `foo.puml`                      | `foo.svg` (clean) | `foo.puml.svg`       |
| D2       | `foo.d2`                        | `foo.svg` (clean) | — (D2 doesn't embed) |
| draw.io  | `foo.drawio` (uncompressed XML) | `foo.svg` (clean) | `foo.drawio.svg`     |

- **Render is always `foo.svg`** — the renderer's native output, no rename. The
  source file's extension carries provenance.
- **Pair is the default** because it gives readable intent diffs + reliable
  GitHub visual diff + no draw.io metadata churn. The git-bloat argument was
  tested and is negligible.
- **Embedded single-file** (`foo.puml.svg` / `foo.drawio.svg`) is an **opt-in**
  for shipping a standalone editable file _outside_ git — not the in-repo default.
- **Phase 1 pipeline:** `render (clean) → commit` the raw renderer SVG (no
  optimize pass; svgo deferred to Phase 2 `diagctl`).

### Review-ability in PR / MR (GitHub + GitLab)

- The **source diff** (`.puml`/`.d2`/`.drawio`) is plain text — reviewers read
  _intent_.
- The **clean SVG** stays small, so GitHub serves its full rich image diff (2-up
  / swipe / onion-skin) without the "Load diff" size-limit stub that the
  _embedded_ variants trigger. This is the concrete payoff of going clean.
- **GitLab** gives a render/source toggle for committed SVGs (view the rendered
  image or the raw XML). Its swipe/onion-skin image-diff modes are raster-only;
  rich visual diff for SVG is unconfirmed — so on GitLab lean on the **source
  diff** for review, with the rendered SVG as the visual cross-check.
- **No rasters in git.** Never commit `.png`/`.webp`: they cost N× binary blobs
  in history, WebP gets no rich PR diff, and **LFS free tiers are a trap** (the
  bandwidth/storage caps silently break images when hit). If an external consumer
  needs a raster, produce it as a **CI artifact / Pages output**, never a commit.

## 3. House style — defer to markspec typography

**Reference, do not reinvent:** <https://driftsys.github.io/markspec/typography/#diagrams>.
Operationalised as agent-checkable rules:

- `viewBox` set; omit fixed `width`/`height` (`skinparam svgDimensionStyle false`
  for PlantUML);
- monochrome / greyscale-readable first — **colour is decorative, not
  structural**;
- **legend required** when colour or shape encodes meaning;
- IBM Plex Sans fallback chain
  (`"IBM Plex Sans","Segoe UI","Helvetica Neue","DejaVu Sans",sans-serif`);
- ≥ 12px labels, ≥ 14px titles;
- 1.5–2px primary strokes, 1px secondary, no hairlines;
- caption below the figure (`_Figure: …_`).

**Failure-mode fixes (the recurring sins):**

- **Label every arrow** — no bare connectors.
- **Single flow direction** — never mix (no left-to-right and top-to-bottom in
  one diagram).
- **One question per diagram** — if it answers two, split it.
- **No conflated types** — no sequence steps inside a state machine.
- **7 ± 2 elements per zoom level** — beyond that, decompose into sub-views.

## 4. Verify (Phase 1) — a three-layer checklist + human-in-the-loop

Phase 1 has **no gate tooling** (no `diagctl`, svgo, svglint). The gate is a
**checklist the agent applies**, plus **human review for load-bearing diagrams**
(anything the agent cannot self-verify). Phase 2 (`diagctl`, story #14) will make
Layers 0–1 deterministic — but nothing here depends on it.

**Layer 0 — Compile (does it render at all?)**

- Run the render step; it fails loudly if the source is invalid. If you cannot
  render (no tool), commit the source and defer — do not claim success.

**Layer 1 — Conformance + structure (did it draw the _right_ graph, in house
style?)** Checklist:

- [ ] **every house-style rule from §3 holds** — the typography settings
      (`viewBox` set / no fixed `width`/`height`, monochrome-readable + legend
      when colour or shape encodes meaning, IBM Plex Sans chain, ≥ 12px labels /
      ≥ 14px titles, 1.5–2px strokes) **and** the failure-mode fixes (every arrow
      labelled, single flow direction, one question per diagram, no conflated
      types, ≤ 7 ± 2 elements per zoom level).
- [ ] render named `foo.svg`; source extension carries provenance (§2).
- **Human reviews** load-bearing diagrams.

**Layer 2 — Niceness (readable, right type, laid out well?)** — **you cannot
judge a diagram from source alone.** Render to an image and _look_
(Excalidraw-style render-then-review loop). Apply:

- **Isomorphism test:** strip all text — does the structure still communicate?
- **Education test:** does the diagram _argue_ a point, not merely _display_
  boxes?

For load-bearing or polished diagrams, prefer **pairwise comparison vs a known-good
reference** over absolute scoring, and have a human confirm.

## 5. Dispatch

Once the tool is chosen, **follow the per-format skill** for syntax and render
mechanics:

| Tool     | Skill                       | Installer agent (co-located) |
| -------- | --------------------------- | ---------------------------- |
| PlantUML | `tech-diagramming-plantuml` | `tech-diagramming-plantuml`  |
| ASCII    | `tech-diagramming-ascii`    | — (no tool needed)           |
| D2       | `tech-diagramming-d2`       | `tech-diagramming-d2`        |
| draw.io  | `tech-diagramming-drawio`   | `tech-diagramming-drawio`    |

If a per-format skill is **absent**, do not block: apply the storage convention
(§2) and house style (§3) from this skill, and use general knowledge for the
syntax.

## 6. Install & fallback (Phase 1)

A portable skill runs in arbitrary consumer repos. Getting the renderer present
is a **prerequisite, not a phase** — it degrades gracefully and **never blocks**.
Walk this ladder for the selected tool:

1. **Detect.** Check whether the selected tool's renderer is present (ASCII needs
   none — it is always available). If present, proceed to the per-format skill
   (§5). Only continue this ladder when the renderer is missing.
2. **Offer — never auto-install.** Tell the user what would be installed (e.g.
   PlantUML pulls a JRE + Graphviz; D2 is a single static binary; draw.io desktop
   pulls Electron), and ask. Installing tooling into someone's repo is their call,
   not yours.
3. **On accept — dispatch the tool's installer subagent** (kind=agent, same name
   as the format skill): `tech-diagramming-plantuml`, `tech-diagramming-d2`, or
   `tech-diagramming-drawio`. Each one mechanically **detects → installs
   cross-platform → verifies a real render → returns** `STATUS: available |
   unavailable | refused` (it asks nothing — consent already happened in step 2).
   On `available`, proceed to dispatch (§5).
4. **On decline, or the installer returns `unavailable` / `refused`, or the
   tooling is too flaky — fall back, in order:**
   - **ASCII** — the no-tool floor; **always available, never needs install**.
     Use it when the diagram is simple enough to carry in text (dispatch to
     `tech-diagramming-ascii`).
   - **raw SVG** — when ASCII will not carry it, **hand-author a minimal SVG**
     directly: compute the coordinates, set a `viewBox`, emit no fixed
     `width`/`height`. A no-renderer path to a committed _visual_ — lower fidelity,
     but it renders everywhere.
   - **emit the source + defer the render** — commit the `.puml`/`.d2`/`.drawio`
     source and defer rendering to CI or another machine where a renderer will
     exist later. The **source is the deliverable; the render is derived.**
5. **Never block on a renderer.** ASCII, raw SVG, and defer-render always leave a
   path forward.

Constraints the installer subagents enforce on your behalf: **`apt` only with
real root or passwordless sudo** (`id -u` = 0 or `sudo -n true`), never `sudo`
blindly, never mutate global shell config; **WSL2 recommended on Windows** for the
Java/headless renderers. Phase 1 installs **only the renderers** — no
svgo/svglint/xmllint/Deno, because Phase 1 has no gate tooling.
