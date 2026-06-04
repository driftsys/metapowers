# Tech note: working-memory lifecycle & gardening

**Status:** Draft — for tech-lead review
**Date:** 2026-06-02
**Authors:** (circulate for review)
**Scope:** A general lifecycle for turning AI-assisted-development working
artifacts into durable software design documentation (SDD). Superpowers is the
running example; the implementing rule and skill target Superpowers specifically.

> This is a proposal under review. It is **not** an accepted decision. Once the
> reviewers ratify (or amend) it, the durable parts should be promoted into an
> Architecture Decision Record (ADR) and the convention sections into the
> project's agent-instructions / contributing docs.

## 1. Problem & context

AI-assisted-development tools produce **specs** and **plans** as working memory
during a development session. [Superpowers](https://github.com/obra/superpowers)
— the running example throughout this note — generates a spec and an
implementation plan per feature. Such artifacts are conventionally treated as
disposable: written to gitignored local scratch, never entering version control.

That disposable model leaves two needs unmet:

1. **Collaborative human + AI work.** When a team (and its review agents)
   collaborate on a branch, the in-flight spec/plan is the shared coordination
   medium. A gitignored local file is invisible to teammates, reviewers, and CI
   agents. The disposable model implicitly assumes a single, solo, local session.

2. **Quality-process evidence.** Specs and plans carry the raw material of
   durable engineering records — architecture decisions (ADR), software design
   descriptions (SDD), and software requirements (SRS): design rationale,
   decisions, detailed design. Quality processes (e.g. ASPICE, ISO 26262) require
   traceable, browsable design records. Discarding the raw artifact loses the
   rationale that feeds those records.

The constraint this lifecycle must **not** violate: working artifacts must never
become a shadow source of truth. The guiding principle is
_"Tests are the spec. Code is the implementation. Documentation describes
both."_ Code + tests are authoritative; documentation describes, it does not
drive.

## 2. Decision (proposed)

Track working memory on the feature branch so collaborators and agents can see
it; **garden** it at feature completion — reformatting the spec/plan into durable,
curated `docs/` records — while **moving the raw artifacts, as-is, to an
archive**; and enforce, via CI, that no ungardened working memory reaches `main`.

Gardening is a **transform-and-route** operation, not a rewrite into foreign
templates: it keeps the existing documents close to their Superpowers form,
filters out the ephemeral, decorates the durable so its nature (requirement /
decision / architecture / design) is obvious, and reconciles lightly against the
merged code.

### 2.1 Mode-adaptive (per-project override)

Each project chooses how working memory is treated **simply by whether it
gitignores `wip/superpowers/`** — the gitignore entry _is_ the switch; no config
flag is required.

- **Collaborative mode — `wip/` tracked (default).** Specs/plans are committed on
  the feature branch and visible to teammates and review agents. Gardening
  archives the raw and the WIP-gate (§5) is enforced.
- **Private mode — `wip/` gitignored (override).** Specs/plans are local-only
  working memory (the stock Superpowers behaviour). Gardening still produces the
  durable `docs/` records, but there is nothing tracked to archive and the
  WIP-gate is a no-op. The tradeoff: no shared visibility, and no git-based
  recovery of the raw.

Gardening detects the active mode with `git check-ignore`.

## 3. Layout

```text
wip/superpowers/          # active, not-yet-gardened working memory
├── specs/                #   (tracked on the branch, or gitignored = private)
└── plans/

archive/superpowers/      # raw spec/plan, as-is, moved here on gardening
├── specs/
└── plans/

docs/
├── spec/<feature>.md      # requirements + feature architecture  → what & where
├── decisions/<topic>.md   # ADRs, AD-NNNN ids                    → why
└── design/<feature>.md    # detailed design (SDD)                → how
```

**The durable triad.** Gardening routes a feature's working memory into three
record types:

| Record                   | Source               | Answers      | Standard        |
| ------------------------ | -------------------- | ------------ | --------------- |
| `docs/spec/<feature>`    | the spec             | what & where | EARS / markspec |
| `docs/decisions/<topic>` | the spec's decisions | why          | MADR-inspired   |
| `docs/design/<feature>`  | the plan (de-tasked) | how          | arc42-inspired  |

**Core invariant:** a non-empty `wip/superpowers/` on a branch targeting `main`
means "this branch has ungardened work in progress."

## 4. Lifecycle mechanism

Working memory is committed to `wip/` on the feature branch (visible in the MR).
At feature completion, gardening produces the durable records in `docs/`, moves
the raw spec/plan to `archive/`, and empties `wip/`.

```text
main:  A ───────────────────────────────────────────── M   ← merge
            \                                           /
feat/x:      C1 ── … ── Cg ───────────────────────────╯
             │          │
   spec+plan ┘          └─ gardening commit:
   in wip/                 + docs/spec/x.md         (requirements + feature arch)
   (visible in MR)         + docs/decisions/<topic>.md (decisions, AD-NNNN)
                           + docs/design/x.md       (detailed design, de-tasked)
                           git mv wip/specs|plans → archive/  (raw, as-is)
                           wip/ now empty → WIP-gate green
```

The durable records **persist in `docs/`** regardless of merge strategy
(merge-commit, rebase, or squash) — they are never deleted, so nothing valuable
is lost under any policy. The raw, as-is artifacts live in `archive/`; their
pre-gardening edit history lives in git.

## 5. WIP-gate (CI review gate)

**Collaborative mode only.** In private mode `wip/` is gitignored, so
`git ls-files wip/` is always empty and the gate is a no-op.

CI fails a `main`-targeting branch when `wip/superpowers/` is non-empty:

```bash
# illustrative — fails if any active working memory remains ungardened
test -z "$(git ls-files wip/superpowers/)" \
  || { echo "Ungardened WIP present in wip/superpowers/ — run gardening."; exit 1; }
```

- **Green = gardened.** Gardening is the act that empties `wip/`.
- **Escape hatch.** Merging with WIP is permitted only by an explicit, logged
  override (mechanism is an open question — see §11), so the gate is a gate, not
  a wall.

The gate does **not** run gardening — it only enforces that gardening happened.
Gardening is triggered as a wrap-up step (§6).

## 6. Gardening: the operation

**Trigger.** Gardening is an **invokable skill**, and the lifecycle rule wires it
into branch wrap-up ("finishing a branch includes running gardening before
merge"). The WIP-gate is the backstop if it is forgotten.

It runs **once, before the PR lands** — after green tests — because that is the
only point where as-built is known. Deliberately **not** at Superpowers'
spec-review or plan-acceptance checkpoints: those are pre-implementation, so
gardening there would capture as-planned content and need re-gardening anyway
(decisions can reverse during implementation). The early-visibility those
checkpoints would buy is already provided by branch-tracking (§2.1). A future
enhancement could stage provisional drafts at the checkpoints and reconcile them
before PR — deferred (YAGNI).

**As-built, lightly (load-bearing).** Because code + tests are authoritative, the
records must describe what was **built**, not what was planned. But in
collaborative mode the spec/plan were tracked and updated on the branch as the
work proceeded, so they are already close to as-built. Gardening therefore does a
**light reconciliation**: skim each record against the merged code + tests, fix
obvious divergences, and **flag** uncertain ones for human confirmation — not a
rebuild.

**The flow:**

```text
1. Triage      Per topic: is this new, or does it touch existing records?
2. Route       spec → requirements+arch (docs/spec) and decisions (docs/decisions);
               plan → detailed design (docs/design).
3. Filter      Drop the ephemeral: TDD task ceremony, step-by-step plan
               mechanics, code snippets (point to code), verbatim requirements.
4. Decorate    Format so each part's nature is obvious; stamp stable AD-NNNN ids
               on decisions; keep close to the Superpowers prose and order.
5. Reconcile   Light review vs. merged code + tests; flag divergences.
6. Rewrite     Edit superseded pieces in place (§8); never deprecate-and-replace.
7. Archive     git mv raw spec/plan to archive/; empty wip/ → gate green.
```

### 6.0 Execution — delegated to the `sdd-gardener` subagent

Gardening is context-heavy (it reads the spec/plan, the merged code + tests, and
the existing `docs/` triad), so the `sdd-gardening` skill (SKILL.md) **dispatches
its co-located `sdd-gardener` subagent (AGENT.md)** rather than running inline —
keeping the main session's context lean.

- **Inputs handed to the subagent:** the `wip/` spec + plan; pointers to the
  merged code + tests; the existing `docs/` triad (for the consistency engine);
  and — **only when the current session still holds it** — the brainstorming
  discussion (which carries the considered-options/rationale directly). When
  gardening runs in a later/separate session, the subagent works from the durable
  artifacts; the cross-session gap is covered by capture-at-source (§10), never by
  transcript mining.
- **Return contract — a summary with references, never raw content:** records
  created/edited (paths + `AD-NNNN` ids), divergences flagged during
  reconciliation, and open offers needing a human (create a requirement? update
  system architecture?). The main session keeps the summary and `Read`s the actual
  files only when needed.
- **Scope:** one `sdd-gardener` subagent per feature — the route → reconcile → rewrite chain
  shares state on the records, so splitting risks incoherent edits. Parallel
  gardening across many features is a future scale option, not now.

### 6.1 Format precedence (format-tool-agnostic — defaults, not mandates)

The skillset never hard-depends on an **output tool** (markspec, adr-tools, …).
Format is chosen per record type:

- **`spec/` and `design/`** — these derive from a Superpowers source document. If
  a project tool enforces a format (e.g. a markspec entry type for requirements),
  conform; otherwise **mirror the Superpowers source** — stay close to its prose
  voice and chapter order, minimal transformation.
- **`decisions/`** — decisions have **no Superpowers source shape** (Superpowers
  emits no ADR). If a tool enforces one (adr-tools / markspec), conform; otherwise
  use the **§7 record template** (MADR-minimal) as the default shape.

A more specific project rule always wins (instruction priority:
_user/project rules > skills_). There is no "no-framework fallback" — the source
is always a Superpowers spec/plan (see the scope note in §11).

What never yields is the **content contract**: the required substance
(requirements, considered options, decision, consequences; interfaces,
relationships, verification) and the trace links (`Satisfies:`, ids) must be
present regardless of which format carries them. Only the layout defers.

### 6.2 Requirements (EARS default, markspec-agnostic)

Requirements in `docs/spec/<feature>.md` are written in **standard EARS** by
default (ubiquitous / event-driven / state-driven / optional / unwanted). If
markspec is installed and instructs, gardening defers to it (markspec entries,
stamped ids, `fmt`/`check`). The skill must work with **or without** markspec.

When a decision or design traces to **no** existing requirement, gardening
surfaces the gap and **offers** to record one — it never auto-generates silently,
and never hand-writes or forges an id.

### 6.3 Decisions (records, AD-NNNN, edit-in-place)

Decisions are split into `docs/decisions/<topic>.md` — standalone records, because
decisions are the most cross-referenced, longest-lived, cross-feature artifact a
feature produces; a feature's spec is the wrong container for something that
spans features. Each decision is a decorated section with a globally-unique,
greppable `AD-NNNN` id, so requirements and tests can reference a specific
decision. A topic file may hold one or more decisions. See §7 for the template.

## 7. Output contract — minimal, git-backed templates

Minimal, git-backed, standards-aligned. Metadata git already holds (author, date,
status-history, version) is **omitted**; only the non-git-derivable trace footer
stays. Grounded in MADR 4.0 (all metadata optional; spine = context → options →
outcome), arc42 (all sections optional; black-box-before-white-box progressive
discovery), and EARS for requirement phrasing. The record template is the
**default shape for decisions** (which have no Superpowers source); for `spec`/
`design` these serve as a **content checklist**, not a reformatting target (§6.1).

**Decision record** — `docs/decisions/<topic-slug>.md` (one or more per file):

```markdown
# <topic — e.g. IPC transport>

## [AD-0007] Use gRPC for inter-process communication

**Context.** <2–3 sentences: the forces and problem.>

**Options.** gRPC; raw sockets + custom protocol; D-Bus.

**Decision.** Chose **gRPC**, because <deciding reasons — as actually built>.

**Consequences.** Good — <easier>. Bad — <cost / harder>.

Satisfies: REQ-0042 · Related: [AD-0003](#ad-0003)
```

`AD-NNNN` is globally unique (gardening scans existing ids and increments).
Compact bold labels keep multiple decisions scannable; the `## [AD-NNNN] Title`
heading is the navigable anchor. "Options" is optional — omit when none were
recorded rather than fabricating alternatives.

**Spec** — `docs/spec/<feature>.md`:

```markdown
# <feature>

## Purpose & scope

<1 paragraph.>

## Requirements

<EARS requirements (or markspec entries when installed).>

## Architecture (feature)

<The feature's own components, boundaries, and where it sits relative to other
components. System-wide architecture is out of scope — see §9.>

## Decisions

<Links to the relevant docs/decisions/ AD-NNNN, not restated here.>

---

Satisfies / trace footer as applicable.
```

**Design (SDD)** — `docs/design/<feature>.md` (from the de-tasked plan):

```markdown
# <feature / component name>

## Building blocks

<Components this feature adds/changes — black-box first: name + responsibility.>

## Interfaces

<Provided/required contracts: signatures, message schemas, API/IPC surface.>

## Relationships & runtime

<Dependencies and the key interaction or data flow. Sequence sketch if non-trivial.>

## Design concepts

<Module architecture, bounded context(s), DDD strategy/tactics, cross-cutting
patterns, error handling. Link decisions (records) — do not restate.>

## Verification

<Link to the tests that exercise this.>

---

Satisfies: REQ-0042 · Decisions: [AD-0007](../decisions/ipc-transport.md#ad-0007) · Code: `src/...`
```

**Audit note.** ASPICE auditors sometimes want a visible change record. Default
stays git-backed (minimal); a project that needs it may add an optional in-doc
changelog, kept out of the default template.

## 8. Consistency: edit in place, do not deprecate

Gardening maintains **living records**. When a new spec changes a
previously-recorded decision or design, gardening **edits the existing record** so
it stays consistent with current reality — it does **not** mark the old one
deprecated and create a superseding one. A new file/record is created only for a
genuinely new topic. This is a deliberate departure from immutable-MADR
supersession, consistent with the guiding principle (§1): documentation describes
the current system. Decision history is preserved by the record's git history and
the raw in `archive/`; editing in place also keeps cross-references stable.

**The consistency engine (the hard part).** To edit the right record, gardening
must first **locate** it, then decide **edit vs. new**:

1. **Trace links (the spine, deterministic).** An existing `REQ-NNNN`/`AD-NNNN`
   the spec references, or the feature/topic slug, points directly at the file.
2. **Topic / feature-slug match.** Same feature → same `spec`/`design`; a
   decision's topic → candidate `decisions/` file.
3. **Search safety-net.** Where a link nails it, edit in place; where it is
   ambiguous or looks new, **propose candidates and let the human confirm**
   edit-vs-new. Never silently create a duplicate or silently overwrite.

## 9. System architecture boundary

Gardening is feature-scoped, so `docs/spec/<feature>.md` carries the **feature's
own architecture** (its components, boundaries, interfaces). **System
architecture** (ASPICE SWE.2) — the holistic, cross-feature view — stays
**human-curated** and is never auto-edited. Gardening **links** to the relevant
system-architecture doc, and when none exists for the area, **offers to create**
one (human-reviewed). The spec/decisions/design trail is the raw material from which
system architecture is composed.

## 10. Recovery & continuity

In collaborative mode, a new session has full prior context trivially: the
durable records in `docs/` (distilled, current) plus the raw in `archive/`
(as-is). The records' git history holds the edit-by-edit evolution as a bonus —
not load-bearing. In private mode only the `docs/` records persist; the raw is
local and not recoverable cross-session.

**Capturing alternatives at the source.** Considered options are the richest
decision rationale, but the Superpowers spec often omits them (they live in the
brainstorming dialogue). Rather than mine ephemeral transcripts (rejected as too
complex — §13), the lifecycle rule nudges spec authoring to **record an
"Alternatives considered" section + trace links** when the spec is written, so
the durable artifact carries them. If they are still absent, gardening records
"alternatives not documented" — never fabricates.

## 11. Packaging

Three installable items plus a CI script, all targeting Superpowers specifically:

- **`working-memory-lifecycle` (RULE.md)** — the always-on guardrails: where
  working memory lives, the mode switch, the WIP-invariant, edit-in-place living
  records, the durable triad, the trigger wiring (finishing a branch runs
  gardening), and a one-line clause requiring specs to record considered
  alternatives + trace links. Ships the WIP-gate CI script as a resource.
- **`sdd-gardening` (SKILL.md)** — the on-demand procedure (§6): it **dispatches
  the co-located `sdd-gardener` subagent (AGENT.md)** (§6.0) and surfaces its
  summary to the user. The operation is referred to as "gardening" throughout
  this note.
- **`sdd-gardener` (AGENT.md)** — the subagent that does the work: triage → route →
  filter → decorate → reconcile → rewrite → archive, with the consistency engine
  (§8), format precedence (§6.1), and system-architecture boundary (§9) inside it.
  Fixed return contract (§6.0): a summary with references, never raw content.

**Scope & seam.** Both items target **Superpowers** specifically — consistent with
metapowers' charter and philosophy #5 (metapowers is explicitly _not_ spec-kit /
BMAD). Only **step 1 — reading the source working memory** — is framework-specific;
everything downstream (route → filter → decorate → reconcile → record format, the
consistency engine, the format-tool-agnostic output) is framework-neutral. The
neutral name `sdd-gardening` leaves room to support another source framework later
by swapping the source-reading step — not by rewriting the skill. We are **not**
building that abstraction now (YAGNI).

### Open questions for review

1. **WIP-gate override mechanism.** CI label vs. a committed marker file vs. a
   documented exception process.
2. **Reconciliation with Superpowers' hardcoded paths.** Superpowers writes to
   `.scratch/superpowers/…`; its `brainstorming` skill writes design docs to
   `docs/superpowers/specs/`. We do not edit the upstream plugin. How does the
   rule redirect authoring into `wip/superpowers/`? (rule instruction vs.
   gitignore/convention adjustment.)
3. **Default mode.** Collaborative (tracked) with private as opt-out, or the
   reverse? Current lean: collaborative, since it is the motivating need.

## 12. What survives from earlier drafts

These were settled and remain: tracking working memory on the branch; the
add-then-keep mechanism (durable records persist, never deleted); the WIP-gate;
mode-adaptive via gitignore; edit-in-place living records; minimal git-backed
templates; tool-agnostic defaults.

## 13. Rejected alternatives

- **Keep specs gitignored + copy durable content out.** Defeats collaboration and
  loses the raw rationale entirely. Rejected (private mode remains available as an
  explicit per-project choice).
- **Add-then-delete (prune the raw, recover only from history).** Required a
  no-squash merge policy and made recovery depend on fragile git archaeology.
  Rejected in favour of keeping the raw in `archive/`.
- **Fan-out into separate per-decision ADR files _and_ separate SDD files.**
  Considered, then simplified: decisions are split into `decisions/` (because they
  are cross-cutting), but requirements + feature architecture stay together in one
  `spec/` document and design stays in one `design/` document — rather than
  shattering each feature across many files.
- **Transcript recovery of considered options.** Mining the brainstorming
  transcript to recover alternatives — rejected as too complex (session
  identification, client-specific formats, fragile). Replaced by capturing
  alternatives at the source (§10) with an honest-gap floor.
- **Permanently tracked specs mingled with `docs/`.** Reintroduces shadow-SSOT
  drift. Rejected; gardening transforms working memory into curated records and
  archives the raw.
- **Source-framework-agnostic skillset (ingest spec-kit / BMAD / etc.).**
  Considered, deferred. Off-charter (philosophy #5 rejects spec-kit/BMAD) and
  speculative (YAGNI). Mitigated by isolating the source-reading step as a clean
  seam (§11) so generalization later is a swap, not a rewrite. Note: format-tool
  agnosticism (markspec/adr-tools/EARS) is _kept_ — that is a different axis.
