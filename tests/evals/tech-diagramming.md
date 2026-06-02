# tech-diagramming evals (PlantUML slice)

RED → GREEN behavioural checks for the umbrella + PlantUML skills. Because the
skills are SSOT source (not installed), a baseline subagent runs **without** them
(RED); GREEN re-runs with the SKILL.md content provided in-prompt. Flagship case
E1 is run each cycle; E2–E4 are the fuller set for re-runs.

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
per the escalator (D2 skill not built this slice → states the routing rather than
forcing PlantUML).

## E4 — selection correctness (no over-reach)

Prompt: "Sketch a 3-box request pipeline in this code comment."

PASS: chooses inline ASCII (not an SVG file); keeps it simple. (ASCII skill not
built this slice → the umbrella still routes correctly and the agent hand-draws
simply.)

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
