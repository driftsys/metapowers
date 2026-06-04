# sdd-gardening — dev-role end-to-end harness (v0.1.0)

The triggering battery ([scenarios.md](scenarios.md)) measured **description
discrimination** closed-book: a clean-room agent picks a skill from a handed-in
list. It deliberately did **not** measure live-registry activation or end-to-end
behavior — those are this harness.

Here a **fresh agent plays the developer** finishing a Superpowers cycle, in a
sandbox where the metapowers items are in a **live skill registry** it can
actually discover and invoke. We observe whether gardening fires **on its own** at
wrap-up, whether the `sdd-gardener` agent returns a valid digest, whether the durable triad
and archive are produced, and whether the WIP-gate flips red → green.

## The live-registry decision (why a sandbox + a real session)

Genuine activation cannot be tested by handing an agent skill descriptions, nor by
a `Task`/Agent-tool subagent — a dispatched subagent inherits the **parent
session's** registry, and the metapowers items are SSOT source here, not installed
skills. The only faithful mechanism is a **separate Claude Code session whose
project registry actually contains the items**:

1. A throwaway git repo (`/tmp/...`), seeded to look like the end of a cycle.
2. `upskill add <metapowers.bundle.yaml> --project` installs the items into the
   sandbox's `.claude/`. Verified live: the `sdd-gardening` skill is discovered,
   the co-located `sdd-gardener` agent is dispatchable (`subagent_type:
   sdd-gardener` — the agent is co-located in the `sdd-gardening/` dir but keeps
   its own divergent name, which upskill ≥ 0.7.4 allows), and the
   `sdd-working-memory-lifecycle` rule is auto-loaded (Claude Code reads
   `.claude/rules/*.md`).
3. A fresh `claude -p` session is opened **in the sandbox** as the dev-role agent.
   The Superpowers plugin is inherited from the user-global install, so
   `finishing-a-development-branch` is also present — the harness tests whether the
   rule makes finishing → gardening actually fire alongside it.

`setup-sandbox.sh green|red <dir>` builds the sandbox. **The harness never copies
the gate into the RED sandbox**: its comments and error message name the
`sdd-gardening` skill and the garden→archive procedure, so a RED agent that could
read it would learn the procedure and the baseline would no longer be clean (this
was observed and fixed during the 2026-06-02 run). RED installs no bundle, so it
has no gate. GREEN installs the bundle, so since upskill 0.7.2 the gate ships into
`.claude/rules/sdd-working-memory-lifecycle/wip-gate.sh` — harmless there, since GREEN
already has the rule and skill loaded. Either way the **observer** runs the
canonical script from the metapowers repo with cwd set to the sandbox — it only
needs `git ls-files wip/superpowers/`, which resolves against cwd.

## Fixture (what the sandbox contains, on branch `feat/retry-backoff`)

A finished, **tests-green** feature — HTTP client retry with backoff:

- `wip/superpowers/specs/retry-backoff.md`, `wip/superpowers/plans/retry-backoff.md`
  — tracked working memory (collaborative mode), with an "Alternatives considered"
  section so the gardener has real decision rationale to route.
- `src/retry.py`, `tests/test_retry.py` — implementation + passing tests
  (`python3 tests/test_retry.py`, exit 0).
- `docs/` empty.

**Planted divergence (reconciliation probe):** the spec's R4 states the default
retry budget is **5 attempts**; the as-built code defaults to **3**
(`max_attempts=3`). A faithful gardener reconciling records against as-built code
should **flag** this, not copy the spec's "5" through.

## The dev-role prompt (verbatim — note: gardening is never mentioned)

> You are a developer on the `feat/retry-backoff` branch of this repository. You
> have finished implementing HTTP client retry with backoff and the tests pass
> (`python3 tests/test_retry.py`). You are about to open a pull request to `main`.
> Do whatever you would normally do to get this branch ready to merge. When you
> are finished, give a short summary of what you did.

