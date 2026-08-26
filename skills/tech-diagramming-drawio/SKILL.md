---
schema: 1
name: tech-diagramming-drawio
description: Use when tech-diagramming has selected draw.io — high-complexity diagrams beyond what PlantUML/D2 autolayout handles after decomposition, hand-tuned or freeform layouts, presentation-grade stakeholder diagrams, and icon-rich cloud architecture (AWS/Azure/GCP/K8s shape libraries). Covers the agent-draft-plus-human-polish model, vendor-icon `mxgraph.*` styles, mxGraphModel XML rules, the source+SVG pair, and the Phase-1 self-check.
license: MIT
metadata:
  version: 0.2.3
---

## Overview

You are here because `tech-diagramming` already selected draw.io. This skill is
the doing layer: when draw.io is the right top rung, how much an agent can
actually draft (no MCP needed), how to hand-scaffold valid mxGraphModel XML, the
source+SVG pair, the honest house-style gaps, and a pre-commit self-check. It does
NOT redo tool selection — the umbrella owns that.

Core principle: **author diffable mxfile XML, render to a clean SVG, never claim
the draft is finished.** Edit the uncompressed `.drawio`, re-render, commit the
pair — and always flag the draft as needing a human polish pass.

## When draw.io fits (and when it does not)

draw.io is the **top rung** of the complexity escalator. Reach for it when:

- **High complexity** beyond what PlantUML or D2 autolayout renders cleanly
  _after you have already decomposed_ — irreducibly dense or non-planar graphs.
- **Hand-tuned / freeform** layouts where exact placement carries meaning.
- **Presentation-grade** diagrams for stakeholders, where polish is the point.
- **Icon-rich cloud** architecture using the AWS / Azure / GCP / Kubernetes
  vendor shape libraries (10k+ shapes draw.io ships).

