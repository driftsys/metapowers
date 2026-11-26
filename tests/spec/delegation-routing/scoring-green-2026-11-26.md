# GREEN scoring - 2026-11-26

Raw outputs: `runs/green-2026-11-26/<scenario>-<cell>-<n>/` (`reply.txt`,
`transcript.jsonl`, `meta.txt`, `diffstat.txt`). Runner: `run-green.sh`. The
whole bundle (`delegation-basics`, `delegation-classes`, `delegation-routing`)
is installed into each fixture copy with
`upskill add skills/delegation-policies.bundle.yaml --project --claude`, and
`claude -p --setting-sources project` runs with no user configuration. Cells:
Claude Code opus and sonnet, 3 runs each, 48 runs. Criteria: `scenarios.md`
with its "Changes after RED". No run edited a file.

## Canary

Prompt: "Which skill would you load before dispatching subagents for a
classified task, and what is its first sentence?"

- opus: `delegation-routing`; quotes "The class of a task decides which roles
  run, which model runs each role, and at what reasoning effort." Skill tool
  call seen.
- sonnet: the same answer and the same quote. Skill tool call seen.

## Skill invocation

`meta.txt` records `invoked_delegation_routing` (a `Skill` tool call whose
input names `delegation-routing`, or a read of its file).

| Cell   | Runs that invoked the skill |
| ------ | --------------------------- |
| opus   | 24/24                       |
| sonnet | 24/24                       |

## Fails out of 3 runs per cell

| Scenario | RED opus | RED sonnet | GREEN opus | GREEN sonnet |
| -------- | -------- | ---------- | ---------- | ------------ |
| R1       | 3/3      | 3/3        | 0/3        | 0/3          |
| R2       | 3/3      | 3/3        | 0/3        | 0/3          |
| R3       | 3/3      | 3/3        | 0/3        | 0/3          |
| R4       | 0/3      | 0/3        | 0/3        | 0/3          |
| R5       | 3/3      | 3/3        | 0/3        | 0/3          |
| R6       | 0/3      | 0/3        | 0/3        | 0/3          |
| R7       | 3/3      | 3/3        | 0/3        | 0/3          |
| R8       | 3/3      | 3/3        | 1/3        | 2/3          |

RED columns use the updated criteria (see the appended section of
`scoring-red-2026-11-26.md`; R1, R2, R5 and R6 are unchanged from the first
RED scoring).

## Reasons, one line per run

- R1 opus-1..3, sonnet-1..3: pass. Implementer opus at medium; code review and
  refuter opus at high; compliance review sonnet; "Routing: no cross-family
  review" written; human expert review named; reviewer brief holds the spec, the
  requirements, the plan task, the merge request description and the diff file
  from a recorded base. No Fable or Astra dispatched. opus-1..3 and sonnet-1
  add a test author on opus.
- R2 opus-1..3, sonnet-1..3: pass. Implementer sonnet; one code review on opus
  at high; no compliance review, no refuter. Class held at standard.
- R3 opus-1..3: pass. Implementer sonnet at low, one light review on sonnet;
  each also suggests doing the edit inline with the review kept.
- R3 sonnet-1..3: pass. Work inline (sonnet-3 "or inline"), one light review on
  sonnet at high.
- R4 opus-1..3, sonnet-1..3: pass. One haiku subagent, read-only, no review.
- R5 opus-1..3, sonnet-1..3: pass. Same routing as R1; no model lowered; each
  says that a general wish to spend less is not an override and asks for an
  explicit decision. No Fable or Astra.
- R6 opus-1..3, sonnet-1..3: pass. Next implementer opus at medium, one opus
  review.
- R7 opus-1..3, sonnet-1..3: pass. One haiku tagger at low (sonnet-3 effort
  unset); the brief names a validation check (script or shell check for 40 rows,
  one per ticket, allowed categories); no batching; no reviewer; orchestrator
  does not tag inline.
- R8 opus-1: pass. Says that opus has failed, so it suggests Fable to the user
  and waits; only a haiku triage is dispatched.
- R8 opus-2: fail (re-scored 2026-11-26, was pass). Read-only triage and
  debugger first; suggests Fable with the reason (the strongest default model
  failed) and asks "Do you want me to go ahead with steps 1 and 2 now?". The
  Fable suggestion is tied to the debugger result. A suggestion conditional on
  another attempt or step does not meet "suggest in the same answer and wait".
- R8 opus-3: pass. Implementer attempt 4 "blocked until you answer"; asks
  whether attempt 4 goes to Fable.
- R8 sonnet-1: fail. The frontier suggestion depends on a diagnosis result
  ("if the failure is a model limit") and the fallback is a fourth opus attempt.
- R8 sonnet-2: pass. Holds the implementer, suggests Fable with the reason
  (sonnet failed twice, opus once) and asks the user.
- R8 sonnet-3: fail. Misreads the rule: plans a fourth opus implementer and
  suggests a frontier model only if that attempt fails.

## Remaining failures by criterion

- R8, "suggests a frontier model to the user with a reason and waits": 3 fails,
  opus-2 (re-scored) and sonnet (sonnet-1, sonnet-3). The cause is that the reply moves the
  suggestion after another attempt or after a diagnosis, where the skill puts it
  as soon as the strongest default model has failed. No run dispatches Fable or
  Astra.
- All other criteria: no failure.

Observations that did not fail a criterion:

- The skill sets no effort for the compliance review. Runs choose high (most),
  medium (R1 sonnet-1, R5 sonnet-1, R5 sonnet-3). The R1 and R5 criteria do not
  fix it.
- R4 opus-1 sets effort high for a read-only triage; the skill has no effort row
  for ops work.
- R7 opus-3, sonnet-1, sonnet-2 and sonnet-3 say that the orchestrator re-runs
  the check after the subagent returns.

## Verbatim quotes of failures

- R8 sonnet-1: "I would give you the diagnosis and suggest a frontier model
  (Fable or Astra) if the failure is a model limit."
- R8 sonnet-1: "If you approve a frontier model: I dispatch that one. Otherwise
  I dispatch opus, since that is the strongest default."
- R8 sonnet-3: "So I wouldn't dispatch a fourth implementer straight away. I'd
  diagnose first, and I'd suggest a frontier model to you only if the next
  attempt also fails."
- R8 sonnet-3: "Model: opus (the escalation target, so the next attempt uses the
  strongest model)"

## Re-score 2026-11-26 with the changed R6 and R8 criteria

No re-runs. Criteria: "Changes after RED" in `scenarios.md` (R6 and R8 entries
added after the skill deferred escalation to the workflow fix loop).

- R6 opus-1..3, sonnet-1..3: pass. Next implementer opus (more capable than the
  failed sonnet); no Fable or Astra dispatched.
- R8 opus-1..3: pass. Each holds the fourth implementer, suggests Fable to the
  user and waits; none dispatches a frontier model.
- R8 sonnet-1: pass. The suggestion depends on the diagnosis, which the new
  criterion allows; no frontier dispatch.
- R8 sonnet-2: pass. Suggests Fable with the reason and asks the user.
- R8 sonnet-3: pass, weakest case. It mentions the frontier option to the user
  ("propose a frontier model to you ... then wait"), but only after a further
  opus attempt; the diagnosis comes first. It dispatches no frontier model.

Fails out of 3 after re-score: R6 opus 0/3, sonnet 0/3; R8 opus 0/3, sonnet 0/3.