The prompt describes only a developer finishing a branch. It does **not** say
"garden", "promote", "write docs", or "archive". Activation must come from the
live registry (rule + skill description), not the prompt.

## Pass / fail criteria (written before running)

| # | Criterion                | PASS                                                                                                                                        |
| - | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | **Activation**           | The agent invokes the `sdd-gardening` skill at wrap-up without being told to garden.                                                        |
| 2 | **Delegation**           | The `sdd-gardening` skill dispatches its co-located `sdd-gardener` agent (`subagent_type: sdd-gardener`), not inline gardening.             |
| 3 | **Return contract**      | The `sdd-gardener` agent returns a digest matching its contract (status / records / divergences / offers / wip / notes), no raw file dumps. |
| 4 | **Triad produced**       | `docs/spec/retry-backoff.md`, a `docs/decisions/<topic>.md` with an `AD-NNNN` id, and `docs/design/retry-backoff.md` all exist.             |
| 5 | **Archive + empty wip**  | Raw spec+plan are moved to `archive/superpowers/`; `git ls-files wip/superpowers/` is empty.                                                |
| 6 | **WIP-gate red → green** | The WIP-gate (run by the observer) exits 1 before gardening and 0 after.                                                                    |
| 7 | **Reconciliation**       | The planted 5-vs-3 retry-budget divergence is flagged (not silently copied through).                                                        |

RED control (sandbox built with `red`, items absent) confirms the items are
load-bearing: the dev-role agent does **not** produce the triad + archive (it
merges as-is, or writes ad-hoc docs, leaving `wip/` non-empty and no gate).

## How to run

### Automated (scripted headless session)

```bash
EVAL=tests/spec/sdd-gardening
GATE="$PWD/skills/sdd-working-memory-lifecycle/wip-gate.sh"   # observer-only; not in sandbox
PROMPT="You are a developer on the feat/retry-backoff branch of this repository. You have finished implementing HTTP client retry with backoff and the tests pass (python3 tests/test_retry.py). You are about to open a pull request to main. Do whatever you would normally do to get this branch ready to merge. When you are finished, give a short summary of what you did."
TOOLS="Read,Write,Edit,Bash,Glob,Grep,Agent,Task,Skill,TodoWrite"

# GREEN — live registry present
bash $EVAL/setup-sandbox.sh green /tmp/sdd-green
( cd /tmp/sdd-green && bash "$GATE"; echo "gate(before)=$?" )          # expect 1
( cd /tmp/sdd-green && claude -p "$PROMPT" --allowedTools "$TOOLS" )
# then verify, as the observer:
( cd /tmp/sdd-green && \
  ls docs/spec docs/decisions docs/design && \
  echo "wip:"; git ls-files wip/superpowers/ && \
  echo "archive:"; git -c core.quotepath=off status --porcelain archive/ && \
  bash "$GATE"; echo "gate(after)=$?" )                                # expect 0

# RED — control, items absent (no gate script in the sandbox to leak the procedure)
bash $EVAL/setup-sandbox.sh red /tmp/sdd-red
( cd /tmp/sdd-red && claude -p "$PROMPT" --allowedTools "$TOOLS" )
```

The `--allowedTools` list is scoped (no `--dangerously-skip-permissions`): the
sandbox is a throwaway `/tmp` repo and the agent only needs file, shell, subagent,
and skill tools. (The subagent-dispatch tool is named `Agent` in Claude Code
≥ 2.1; older builds call it `Task` — both are listed for portability.)

### Manual handoff (fresh interactive session)

If scripted headless runs are unavailable: run `setup-sandbox.sh green <dir>`,
open a **new** Claude Code session in `<dir>`, paste the dev-role prompt, then
apply the pass/fail table yourself (a paste-into-a-fresh-session handoff style).

## Recording results

Append a dated run to `results-dev-role-YYYY-MM-DD.md`: the verdict per criterion,
the captured `sdd-gardener` agent digest, the observer's filesystem checks, and any gaps
fed back into the items.
