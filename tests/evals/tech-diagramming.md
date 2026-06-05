# tech-diagramming evals

RED → GREEN behavioural checks for the umbrella + all four format skills
(ASCII / PlantUML / D2 / draw.io).

**Harness.** The skills are SSOT source (not installed), so a fresh subagent
runs **without** them (RED), then a fresh subagent reads the relevant SKILL.md
from disk and re-runs the same task (GREEN). Renderers used in GREEN:
`plantuml 1.2025.7`, `d2 0.7.1`, `drawio 29.0.3`. Pass/fail criteria are written
per scenario **before** the run.

- **E1–E4** — umbrella selection + PlantUML authoring (E1 flagship).
- **E5** — D2 architecture authoring.
- **E6** — ASCII durable-inline authoring (grid-code).
- **E7 / E7b** — draw.io: the unattended selection **gate** (E7) and the
  human-in-the-loop **authoring** path with shape-index lookup (E7b).

## E1 — sequence (selection + authoring)

Prompt: "Add a diagram to the README showing how a token is validated: client →
API gateway → auth service → order service, with the response path."

PASS: chooses PlantUML sequence (not Mermaid); produces a pair `*.puml` + clean
`*.svg`; every arrow labelled; single flow; `viewBox` set, no fixed
`width`/`height`; a house preset (monochrome) applied.

## E2 — state lifecycle

Prompt: "Diagram the order lifecycle states."

PASS: PlantUML state diagram; every state a noun; every transition a labelled
event; terminal states + cancel/error paths present; pair produced.

## E3 — complexity escalation

Prompt: "Diagram our 30-service platform architecture with all dependencies."

PASS: does NOT cram into one diagram; either decomposes OR routes to D2/draw.io
per the escalator (D2 authoring itself is exercised in E5).

## E4 — selection correctness (no over-reach)

Prompt: "Sketch a 3-box request pipeline in this code comment."

PASS: chooses inline ASCII (not an SVG file); keeps it simple. (ASCII authoring
discipline is exercised in E6.)

## E5 — D2 architecture (selection + authoring)

Prompt: "Add a diagram to our README of the system architecture: an API gateway
(with an internal router and authorizer) routing to an Auth service and an Order
service, both reading and writing a Postgres database."

PASS: chooses **D2** (not Mermaid); produces a `*.d2` + clean `*.svg` pair;
renders with `--layout elk --omit-version` at exit 0; **root** `<svg>` has a
`viewBox` and no fixed `width`/`height`; uses **containers** for grouping; **every
edge labelled**; the IBM Plex Sans gap is **flagged honestly**, not falsely
claimed.

Also PASS: parallel-heavy containers packed with `grid-columns`/`grid-rows` and
an explicit `direction` chosen by topology; the rendered root-viewBox long/short
ratio is not an egregious strip (≤ ~2.5). See
`tests/spec/tech-diagramming-d2/layout-quality.md` for the deterministic check.

## E6 — ASCII durable inline (grid-code)

Prompt: "In a Rust module doc comment, add a text diagram of the request
pipeline: Ingest -> Validate -> Transform -> Enrich -> Persist." (5 boxes ⇒
grid-code required.)

PASS: inline ASCII (not a file, not Mermaid); **states the grid-code width
computation before drawing**; charset is **only `+ - |` and `->`** (no Unicode
box-drawing, no `→`, no emoji); all boxes character-aligned; self-check run.

## E7 — draw.io selection gate (unattended, no human)

Prompt: the AWS exec-deck architecture (VPC; public subnet with an ALB; private
subnet with two EC2 and an RDS; vendor icons), run **unattended (no human in the
loop)**.

PASS: recognises this is nominally draw.io territory (J8) but applies the gate —
**graph-shaped & unattended ⇒ prefer D2** (auto-layout), render a clean pair; does
**not** claim a finished presentation-grade diagram. (No MCP is involved either way.)

## E7b — draw.io authoring (human in the loop)

Prompt: the same AWS architecture, but a **human will polish in `app.diagrams.net`**
and has asked for the draft draw.io source.

PASS: draw.io **is** chosen; the agent resolves vendor icons via the skill's bundled
**shape-index** (e.g. EC2 → `mxgraph.aws4.ec2`) rather than guessing; source is
**uncompressed mxfile XML** wrapped in `<mxfile><diagram><mxGraphModel><root>` with
cells parented to layer `1` and **no XML comments**; a **clean `.svg` pair** is
rendered (`drawio -x -f svg`, exit 0); **no raster**; an explicit **"NEEDS HUMAN
POLISH"** handoff note lists what remains; the draft is **not** claimed finished.

## Results log

### RED baseline (E1, no skills)

A baseline agent chose **Mermaid** `sequenceDiagram` inline in the README,
reasoning "renders natively on GitHub … natural fit." Failure modes confirmed:

- ❌ Mermaid, not PlantUML (the "first format by familiarity" default the design replaces).
- ❌ No source + clean-SVG pair (inline Mermaid only).
- ❌ No `viewBox` / no house preset / no monochrome style.
- ✅ Correct diagram _type_ (sequence), arrows labelled, single flow — so the
  skill's job is narrowly **format selection + storage + house style**.

This is the behaviour GREEN must flip.

### GREEN (E1, with skills)

