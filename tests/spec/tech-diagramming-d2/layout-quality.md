# tech-diagramming-d2 — layout-quality eval

Verifies the **Layout quality** guidance in `skills/tech-diagramming-d2/SKILL.md`:
direction-by-topology + grid-packing parallel nodes, and the measured
render-check. Renderer: `d2 0.7.1` (elk). No vision, no network.

## Deterministic check (the grid lever)

`check-aspect.sh` renders a `.d2` with elk and prints the root-viewBox long/short
ratio (exit 0 iff `≤ 2.5`). The binding assertion is **relative**: grid-packing a
parallel set reduces the ratio.

```bash
DIR=tests/spec/tech-diagramming-d2
n="$("$DIR/check-aspect.sh" "$DIR/fixtures/fan-naive.d2")"   # ≈ 2.43, band=IN
t="$("$DIR/check-aspect.sh" "$DIR/fixtures/fan-tuned.d2")" \
  || { echo "FAIL: fan-tuned band=OUT"; exit 1; }            # ≈ 1.91; non-zero exit ⇒ band=OUT
awk -v n="$n" -v t="$t" 'BEGIN{ exit !(t < n) }'             # PASS: tuned < naive
```

## Behavioural scenarios (RED→GREEN, subagent)

Harness matches `tests/evals/tech-diagramming.md`: a fresh subagent runs the task
**without** the skill (RED), then **with** `skills/tech-diagramming-d2/SKILL.md`
read from disk (GREEN). Pass criteria are fixed before the run.

### L1 — flat parallel set

Prompt: "Draw a D2 diagram: a load balancer fanning out to 12 stateless
services."

PASS (GREEN): the parallel siblings are packed with a grid (`grid-columns` **or**
`grid-rows` — one is sufficient) so they form a block, not a single file; a
`*.d2` + clean `*.svg` pair is produced; the render is `band=IN`. (The
ratio-vs-ungridded comparison is covered by the deterministic check above; the
behavioural run is judged on whether the agent reaches for a grid at all.)

### L2 — deep nested architecture

Prompt: "Draw a D2 diagram of a 3-tier app: edge services (DNS, CDN, WAF, auth),
a VPC with public/app/data subnets and an async pipeline, plus monitoring."

PASS (GREEN): an explicit `direction:` chosen by topology; every container
holding ≥ 4 sibling nodes (the subnets, the edge-services group) packed with a
grid (`grid-columns`/`grid-rows`); `elk` engine; pair produced; render not an
egregious strip (`band=IN`). (Direction choice and the icon-rich strip fix are
exercised here — they are not part of the deterministic check above.)
