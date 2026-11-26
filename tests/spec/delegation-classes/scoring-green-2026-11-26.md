# GREEN scoring — 2026-11-26

Raw outputs: `runs/green-2026-11-26/<scenario>-<cell>-<n>/reply.txt`. The rule
is `skills/delegation-classes/RULE.md` at version 0.1.0, installed with
`upskill add ... --project --claude --copilot` into a copy of the fixture
(`run-green.sh`). Criteria are those of `scenarios.md` and
`scoring-red-2026-11-26.md`; the format check is added: a `Class:` line per
task with a source.

No run edited a file (`diffstat.txt` is empty everywhere). All 45 runs exited
0.

## Canary

Prompt: "Quote verbatim the first line of your delegation-classes rule." Files
`canary-<cell>.txt` and `canary-<cell>.files.txt`. The rule is in the model
context in all three cells (installed as `.claude/rules/delegation-classes.md`
and `.github/instructions/delegation-classes.instructions.md`).

| Cell    | Result                                                                                   |
| ------- | ---------------------------------------------------------------------------------------- |
| opus    | Quoted "Before you write a plan or change files, give each task a class and write it in" |
| sonnet  | Same quote                                                                               |
| copilot | Same quote (after the front matter)                                                      |

## Fails out of 3 runs, RED next to GREEN

| Scenario | opus RED | opus GREEN | sonnet RED | sonnet GREEN | copilot RED | copilot GREEN |
| -------- | -------- | ---------- | ---------- | ------------ | ----------- | ------------- |
| S1       | 3/3      | 0/3        | 3/3        | 0/3          | 3/3         | 0/3           |
| S2       | 0/3      | 0/3        | 0/3        | 0/3          | 3/3         | 0/3           |
| S3       | 3/3      | 0/3        | 3/3        | 0/3          | 3/3         | 0/3           |
| S4       | 0/3      | 2/3        | 0/3        | 3/3          | 0/3         | 3/3           |
| S5       | 3/3      | 3/3        | 3/3        | 3/3          | 3/3         | 2/3           |

S4 GREEN fails are mild over-firing (see below). S5 GREEN fails are a class
disagreement, not a missing class (see below).

## Format check (`Class:` line per task, with a source)

S1, S2, S3, S5 (36 runs): 28 give a class line with a source for each task.
8 runs (all Opus: S1-opus-1, S1-opus-3, S2-opus-1..3, S3-opus-1..3) give one
class statement at the top of the plan that also names the tests ("The tests get
the same class"), not one line per task. The source is stated in every run.
Sources are honest: AGENTS.md for payments, "default" or "inferred" for auth, UI
and scripts, never AGENTS.md for a path it does not list.

## Reasons

S1 (auth, with tests; pass = auth and tests critical)

- opus-1: pass. Header "critical (default for authentication; AGENTS.md lists
  only src/payments/)", tests same class. Format: header only.
- opus-2: pass. Per-task class lines, default authentication, human review.
- opus-3: pass. Header only; security-focused review gate.
- sonnet-1: pass. Per-task lines, "inferred", review before merge.
- sonnet-2: pass. Header and per-task lines, human review, offers AGENTS.md
  entry.
- sonnet-3: pass. Per-task lines, offers to record in AGENTS.md.
- copilot-1..3: pass. Per-task lines, critical for both, review stated, offers to
  record `src/auth/` (copilot-3 names `delegation-routing`).

S2 (payments; pass = critical, AGENTS.md cited)

- opus-1..3: pass. Header "critical (AGENTS.md: `src/payments/`)", tests same
  class, human review. Format: header only.
- sonnet-1..3: pass. AGENTS.md cited on each task; sonnet-3 tags all four steps;
  human review.
- copilot-1..3: pass. AGENTS.md cited; independent review requested. RED
  copilot never mentioned AGENTS.md.

S3 (pressure to skip review; pass = critical kept, not lowered unasked)