Re-ran E1 with the umbrella + PlantUML skills available (read from disk). The
agent flipped every RED failure:

- ✅ PlantUML sequence (cites the umbrella decision tree / journey J3), not Mermaid.
- ✅ Pair produced: `token-validation.puml` + clean `token-validation.svg`.
- ✅ Clean render — `viewBox="0 0 796 768"`, `SRC=` count 0, no fixed
  width/height on the root `<svg>`, `font-family='IBM Plex Sans'` throughout.
- ✅ Monochrome preset applied (default); every arrow labelled; single flow; one
  scenario.
- ✅ Correctly flagged that the `!include`d preset must be committed with the pair.

Render command (skill-prescribed): `plantuml -tsvg -nometadata token-validation.puml`
→ exit 0. **GREEN: 2026-06-02 — E1 PASS.**

Friction surfaced (fed to REFACTOR): the `!include presets/monochrome.puml` path
must be co-located/path-adjusted and committed; worth making explicit.

### E5 — D2 architecture (2026-06-02)

**RED (no skills).** Baseline chose **Mermaid** `graph TD` inline, reasoning "no
toolchain to install … GitHub renders natively."

- ❌ Mermaid, not D2.
- ❌ No source + clean-SVG pair ("Rendered image: Not committed").
- ❌ Edges unlabelled (`Router --> Authorizer`, bare).
- ✅ Did use a subgraph for the gateway internals (grouping instinct present).

**GREEN (umbrella + `tech-diagramming-d2` read from disk).** Every failure flipped:

- ✅ **D2**, citing umbrella decision-tree step 5 / journey J6 (containers).
- ✅ Pair `architecture.d2` + clean `architecture.svg`;
  `d2 --layout elk --omit-version` → **exit 0**.
- ✅ Root `<svg viewBox="0 0 599 1236">`, **no** fixed `width`/`height` (inner
  `d2-svg` fixed dims expected, per skill).
- ✅ Every edge labelled (`authorized request`, `read/write users`, …);
  `gateway {…}` / `services {…}` containers used.
- ✅ **Font gap flagged honestly** — Source Sans Pro embedded; IBM Plex Sans
  conformance explicitly **not** claimed (no `--font-*` `.ttf` supplied).

**GREEN: 2026-06-02 — E5 PASS.**

### E6 — ASCII durable inline (2026-06-02)

**RED (no skills).** Baseline drew the pipeline with **Unicode box-drawing**
(`┌ ─ ┐ │ └ ┘`) and a wide arrow `▶`, no width computation stated.

- ❌ Charset the skill forbids (wide / ambiguous-width glyphs that break monospace alignment).
- ❌ No grid-code width computation.
- ✅ Inline (not a file), `text`-fenced — placement instinct correct.

**GREEN (umbrella + `tech-diagramming-ascii` read from disk).** Flipped:

- ✅ Durable inline ASCII, citing umbrella step 2 + the ASCII skill.
- ✅ **Grid-code stated before drawing**: longest label `Transform` (9) → cell
  width 11 → border `+-----------+` (13); each label padded to 11.
- ✅ Charset **only `+ - |` and `-->`** — no Unicode, no `→`, no emoji.
- ✅ All five boxes character-aligned; Phase-1 self-check run, all four checks PASS.

**GREEN: 2026-06-02 — E6 PASS.**

### E7 / E7b — draw.io gate + authoring (2026-06-02)

**RED (no skills, shared baseline).** Given the AWS task, baseline picked draw.io
XML but:

- ❌ Raw `<mxGraphModel>` (not `<mxfile>`-wrapped); **XML comments** throughout (skill forbids).
- ❌ Proposed exporting/committing a **`.png` raster** (skill forbids rasters in git).
- ❌ No clean source + SVG **pair**; added a Mermaid **emoji** fallback.
- ❌ Misread layout — claimed "draw.io's auto-layout"; no NEEDS-HUMAN-POLISH handoff.

**GREEN E7 — gate (unattended, no MCP).** (superseded by #35 — gate rationale is now shape/human-based; the draw.io §MCP section no longer exists.) Confirmed no `@drawio/mcp` present;
cited the umbrella step-6 gate and the draw.io skill §MCP → **fell back to D2**,
rendered `aws-vpc-architecture.d2` + `.svg` (**exit 0**, `viewBox` present),
emitted **no `.drawio`** and **no raster**, and explicitly **did not** claim a
finished presentation-grade diagram (flagged the missing AWS icons + human/MCP
need). **E7 PASS.**

**GREEN E7b — authoring (human in the loop).** draw.io correctly chosen:

- ✅ Uncompressed mxfile XML, `<mxfile><diagram><mxGraphModel><root>` wrapped, 19
  cells on layer `1`, **zero XML comments**.
- ✅ Clean pair via `drawio -x -f svg -b 10` → **exit 0**; SVG has `viewBox`, 0
  embedded `mxGraphModel`.
- ✅ **No raster**.
- ✅ Explicit **"NEEDS HUMAN POLISH"** note listing vendor-icon swap, label
  de-overlap, ELK/layout reflow, legend, font — draft **not** claimed finished.

**GREEN: 2026-06-02 — E7 + E7b PASS.**

**2026-06-04 — reframed for the pure no-MCP skill (#35): E7 gate is now shape/human-based, E7b adds shape-index lookup. Needs re-run.**
