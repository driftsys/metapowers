# diagrampowers — over-engineering harness (v0.1.0)

**Question under test:** are the diagramming skills over-engineered? Reframed as
RED-GREEN (see `upskill-evaluating-prompts`): _does the absence of these skills
cause a worse result?_ If a capable bare model already produces equivalent output
(RED passes on its own), the content adds nothing and is over-engineered. If RED
fails where GREEN succeeds, the content is load-bearing.

This first pass attacks the two cheapest, highest-signal targets:

- **Target A — tool-selection routing** (the umbrella's §1: journeys J1–J8, the
  tool-strength matrix, the decision tree, ~half of `tech-diagramming/SKILL.md`).
- **Target B — the bundled drawio shape-index** (a gzipped 10k-shape DB shipped as
  a resource in `tech-diagramming-drawio/`, the heaviest data artifact in the
  family, for a tool the umbrella itself frames as "last resort").

It does **not** test the per-format authoring bodies (PlantUML/D2/ASCII syntax,
render mechanics) or the four installer AGENTs. Those are follow-ups.

## Harness — live registry, isolated

Same faithful mechanism as `tests/spec/sdd-gardening`, adapted for a machine that
**dogfoods** the skills user-globally. `setup-sandbox.sh red|green <dir>` builds a
throwaway repo; the runner passes `--setting-sources project,local`.

- **RED** — empty sandbox, no install. `--setting-sources project,local` drops the
  `user` scope where the global `~/.claude/skills/tech-diagramming*` live.
  Verified: the session lists **NONE** for diagram skills and stays authed (keychain
  is untouched; this is NOT `CLAUDE_CONFIG_DIR`, which detaches the token, and NOT
  `--bare`, which never reads keychain).
- **GREEN** — `upskill add diagrampowers.bundle.yaml --project` installs the five
  skills into the sandbox's project-scope `.claude/`, plus delivers the drawio
  `data/shape-index.jsonl.gz` resource. Verified: the session lists all five.

Only the diagram skills differ between RED and GREEN; auth, plugins (Superpowers),
model, and prompt are held constant. GREEN tests **genuine activation**, not pasted
skill text.

```bash
EVAL=tests/spec/diagrampowers
TOOLS="Read,Write,Edit,Bash,Glob,Grep,Agent,Skill,TodoWrite"
SS="project,local"            # the isolation lever — REQUIRED

# Target A
for M in red green; do
  bash $EVAL/setup-sandbox.sh $M /tmp/diag-A-$M
  ( cd /tmp/diag-A-$M && claude -p "$(cat $OLDPWD/$EVAL/prompts/tool-selection.txt)" \
      --allowedTools "$TOOLS" --setting-sources "$SS" ) | tee $EVAL/runs/A-$M.out
done

# Target B
for M in red green; do
  bash $EVAL/setup-sandbox.sh $M /tmp/diag-B-$M
  ( cd /tmp/diag-B-$M && claude -p "$(cat $OLDPWD/$EVAL/prompts/shape-index.txt)" \
      --allowedTools "$TOOLS" --setting-sources "$SS" ) | tee $EVAL/runs/B-$M.out
done
```

LLMs are stochastic; a borderline verdict warrants ≥3 trials per cell.

## Target A — pass/fail criteria (written before running)

Prompt: `prompts/tool-selection.txt` — six diagram needs, mapped to the umbrella's
journeys. The prompt names **no tool** (no priming). Per scenario, score two axes:

- **Competence** — did the model pick a _render-don't-draw_, version-controllable,
  text-or-source approach? FAIL = "draw it in Figma", "screenshot", hand-placed
  pixels, or an un-renderable answer.
- **House-match** — does the choice match the umbrella's prescribed tool?

| #  | Need                     | Umbrella prescribes | Competence PASS bar                                  |
| -- | ------------------------ | ------------------- | ---------------------------------------------------- |
| A1 | login message flow       | PlantUML sequence   | any text/source sequence tool                        |
| A2 | order state lifecycle    | PlantUML state      | any text/source state tool                           |
| A3 | service architecture map | D2                  | any text/source graph tool with auto-layout          |
| A4 | DB schema + FKs          | D2 (`sql_table`)    | any text/source ER tool                              |
| A5 | 3-stage pipeline, README | ASCII (durable)     | inline text diagram — NOT an external image file     |
| A6 | icon-rich AWS, deck      | draw.io (or D2)     | does NOT hand-place an un-laid-out drawing; sensible |

**Mermaid is recorded separately as a "reasonable substitute," not a failure.** The
umbrella deliberately routes to PlantUML/D2 over Mermaid; a bare model that picks
Mermaid for A1–A4 is _competent but off-house_. Whether that is a real quality gap
or pure house preference is the crux of the verdict.

**Over-engineering verdict (A):**

- **Over-engineered** if RED competence is high (≈6/6) and the only RED→GREEN delta
  is house-preference substitution (e.g. Mermaid→PlantUML/D2) with no outcome-quality
  difference. The routing apparatus would then be encoding a preference a capable
  model satisfies unaided.
- **Justified** if RED makes genuine routing errors that GREEN fixes — e.g. A5 as an
  external PNG, A6 hand-placed/un-laid-out, A3 with a no-auto-layout tool, or
  behavioural-vs-structural confusion.
- Also note whether GREEN **activates** `tech-diagramming` at all for a planning
  prompt. If it does not fire, the routing layer is moot at decision time regardless
  of its content.

## Target B — pass/fail criteria (deterministic; written before running)

Prompt: `prompts/shape-index.txt` — four AWS icons. **Ground truth** (the exact
mxgraph identifiers, confirmed present in the index, one canonical match each):

| Resource           | Correct token              |
| ------------------ | -------------------------- |
| AWS Lambda         | `mxgraph.aws4.lambda`      |
| Amazon S3          | `mxgraph.aws4.s3`          |
| Amazon DynamoDB    | `mxgraph.aws4.dynamodb`    |
| Amazon API Gateway | `mxgraph.aws4.api_gateway` |

**Score** = number of the four whose emitted `style` string contains the correct
`mxgraph.aws4.<name>` token (as `resIcon=` or `shape=`). A plausible-but-wrong
string (`shape=mxgraph.aws.lambda`, `shape=lambda`, a generic rectangle, an invented
`resIcon`) scores 0 for that resource. Checked with:

```bash
for t in lambda s3 dynamodb api_gateway; do
  grep -q "mxgraph.aws4.$t\b" runs/B-<mode>.out && echo "$t OK" || echo "$t MISS"
done
```

**Over-engineering verdict (B):**

- **Over-engineered** if RED already scores ≥3/4 from the model's own knowledge —
  the 10k-shape index would be redundant.
- **Justified** if RED scores ≤1/4 (hallucinated/wrong tokens) and GREEN reaches 4/4
  by consulting the delivered index — the index is then load-bearing, and its
  delivery via `upskill add` is what makes GREEN possible.

## Recording results

Append a dated `results-YYYY-MM-DD.md`: per-cell verdicts, the captured outputs
(`runs/{A,B}-{red,green}.out`), whether GREEN activated the skill (from the run
transcript), and the over-engineering verdict per target with the evidence.

## Known gap

This pass does not isolate the umbrella's **content** from its **activation**: a
live-registry GREEN that does not activate the skill looks identical to RED. If
Target A is inconclusive for that reason, add a content-paste GREEN (feed
`tech-diagramming/SKILL.md` §1 directly, per the `tech-diagramming-d2` precedent) to
separate "the routing content is wrong/unhelpful" from "the skill never fired."
