---
schema: 1
name: tech-diagramming-drawio
description: Use when tech-diagramming has selected draw.io — high-complexity diagrams beyond what PlantUML/D2 autolayout handles after decomposition, hand-tuned or freeform layouts, presentation-grade stakeholder diagrams, and icon-rich cloud architecture (AWS/Azure/GCP/K8s shape libraries). Covers the agent-draft-plus-human-polish model, optional MCP, mxGraphModel XML rules, the source+SVG pair, and the Phase-1 self-check.
license: MIT
metadata:
  version: 0.1.0
---

## Overview

You are here because `tech-diagramming` already selected draw.io. This skill is
the doing layer: when draw.io is the right top rung, how much an agent can
actually draft, the optional MCP accelerator, how to hand-scaffold valid
mxGraphModel XML, the source+SVG pair, the honest house-style gaps, and a
pre-commit self-check. It does NOT redo tool selection — the umbrella owns that.

Core principle: **author diffable mxfile XML, render to a clean SVG, never claim
the draft is finished.** Edit the uncompressed `.drawio`, re-render, commit the
pair — and always flag the draft as needing a human polish pass.

## When draw.io fits (and when it does not)

draw.io is the **top rung** of the complexity escalator. Reach for it when:

- **High complexity** beyond what PlantUML or D2 autolayout renders cleanly
  *after you have already decomposed* — irreducibly dense or non-planar graphs.
- **Hand-tuned / freeform** layouts where exact placement carries meaning.
- **Presentation-grade** diagrams for stakeholders, where polish is the point.
- **Icon-rich cloud** architecture using the AWS / Azure / GCP / Kubernetes
  vendor shape libraries (10k+ shapes draw.io ships).

| Use draw.io for | Do NOT use draw.io for | Go to |
| --- | --- | --- |
| High-complexity / irreducible after decomposition | Sequence (one scenario's message flow) | PlantUML |
| Hand-tuned / freeform / pixel-tuned | State / lifecycle | PlantUML |
| Presentation-grade stakeholder diagrams | Plain auto-layout architecture / system maps | **D2 first** |
| Icon-rich cloud (AWS/Azure/GCP/K8s) | ER / schema | D2 |

For plain auto-layout architecture, **prefer D2 first** — it pays no
manual-editing cost. Only escalate to draw.io when D2's layout has genuinely
collapsed or the diagram needs hand-tuning, vendor icons, or presentation gloss.

## Agent capability — agent drafts, human polishes (load-bearing)

draw.io is **not human-only.** An agent CAN produce a good **80–90% draft** using
an MCP server, ELK auto-layout, and this skill. Real-world evidence corrects two
common misconceptions: that draw.io needs a human from the first stroke (it does
not, for most diagrams), and that an agent draft is a finished diagram (it is
not).

The conditions that make the draft good:

1. **Drive ELK `postLayout` explicitly.** The official MCP defaults to *manual
   coordinates* — you must request ELK auto-layout to get it. An agent that does
   not ask for ELK gets hand-placed boxes, not a laid-out graph.
2. **Label de-overlap, vendor-icon correctness, and final polish typically need
   a human pass**, and that pass scales with complexity. The agent gets the
   structure right; a human resolves overlapping labels, confirms the right
   vendor icon, and tunes the final layout.
3. **Only freeform / pixel-tuned / artistic diagrams need a human throughout.**
   Everything else is agent-draft-then-human-polish.

So the rule is: **agent drafts, human polishes.** Always flag the draft as
needing review. **Never claim a draft is finished.** The Phase-1 self-check below
requires an explicit "NEEDS HUMAN POLISH" handoff note on every draft.

## MCP — a recommended accelerator, not required

An MCP server materially improves agent drafts; draw.io still works without one.
**Recommend it** when draw.io diagrams come up more than occasionally — weighed
against its setup cost (a Node-based MCP server registered in the client, not a
static dependency). To add it, see the installer (`tech-diagramming-drawio`
AGENT — opt-in).

- **`@drawio/mcp`** (official, jgraph; vendor-backed) or **lgazo's** community
  server.
- **What it buys (real, not cosmetic):** `search_shapes` over the 10k+ shape
  libraries (correct vendor icons — AWS/Azure/GCP/K8s — by name), valid
  `mxGraphModel` generation (avoids malformed-XML pitfalls), and ELK `postLayout`
  so the draft is laid out, not hand-placed.
- **What it does NOT buy:** layout *judgment* — even with ELK a human still
  resolves label overlap and final polish. So it is never required.

**Without an MCP** you lose shape search, model generation, and ELK — so you
**cannot** produce a good *unattended* draft. Two honest paths remain:

1. **A human is in the loop** (the real draw.io case): hand-scaffold the mxfile
   XML below as a rough skeleton, then a person lays it out and polishes in
   `app.diagrams.net` (its GUI uses mxGraph layouts — not ELK). This is the
   deliberate no-MCP path.
2. **No human and no MCP:** do not force draw.io. The umbrella selector falls
   back to **D2** (always-on ELK) — see `tech-diagramming` §1.

## mxGraphModel XML — hand-scaffolding rules

When you scaffold without an MCP, follow the official jgraph skill's rules:

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

Adding `-e` / `--embed-diagram` produces `foo.drawio.svg`: a single file that is
both a clean SVG and reopenable in draw.io / the VS Code extension. It is the
**opt-in**, not the default, because it is large and carries version/agent
metadata that churns the diff across edits. Use it only to ship a standalone
editable file *outside* git.

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