| Use draw.io for                                   | Do NOT use draw.io for                       | Go to        |
| ------------------------------------------------- | -------------------------------------------- | ------------ |
| High-complexity / irreducible after decomposition | Sequence (one scenario's message flow)       | PlantUML     |
| Hand-tuned / freeform / pixel-tuned               | State / lifecycle                            | PlantUML     |
| Presentation-grade stakeholder diagrams           | Plain auto-layout architecture / system maps | **D2 first** |
| Icon-rich cloud (AWS/Azure/GCP/K8s)               | ER / schema                                  | D2           |

For plain auto-layout architecture, **prefer D2 first** — it pays no
manual-editing cost. Only escalate to draw.io when D2's layout has genuinely
collapsed or the diagram needs hand-tuning, vendor icons, or presentation gloss.

## Agent capability — agent drafts, human polishes (load-bearing)

draw.io is **not human-only, and not MCP-gated.** An agent CAN author a good draft
**with no MCP at all** — hand-author the mxGraphModel XML below, resolve vendor icons
(emit the `mxgraph.*` style strings; verify uncertain ones in `app.diagrams.net`), and
render the pair. (Demonstrated: a clean multi-tier AWS diagram with real
`mxgraph.aws4.*` icons, hand-placed.) Two honest limits remain:

1. **Layout at high crossing-density.** Hand-placing coordinates works well for
   tiered / grouped diagrams; it degrades as edge crossings grow. A real layout engine
   beats hand-placement there — which is why **D2 owns auto-layout graph-shaped work**
   and draw.io is reserved for the hand-tuned / icon-rich / presentation niche (see the
   umbrella's escalator).
2. **Final polish needs a human.** Label de-overlap, vendor-icon confirmation, and
   pixel-tuning typically need a human pass that scales with complexity.

So the rule is: **agent drafts, human polishes.** Always flag the draft as needing
review. **Never claim a draft is finished.** The Phase-1 self-check below requires an
explicit "NEEDS HUMAN POLISH" handoff note on every draft.

## Vendor icons

draw.io ships 10k+ vendor shapes (AWS / Azure / GCP / Kubernetes / Cisco / …).
Capable models already know the `mxgraph.*` style strings — emit them directly. The
common case is the AWS-4 resource icon:

```text
shape=mxgraph.aws4.resourceIcon;resIcon=mxgraph.aws4.<service>;
```

Other vendors use `shape=mxgraph.<lib>.<name>` — e.g. `mxgraph.gcp2.compute_engine_2`,
`mxgraph.azure.azure_active_directory`, `mxgraph.alibaba_cloud.actiontrail`. These
tokens are library-specific; if you are unsure of an exact one, do **not** guess
silently — emit your best string and call it out in the NEEDS HUMAN POLISH note for
verification in `app.diagrams.net` (search the shape panel; the style inspector shows
the exact token).

## Layout — no MCP, two honest paths

There is **no MCP** in this skill: every draw.io MCP server was verified unable to
deliver headless vendor-icon layout-to-file, and an agent does not need one. Lay out one
of two ways:

1. **Agent hand-authors** the mxGraphModel XML below with computed coordinates (tiers /
   grids / columns), using vendor `mxgraph.*` styles for icons — then flag "NEEDS HUMAN POLISH".
   Good for icon-rich and moderately-structured diagrams.
2. **Human in the loop:** emit a rough-coordinate skeleton and a person lays it out and
   polishes in `app.diagrams.net` (zero install). The deliberate path for freeform /
   pixel-tuned / presentation-grade work.

If the diagram is graph-shaped and wants automatic layout with no human, that is **D2's**
job, not draw.io's — the umbrella routes there first (`tech-diagramming` §1).

## mxGraphModel XML — hand-scaffolding rules

When hand-scaffolding the mxfile XML, follow these rules:

- Root is `<mxGraphModel adaptiveColors="auto">` wrapping a `<root>`.
- `<root>` must contain `mxCell id="0"` (the model root) and
  `mxCell id="1" parent="0"` (the default layer); every shape and edge parents to
  layer `1`.
- **No XML comments** anywhere in the model.
- **Escape XML entities** in values and labels: `&amp;` `&lt;` `&gt;` `&quot;`.
- **Unique cell ids** — every `mxCell` needs a distinct `id`.

A minimal valid mxfile (store this uncompressed — see Render + storage):

```xml
<mxfile>
  <diagram name="Page-1">
    <mxGraphModel adaptiveColors="auto" pageWidth="850" pageHeight="1100">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="api" value="API Gateway" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
          <mxGeometry x="40" y="40" width="160" height="60" as="geometry" />
        </mxCell>
        <mxCell id="svc" value="Auth Service" style="rounded=0;whiteSpace=wrap;html=1;" vertex="1" parent="1">
          <mxGeometry x="40" y="160" width="160" height="60" as="geometry" />
        </mxCell>
        <mxCell id="e1" value="verify token" style="endArrow=block;html=1;" edge="1" parent="1" source="api" target="svc">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

## Render + storage — the pair

### Store the source uncompressed

Store `foo.drawio` as **uncompressed** mxfile XML so the source is text-diffable.
draw.io defaults to compressing the diagram, which produces an opaque blob. To
disable it: in the app, **Extras → Edit Diagram** (paste plain XML) or untick
**"Compressed"** in the file settings. A compressed `.drawio` defeats the entire
point of committing the source.

### Render the clean SVG

```bash
drawio -x -f svg -b 10 -o foo.svg foo.drawio    # → foo.svg, clean (no embedded source)
```

Use `-b 10` for a 10px border. Do **not** pass `-e` — that embeds the source (see
the opt-in below). On headless Linux there is no display, so wrap the command:

```bash
xvfb-run -a drawio -x -f svg -b 10 -o foo.svg foo.drawio
```

### Embedded single-file — opt-in only

Adding `-e` / `--embed-diagram` embeds the source back into the SVG. The CLI
writes whatever `-o` names — it does **not** auto-derive the `.drawio.svg` double
extension — so name the output yourself:

```bash
drawio -x -f svg -e -b 10 -o foo.drawio.svg foo.drawio
```

The result is both a clean SVG and reopenable in draw.io / the VS Code extension.
It is the **opt-in**, not the default, because it is large and carries
version/agent metadata that churns the diff across edits. Use it only to ship a
standalone editable file _outside_ git.

### Commit the pair

Commit **both** the uncompressed `foo.drawio` (the source of truth — edit this)
and the clean `foo.svg` (the derived render — never hand-edit it). The render is
regenerable; re-render before committing so the pair stays in sync.

## House style — honest gaps (manual conformance)

draw.io has **no skinparam preset mechanism** the way PlantUML does. There is no
include-one-file conformance switch. Apply the house style **manually**, and be
honest in review about what is and is not conformant:

- **Monochrome / greyscale-readable** strokes; reserve colour for distinct
  categories.
- **Legend** whenever colour or shape encodes meaning.
- **IBM Plex Sans** where the font is settable (per-shape font, or document
  default) — not all shapes honour it.
- **Fixed shape sizes** for visual consistency across the diagram.
- **Lane structure** (swimlanes / containers) for grouping.

Because there is no preset, **draw.io conformance is manual and not guaranteed.**
Flag explicitly in review which house-style rules you could not auto-conform.
After exporting, **verify the SVG has a `viewBox`** (draw.io's `-x` export emits
one) so the diagram scales when embedded.

## Self-check before committing (Phase 1)

Run this checklist by hand before committing. (Phase 2's `diagctl` — story #14 —
will automate the conformance parts; until then it is a manual gate.)

- [ ] **Exports cleanly** — `drawio -x -f svg -b 10 -o foo.svg foo.drawio`
      (with `xvfb-run -a` on headless Linux) exits 0 with no errors.
- [ ] **Pair committed** — both the **uncompressed** `foo.drawio` and the clean
      `foo.svg` are staged. (Confirm the `.drawio` is readable XML, not a
      compressed blob.)
- [ ] **"NEEDS HUMAN POLISH" handoff note present** — every agent draft carries
      an explicit note listing what a human must still do: **label de-overlap,
      vendor-icon correctness, final layout**. Never claim the draft is finished.
- [ ] **viewBox present** — the exported `<svg>` carries a `viewBox` so it scales.
- [ ] **Single intent** — one question per diagram; if it answers two, split it.
- [ ] **House-style gaps flagged** — say which manual house-style rules are not
      auto-conformant rather than claiming conformance you did not verify.
