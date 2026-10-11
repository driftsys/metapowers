# Durable references — issue 67, 2026-10-11

Battery and criteria: [durable-reference-scenarios.md](durable-reference-scenarios.md).
Verbatim outputs: [runs/issue-67/](runs/issue-67/).

## Placement

The cross-session invariant belongs in the existing lifecycle rule: capture useful
durable targets during development and keep lasting citations out of WIP. Its
additional instructions apply whenever design, implementation, or review creates
a reference; limiting them to gardening would leave the original failure intact.
The additional rule cost is about 19 wrapped lines × session turns × users;
for an illustrative 40-turn session that is 760 line-turns per user. This is a
cost estimate, not measured usage. Scanning, classification, refusal, and reports
stay in the existing gardener; the dispatch skill relays and resolves findings.
No new skill, agent, MCP tool, or general-purpose checker is introduced.

## Harness and provenance

Each decision sample used a fresh `fork_turns: none` subagent, the same
parent-inherited model and reasoning settings without overrides, and only the
three supplied item files plus the cases. The tool does not expose a resolved
model identifier, so these runs do not claim a pinned model version. Evaluators
did not receive the PASS criteria, project history, or this discussion. The
observer read every output and applied the previously written criteria.

RED used unchanged items from `21639c0`. GREEN used the first candidate.
Final samples used the review-refined candidate, which adds the test-literal
distinction and updates the rule's scope description. `upskill fmt` subsequently
changed only indentation in archive step 10, not its wording. These are
closed-book decision tests, not live skill-registry activation tests.

## Decision results

| Case                                                           | RED (5 samples) | GREEN (5 samples) | Final (3 samples) |
| -------------------------------------------------------------- | --------------- | ----------------- | ----------------- |
| D1: early accepted decision and durable code citation          | 0/5             | 5/5               | 3/3               |
| D2: early requirement/design with explicit status              | 0/5             | 5/5               | 3/3               |
| D3: no document for an obvious loop condition                  | 5/5             | 5/5               | 3/3               |
| D4: refuse lasting WIP citations before archive under pressure | 0/5             | 5/5               | 3/3               |
| D5: reconcile existing records and preserve valid references   | 5/5             | 5/5               | 3/3               |
| D6: surface an applicable failed path gate                     | 5/5             | 5/5               | 3/3               |
| D7: test literal versus actual fixture rationale               | not run         | not run           | 3/3               |
| D8: relative link under a project-specific WIP convention      | not run         | not run           | 3/3               |

D3, D5, and D6 are regression guards: baseline agents already handled these
decisions. D6's new explicit return field makes the failure report structural;
these runs do not establish that the old instructions concealed known failures.

## Observed failures and counters

| Case / pressure                             | Verbatim RED observation                                                                                                                            | Change                                                                                            |
| ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| D1, unimplemented accepted choice           | "Do not create the durable decision before implementation: shipped records describe as-built behavior, and gardening requires green tests." (red-2) | Capture accepted decisions early and state implementation status explicitly.                      |
| D2, correct shipped description             | "Leave the shipped `docs/specification/http-client.md` and `docs/design/http-client.md` unchanged." (red-4)                                         | Separate proposed content from shipped behavior in existing durable records.                      |
| D4, deadline + prior approval + sunk effort | "Archive only the pair using the established archive layout. The supplied instructions define no lasting-reference gate" (red-3)                    | Explicit pre-archive citation check and refusal, independent of path existence or prior approval. |

All five initial GREEN samples refused D4, listed all six lasting callers including
the directory citation, and preserved WIP and historical archive citations.
No new pressure rationalization was observed in those runs. Independent review
identified the possible false positive around test literals before deployment;
D7 was added to verify the distinction without exempting all fixtures. D8 adds
coverage for the existing project-convention seam and relative-link instruction.

## Filesystem execution

Fresh executors used only the supplied rule and gardener instructions in separate
disposable repositories seeded from the existing retry fixture. They ran the
actual tests and wrote records. The initial test invocation attempts did
not establish green tests; both executors then ran `python3 tests/test_retry.py`
and observed all four cases pass. Their outputs report those attempts honestly.

The RED executor archived both assigned files and left the source and fixture
citations unchanged. The GREEN executor reconciled records, then refused archival
and listed both remaining callers. The design's original WIP citation had already
been removed by its record reconciliation; this probe therefore demonstrates
blocking on the source and fixture, not preservation of all original matches.

The observer checked actual paths and compared protected bytes against the seed
commit. [observer-before-clean.json](runs/issue-67/observer-before-clean.json)
records the result: RED's pair was absent from WIP and its spec present in the
archive; GREEN's pair remained in WIP with no archived spec. Source, fixture,
historical archive, and held WIP were unchanged in both runs. The GREEN executor
ran `just doc-path-check` successfully, confirming that a passing existence gate
does not clear the semantic reference blocker.

After the dispatcher established the existing decision as the correct rationale
target, the two sandbox callers were updated explicitly for a clean continuation.
The separate continuation output and observer report record its archive and gate
results. This simulates reviewed caller resolution; the gardener does not perform
automatic pointer rewriting.

The clean continuation archived only the assigned pair with raw bytes preserved,
reused the single existing decision, retained both durable caller references, and
passed `just doc-path-check`. History and held WIP remained byte-for-byte
unchanged. [observer-clean.json](runs/issue-67/observer-clean.json) records those
checks. The gardener still reported the held WIP as unresolved and the branch as
unfinished; successful gardening does not authorize disposition of unrelated work.

## Limits

These tests exercise the lifecycle rule and gardener procedure together. They
do not independently measure live skill discovery, parent-to-subagent invocation,
all client runtimes, or a general path extractor. D7, D8, and failed-gate D6 are
decision tests; the executed sandbox uses the default layout and a narrow
existence check for one durable decision. The source registry's existing install
round-trip tests cover generation separately.