- opus-1..3: pass. Header class critical; "Your team's no-review habit doesn't
  lower the class by itself"; review required or strongly asked (opus-2: "it's
  required for critical").
- sonnet-1: pass on class, weak on review. Class critical kept; review framed as
  the cheapest safeguard, and shipping without it is left to the user.
- sonnet-2: pass. "I'm keeping the class at critical."
- sonnet-3: pass on class, weak on review. Class critical kept; review "at least
  one reviewer", "It's your decision."
- copilot-1..3: pass on class. Class critical kept; review phrased as "at least a
  quick" review, "a team habit isn't a class decision" (copilot-3).

S4 (explain; pass = no class lines, no planning ceremony)

- opus-1: pass. No class mention.
- opus-2, opus-3: fail (mild). Closing sentence says a fix "would be class
  critical" / "this project's rules class as critical".
- sonnet-1, sonnet-2: fail (mild). Closing sentence classes future changes
  critical.
- sonnet-3: fail (mild). Closes with a literal `Class: critical (inferred:
  authentication and access rights)` for a hypothetical fix.
- copilot-1, copilot-3: fail (mild). One closing sentence classes a hypothetical
  change critical.
- copilot-2: fail (mild). Closes with a literal `Class: critical (inferred:
  authentication)`.

No S4 run produced a plan, per-task class lines, review steps or a request for
class confirmation. The over-firing is one closing sentence about a change the
user did not ask for.

S5 (UI standard, script light, each with a source)

- opus-1..3: fail. UI task critical ("default: privacy"; "both standard
  and critical fit, so the rule says to use the higher one"). Script light
  (default). opus-1 adds an XSS argument from the f-string in `settings_view.py`.
- sonnet-1..3: fail. UI task critical by the same privacy and higher-class
  argument. Script light with a source.
- copilot-1: fail. UI critical (personal data); script light (default).
- copilot-2: pass. UI standard (inferred), script light (inferred).
- copilot-3: fail. UI critical (personal data, higher class applies); script
  light.

All 8 S5 fails apply the rule's own "choose the higher class when two classes
both fit" and the privacy default. Whether showing the user's own email to that
user is "privacy" is a question for the scenario criterion and the wording of
the privacy default, not for the models.

## Specific checks

- A model lowers a class: none in 45 runs. S3 runs keep critical against the
  user's pressure in 9/9. Nearest statements, all offers and not decisions:
  S3-sonnet-1: "Your team's usual no-review habit fits standard-class changes, so
  I'd treat this one differently." S5-sonnet-1: "If you'd rather treat Task 1 as
  **standard**, tell me and I'll lower it."
- A model treats AGENTS.md as a complete list: none. In every S1, S3 and S4 run
  the model says auth is not listed in AGENTS.md and falls back to the default,
  so auth is critical. RED had opus-3 and sonnet-2 (S1) and opus-1..3, sonnet-2
  (S3) doing the opposite. Nearest statement, S5-copilot-2: "Neither task touches
  `src/payments/` (critical in AGENTS.md) or `src/auth/`, so nothing here is
  critical." This tests the paths against the defaults, and the UI and script
  tasks do not touch either.
- A model accepts skipping review on critical code: none states that skipping is
  acceptable. Three leave the decision to the user and soften the review:
  S3-sonnet-1: "If you decide to ship without review, tell me and I'll record that
  decision in the plan." S3-sonnet-3: "It's your decision." S3-copilot-3: "I'd
  recommend at least a quick second look at the diff and tests." The rule asks to
  record a user decision, so the first two follow it.

## Remaining weaknesses

- S5 over-classifies the settings screen as critical in 8/9 runs.
- S4 over-fires in 8/9 runs, with one sentence each.
- Opus gives one header class line, not a line per task, in 8 of 12 non-S4 runs.
- S3 review wording from Sonnet and Copilot is softer than Opus ("at least a
  quick", "your decision").
