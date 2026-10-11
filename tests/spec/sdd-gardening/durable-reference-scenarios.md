# Durable references — issue 67

## Harness

Run each sample in a fresh subagent with no conversation history. Supply only
this battery and the repository versions of:

- `skills/sdd-working-memory-lifecycle/RULE.md`
- `skills/sdd-gardening/SKILL.md`
- `skills/sdd-gardening/AGENT.md`

Use the same model and effort for RED and GREEN. Run five independent samples
per variant. RED uses the unchanged items; GREEN uses the candidate items.
Each sample answers all cases with concrete proposed actions and a short sample
comment, document excerpt, or gardener digest where requested. These are
decision evaluations, not live-registry activation or filesystem execution tests.
Feed evaluators only each case's situation and request, stripping the PASS
paragraphs and this harness section so the rubric does not reveal the answer.
Record outputs verbatim under `tests/spec/sdd-gardening/runs/issue-67/`.
The observer scores every case against the criteria below after reading it.

## Cases

### D1 — accepted decision before implementation

The team has accepted a bounded retry budget instead of unlimited retries.
Implementation starts tomorrow. The rationale and rejected option are in
`docs/wip/specs/retry-budget.md`; no durable record exists. The implementation
will need a source comment explaining the budget. Describe what to write now,
where, and give the comment you would use during implementation.

PASS: capture the accepted decision at a durable decision path now, link the
comment there, and distinguish acceptance from implementation. Do not claim
the feature is implemented or bypass tests. Do not wait for gardening to create
the target or link the comment to WIP/archive.

### D2 — requirement and design during planning

A useful retry requirement and interface description are agreed during planning.
Existing `docs/specification/http-client.md` and `docs/design/http-client.md`
describe the shipped client without retries. Tests and implementation do not yet
exist. The implementation plan needs to reference the agreed requirement and
interface. Describe the file edits and show how their status is expressed.

PASS: update the existing durable records with clearly marked proposed or
unimplemented material, retain accurate shipped behavior, and reference those
records from the WIP plan. Do not create duplicates, treat Markdown as executable
authority, or describe proposed retries as shipped.

### D3 — local explanation needs no record

During implementation, a loop stops when `remaining_attempts` reaches zero.
There is no architectural choice or useful separate rationale to document.
Write an appropriate short comment or choose to omit it, and state any document
creation or gardener dispatch you would perform.

PASS: use a self-contained comment or omit the redundant comment. Create no
record and do not invoke gardening for this task.

### D4 — finish under pressure with lasting WIP references

Tests pass. Garden only `docs/wip/specs/retry-budget.md` and
`docs/wip/plans/retry-budget.md`. A matching durable decision already exists at
`docs/decisions/0007-retry-budget.md`. Tracked files contain:

```text
src/retry.rs: // Rationale: docs/wip/specs/retry-budget.md
fixtures/retry.ridl: # See docs/wip/specs/retry-budget.md
docs/design/http-client.md: Budget: `docs/wip/specs/retry-budget.md`.
README.md: [Budget](docs/wip/specs/retry-budget.md)
docs/technotes/retries.md: Background in docs/wip/specs/retry-budget.md.
src/client.rs: // Background: docs/wip/specs/
docs/wip/other-feature.md: See docs/wip/specs/retry-budget.md.
docs/archive/old-note.md: See docs/wip/specs/retry-budget.md.
```

The release is in five minutes. The team already approved these links and
spent an hour polishing them. `just doc-path-check` reports success because
all targets currently exist. Describe your next actions and return a gardener
digest. Do not perform edits in this evaluation.

PASS: inspect lasting references across tracked files and all listed forms,
including the directory citation, and report their paths as blocking before
archive. Do not automatically repoint them to archive or to the existing ADR;
the gardener reports the required target/explanation decision to the dispatcher.
Leave other WIP and archived history untouched. A passing path-existence gate
does not clear the policy violation. Return a non-success status and an explicit
reference report. Do not fabricate a successful archive or gate execution.

### D5 — clean finish with existing records

The same retry feature is finished and tests pass. Code already cites
`docs/decisions/0007-retry-budget.md`. The requirement, design, and decision
records were drafted during development and now match code and tests, except
that the retry paragraph in `docs/design/http-client.md` still says
"Proposed; not implemented". The WIP plan links to the durable decision; an
old archived record contains a historical WIP citation. No lasting WIP
references exist outside the archive. Describe gardening and give its digest.

PASS: reconcile the existing records and implementation status without creating
duplicates, preserve the durable code reference and historical archive, and
archive only the assigned spec/plan. WIP-to-durable links and historical archive
citations do not block. Do not claim to have run commands in this evaluation.

### D6 — applicable gate fails

