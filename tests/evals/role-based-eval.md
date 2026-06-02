# tech-diagramming — role-based generation eval (handoff)

A behavioural eval of the `tech-diagramming` skillset against realistic diagram
tasks a **maintainer**, **dev**, and **architect** actually write. It checks
_what the skills make an agent generate_ — tool choice, artifact shape, house
style, self-check, and boundary handling.

> **Run this in a fresh session.** Paste the "How to run" section below into a new
> Claude Code session opened in the `metapowers` repo. It is self-contained.

---

## How to run (paste into a fresh session)

> You are running a behavioural eval of the `tech-diagramming` skill family in
> this metapowers repo. The skills are SSOT source under `skills/tech-diagramming*`
> (NOT installed) — so a subagent only "has" them if you tell it to read them.
>
> For EACH task in the table below:
>
> 1. Dispatch a general-purpose subagent. Tell it to **first read** the umbrella
>    `skills/tech-diagramming/SKILL.md` and follow it (it will dispatch itself to
>    a format skill — also have it read the relevant `skills/tech-diagramming-<fmt>/SKILL.md`).
> 2. Give it the task's **Prompt** verbatim. Have it produce the artifact(s) in
>    `/tmp/diag-eval/<task-id>/` (NEVER touch the repo). For source formats it must
>    run the render command the skill prescribes.
> 3. Have it report: the tool + diagram type it chose and why (citing the skill),
>    the files produced, the render command + exit code, and its Phase-1 self-check.
> 4. THEN verify independently (don't trust the subagent): render the source
>    yourself if needed; check the SVG (`grep -c viewBox`, `grep -c 'SRC='`, fixed
>    width/height on root `<svg>`, house font); confirm the tool matches **Expected
>    tool**; check labels/single-intent.
> 5. Score each task in a scorecard: `task | expected tool | actual tool | artifact ok? | house-style ok? | self-check? | escalation ok? | PASS/FAIL | notes`.
>
> Renderers available: `plantuml`, `d2`, `dot`, `drawio` (CLI). The `@drawio/mcp`
> MCP is likely NOT present — for draw.io tasks, a PASS is the agent correctly
> scaffolding `.drawio` XML and **flagging "agent drafts, human polishes"**, not a
> finished diagram. ASCII needs no tooling.
>
> Finish with a summary: per-role pass rate, and any **skill gaps** the eval
> surfaced (wrong tool chosen, missing house style, no escalation, bad self-check)
> — these become follow-up fixes.

---

## Pass criteria (the rubric)

Per task, PASS requires:

- **Tool selection** matches the umbrella's decision tree for that journey/complexity.
- **Artifact** is correct for the tool: source+clean-SVG **pair** for PlantUML/D2/draw.io (`foo.svg` renders, has `viewBox`, no fixed width/height on the root `<svg>`, no embedded `SRC=` for the clean pair); **inline ASCII** for ASCII (column-aligned, ASCII charset, no SVG file).
- **House style** applied where the tool supports it (PlantUML monochrome/categorical preset; D2 — honest gaps OK per its skill).
- **Self-check** evidence (the agent ran the Phase-1 checklist: renders, labelled, single intent).
- **Boundary handling**: at an escalation/fallback edge, the agent decomposes, escalates, or falls back (ASCII/raw-SVG/defer-render) per the umbrella — instead of forcing a bad fit.

---

## Tasks

### Maintainer (documenting existing systems for other maintainers)

| ID | Prompt                                                                                                                        | Expected tool           | Expected artifact                 |
| -- | ----------------------------------------------------------------------------------------------------------------------------- | ----------------------- | --------------------------------- |
| M1 | "Document how cache invalidation works in this module — the call flow when a write happens, across Writer, Cache, and Store." | PlantUML sequence       | `.puml` + `.svg` pair             |
| M2 | "Diagram the lifecycle states of a background job: queued → running → done / failed / retrying."                              | PlantUML state          | pair, terminal + retry/fail paths |
| M3 | "Add a directory-structure overview of the `auth` package to its README."                                                     | ASCII tree              | inline `├──`/indentation, aligned |
| M4 | "Document the on-disk record layout for our binary format: a 16-byte header (magic, version, length, flags) then payload."    | ASCII byte/table layout | inline fixed-width cells, aligned |

### Dev (building / debugging features)

| ID | Prompt                                                                                                 | Expected tool     | Expected artifact                      |
| -- | ------------------------------------------------------------------------------------------------------ | ----------------- | -------------------------------------- |
| D1 | "Diagram the OAuth login sequence: browser → app → identity provider → callback → app."                | PlantUML sequence | pair, labelled arrows, single scenario |
| D2 | "Quick sketch in this code comment of the retry pipeline: receive → attempt → backoff → give-up."      | ASCII (inline)    | aligned `+--+`, ASCII charset          |
| D3 | "Add an ER diagram for new tables: orders, line_items, payments, with their relationships."            | D2 (`sql_table`)  | `.d2` + `.svg` pair                    |
| D4 | "Flowchart the request-validation logic: authenticate → rate-limit → validate body → handle / reject." | PlantUML activity | pair, labelled branches                |

### Architect (system design + stakeholder comms)

| ID | Prompt                                                                                                                    | Expected tool                | Expected artifact                                                                |
| -- | ------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------------------------------------------------------------------------------- |
| A1 | "Map our service architecture: web, api-gateway, auth, orders, payments services, their datastores, and the message bus." | D2 (containers)              | `.d2` + `.svg` pair, nested containers                                           |
| A2 | "Draw a C4 container view of the platform (the major containers and how they talk)."                                      | PlantUML (C4-PlantUML) or D2 | pair; umbrella routes C4-container → D2, C4-context → PlantUML                   |
| A3 | "Diagram the AWS deployment: a VPC with public/private subnets, ECS services, an RDS instance, and S3."                   | draw.io (icon-rich cloud)    | `.drawio` scaffold + **"agent drafts, human polishes"** flag (MCP likely absent) |
| A4 | "Show the event flow across services for order fulfilment (order placed → payment → inventory → shipping)."               | D2 or PlantUML sequence      | pair; cross-service interaction                                                  |

### Boundary / fallback probes

| ID | Prompt                                                                                                          | Expected behaviour                                                                                                                                 |
| -- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| B1 | "Diagram our 40-service platform with every dependency, in one diagram."                                        | Does NOT cram one diagram — decomposes or escalates per the complexity escalator.                                                                  |
| B2 | "Make a sequence diagram for the login flow, but PlantUML/Java isn't installed and I don't want to install it." | Offers install; on decline → falls back (ASCII for simple, or raw-SVG, or emit `.puml` + defer render) — per the umbrella install/fallback ladder. |
| B3 | "Just use Mermaid for this, it renders on GitHub."                                                              | Declines Mermaid; cites the storage convention (pair + the GitHub-renders-natively argument the convention overrides).                             |

---

## Notes

- This eval is Phase-1 (no `diagctl`). Verification is the rubric above applied by
  the running session + your judgement, not an automated gate.
- Record results back here (append a "Results YYYY-MM-DD" section) or wherever you
  prefer; the gaps it surfaces feed the next round of skill fixes.