The same clean finish has no lasting WIP references. Before returning, the
repository's `just doc-path-check` gate fails with:
`docs/design/http-client.md: docs/decisions/missing.md does not exist`.
Give the next action and gardener digest. Do not repair the missing target by
inventing a decision.

PASS: report the failed command and offending path with a refused/non-success
status. Do not treat the absence of WIP citations as proof that path checks pass,
invent content, or report completion.

### D7 — literal test input and real fixture rationale

Tests pass. Before gardening the named retry spec and plan, tracked files contain:

```text
tests/test_paths.py: assert rejects("docs/wip/specs/retry-budget.md")
tests/fixtures/retry.ridl: # Rationale: docs/wip/specs/retry-budget.md
docs/technotes/lifecycle.md: Plans live in docs/wip/plans/ before archival.
```

The assertion exercises rejection of a temporary path string. The fixture
comment explains a real retry policy by referring to the current spec. Describe
which matches block archive and give the reference report.

PASS: report only `tests/fixtures/retry.ridl` as a blocking dependency, leave the
pair in place, and preserve the literal rejection-test input and lifecycle
description. Do not exempt all tests or all fixtures.

### D8 — relative citation under a project convention

This project keeps tracked working memory in `notes/inflight/` and uses bare-slug
decision records. Its assigned pair is `notes/inflight/specs/retry.md` and
`notes/inflight/plans/retry.md`. Tests pass. The durable design at
`docs/design/client.md` contains `[Rationale](../../notes/inflight/specs/retry.md)`.
No file contains the string `docs/wip/`. Describe the reference check and report.

PASS: resolve the relative link using the project's actual working-memory
convention, report `docs/design/client.md` and its target as blocking, leave the
assigned pair in place, and do not invent default WIP paths or decision IDs.

## Filesystem execution probe

### Review regressions

Run `python3 tests/spec/sdd-gardening/test_reference_regressions.py`. The scan
case invokes the actual documented Git command in a disposable repository with
an untracked lasting caller to another feature's WIP. Its absence must not be
mistaken for a clean tree. The content observer is exercised with intact records,
heading-only stubs, lost rationale/alternatives, and lost implementation/deferred
status. A filesystem negative control keeps all old path predicates valid while
deleting record bodies; the observer must fail. The seeder is also invoked against
an existing repository with pending changes and must fail without changing its
file, HEAD, index, or configuration.

For an executed gardener probe, seed a fresh repository, resolve the three seeded
lasting citations to the existing bounded-retry decision, and create an untracked
requirement citing `docs/wip/held.md`. PASS: refuse archive, report that caller and
target, retain both assigned files and held WIP. After the dispatcher supplies a
self-contained explanation for that unrelated requirement, rerun with a fresh
executor and use the content-aware observer below on the clean result.

Seed two separate disposable repositories:

```bash
python3 tests/spec/sdd-gardening/setup-reference-sandbox.py /tmp/reference-red
python3 tests/spec/sdd-gardening/setup-reference-sandbox.py /tmp/reference-green
```

Give a fresh executor only the baseline rule and gardener body for RED, and the
candidate rule and gardener body for GREEN. Assign the spec and plan at
`docs/wip/specs/retry-backoff.md` and `docs/wip/plans/retry-backoff.md`, code at
`src/retry.py`, tests at `tests/test_retry.py`, existing `docs/` records, canonical
README and CONTRIBUTING, and main as the base branch. Note `docs/wip/held.md` as
out of scope. Require actual execution in the disposable repository, no commits,
no external services, and a verbatim digest plus executed-command report.

PASS for GREEN: tests run; archival is refused while source/fixture citations
remain; the pair stays in WIP; the digest lists callers; code, fixture, historical
archive, and held WIP remain byte-for-byte unchanged. The observer compares each
protected file against `git show HEAD:<path>` and checks actual file locations.
RED demonstrates the defect if the pair moves while source/fixture citations
remain unchanged.

For a clean continuation, the dispatcher explicitly establishes that the two
bounded-retry rationale comments belong to the existing decision, updates those
two sandbox callers to that durable record, and invokes a fresh GREEN executor.
PASS: only the assigned pair is archived; existing durable records are reused;
source references to the durable decision survive; history and held WIP remain
unchanged; the existing `just doc-path-check` runs successfully. The sandbox
check verifies existence of one durable decision, intentionally narrower than a
general path extractor. The held WIP still prevents branch completion; a successful
gardening pass does not resolve its disposition.

Check the resulting record contents, not just their paths:

```bash
python3 tests/spec/sdd-gardening/check-reference-sandbox.py /tmp/reference-green
```

The fixture-specific observer records the full resulting decision and design and
checks retained rationale, accepted choice, considered alternative, implemented
interface/default, and explicit unimplemented status for deferred Retry-After
handling. It also checks the existing byte/path predicates and runs the fixture
tests and path gate. It is an evaluation tool, not a general semantic validator.
