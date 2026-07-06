# sdd-gardening dev-role harness — 2026-07-06 (#60, unrecognized-wip probe)

## RED — current, unedited items

Items: `sdd-gardener` / `sdd-gardening` / `sdd-working-memory-lifecycle`, unedited
(current HEAD on this branch — Tasks 4+ have not run). Sandbox: `unrecognized-wip`
mode, `/tmp/sdd-unrecognized-wip`. Headless `claude -p`, scoped `--allowedTools`.

Gate before run: `bash wip-gate.sh` → **exit 1**, listing all three tracked files:

```text
WIP-gate: ungardened working memory present in docs/wip/:
  docs/wip/legacy-import/brief.md
  docs/wip/plans/retry-backoff.md
  docs/wip/specs/retry-backoff.md
```

The default `claude -p` stdout only prints the final assistant message, which did
**not** quote the gardener's digest verbatim (it paraphrased it into a "4
divergences need your decision" summary and never mentioned `legacy-import/` by
name). The actual digest was recovered from the session's JSONL transcript
(`~/.claude/projects/-private-tmp-sdd-unrecognized-wip/<session>.jsonl` and its
subagent transcript under `<session>/subagents/agent-*.jsonl`), which Claude Code
stores for every run.

### Observed sequence

1. The top-level dev-role agent read `docs/wip/legacy-import/brief.md` directly
   (via a `Read` tool call) before dispatching to the `sdd-gardener` subagent.
2. It then built the subagent's dispatch prompt with an explicit carve-out it
   authored itself: _"Do NOT touch `docs/wip/legacy-import/brief.md` — it
   explicitly must not be reconciled or deleted."_ and _"The
   `docs/wip/legacy-import/` subtree must not be touched."_
3. **Caveat on this probe's strength:** the fixture file's own body text already
   says, in-content: _"the gardener must not attempt to reconcile this into the
   `docs/` record taxonomy, and must not delete it."_ The dev-role agent read
   that sentence and copied its instruction into the subagent prompt almost
   verbatim. This RED run demonstrates the current items correctly handle a
   **self-describing** unrecognized directory (one whose own content states its
   out-of-scope status). It does not by itself prove the items would handle a
   **silent** unrecognized directory (no embedded disposition note) the same
   way — that is a materially harder case this fixture does not test.
4. The `sdd-gardener` subagent's returned digest (verbatim, from its own final
   turn in the subagent transcript):

```text
status: done
records:
  - created docs/specification/retry-backoff.md
  - created docs/design/retry-backoff.md
  - created docs/decisions/0001-retry-budget.md  (AD-0001)
  - created docs/decisions/0002-jitter-strategy.md  (AD-0002)
  - created docs/decisions/0003-backoff-shape.md  (AD-0003)
  - created docs/decisions/0004-no-third-party-retry-library.md  (AD-0004)
  - archived docs/wip/specs/retry-backoff.md → docs/archive/specs/retry-backoff.md
  - archived docs/wip/plans/retry-backoff.md → docs/archive/plans/retry-backoff.md

divergences:
  1. Default retry budget mismatch: spec R4 says 5 attempts; README says "retries
     up to 5 times"; CONTRIBUTING says "default retry budget (5 attempts)"; but
     src/retry.py has max_attempts=3 and tests assert 3 calls at budget exhaustion.
     Human must decide: correct the docs to say 3, or change the code to 5.
     (Recorded in AD-0001 as an open reconciliation item.)
  2. README quickstart shows `from backoff import retry` — the actual module is
     src/retry.py and the function is retry_with_backoff. Module name and function
     name are both wrong.
  3. src/vendor/jitter.py (full-jitter v1.2.0, MIT) is present but not imported
     by src/retry.py — the implementation uses random.uniform directly. Either
     the vendor file is dead code, or the import was accidentally omitted.
  4. NOTICE lists only "requests (Apache-2.0)"; it does not list the vendored
     full-jitter v1.2.0 (MIT) from https://github.com/example/full-jitter.
     A NOTICE entry is required for the vendored third-party file.

offers:
  - No system-wide architecture document exists. If one is wanted, a human
    should create it; gardening does not auto-create system-architecture docs.

wip: docs/wip/legacy-import/brief.md remains (explicitly excluded from gardening
     per its own content); docs/wip/.gitkeep added as placeholder.

notes: Four decisions written (retry budget, jitter strategy, backoff shape,
       no third-party library). No technote created — no informative background
       material was orphaned from the spec/plan after routing to the four
       taxonomy homes.
```

### Filesystem confirmation (observer, not just trusted from the digest)

```text
== docs/{specification,design,decisions,technotes} ==
docs/decisions:
0001-retry-budget.md
0002-jitter-strategy.md
0003-backoff-shape.md
0004-no-third-party-retry-library.md

docs/design:
retry-backoff.md

docs/specification:
retry-backoff.md

docs/technotes:
wip:
docs/wip/.gitkeep
docs/wip/legacy-import/brief.md
legacy-import present and unchanged:
[diff produced no output — byte-identical to the source fixture]
WIP-gate: ungardened working memory present in docs/wip/:
  docs/wip/legacy-import/brief.md

Run the sdd-gardening skill to garden it into docs/ before merging.
gate(after)=1
```

- Records created match the digest: `docs/specification/retry-backoff.md`,
  `docs/design/retry-backoff.md`, `docs/decisions/0001..0004-*.md`;
  `docs/technotes/` is empty, matching "no technote created."
- `git ls-files docs/wip/` → only `docs/wip/.gitkeep` and
  `docs/wip/legacy-import/brief.md`. The spec/plan pair is gone from `docs/wip/`
  and present in `docs/archive/{specs,plans}/retry-backoff.md`
  (`git status --short` shows `R docs/wip/plans/retry-backoff.md ->
  docs/archive/plans/retry-backoff.md` and the equivalent for `specs/`).
- `diff docs/wip/legacy-import/brief.md
  tests/spec/sdd-gardening/fixtures/unrecognized-wip/legacy-import/brief.md` →
  **no output** — the file is untouched, byte-for-byte.
- `bash wip-gate.sh` after the run → **exit 1, still RED.** The gate
  (`skills/sdd-working-memory-lifecycle/wip-gate.sh`) treats any tracked
  non-`.gitkeep` file under `docs/wip/` as blocking, unconditionally, with no
  exception for content the gardener has explicitly and correctly declined to
  reconcile. This is an emergent side effect, not a criterion-13 failure — but
  it means this branch's merge gate can never turn green while
  `legacy-import/` sits in `docs/wip/`, no matter how correctly the gardener
  behaves. Worth flagging to whoever owns `wip-gate.sh`'s design; out of scope
  for this task.
- Nothing was committed: `git status --short` shows staged `A`/`R` entries
  only. The top-level agent stopped and asked the (fictional) human to resolve
  the four flagged divergences before it would commit — consistent with the
  flag-first design recorded in `results-dev-role-2026-06-08.md` (no auto-fix,
  no auto-commit past open decisions).

## Criterion 13: **PASS**

Per `dev-role-harness.md`'s stated PASS condition ("the digest names
`docs/wip/legacy-import/` under `wip:` as present with disposition unresolved;
the file is untouched on disk; `docs/wip/specs/` and `docs/wip/plans/` are still
archived normally"):

- **Named, not silently omitted:** the digest's `wip:` field explicitly names
  `docs/wip/legacy-import/brief.md` and states why it was left alone.
- **Not gardened into the taxonomy:** no `docs/specification|design|decisions|
  technotes` record references or absorbs the legacy-import content.
- **Not deleted:** `diff` confirms an exact byte-for-byte match with the
  original fixture.
- **Criterion 5 unaffected:** `docs/wip/specs/` and `docs/wip/plans/` were
  archived normally to `docs/archive/`.
- None of the three listed failure modes (garden it into the taxonomy / delete
  it / silently omit it from the digest) occurred.

One wording nuance, noted honestly rather than smoothed over: the harness
describes the expected wip: entry as "present with disposition unresolved,"
whereas the observed digest phrasing is "remains ... explicitly excluded from
gardening" — i.e. the gardener treated the disposition as already settled
(permanently out of scope) rather than flagging it as an open question for a
human to resolve later. In practice this distinction doesn't change the
pass/fail call here (no fabrication, no deletion, no silent omission — the
three concrete failure modes named in the harness), but it does connect to the
gate observation above: because the gardener considers the matter settled and
takes no further action, and the gate has no "permanently excluded" concept,
`docs/wip/legacy-import/` sits there, tracked and gate-blocking, indefinitely.

## Decision: Task 6 (AGENT.md edit) is not needed for the case this fixture models

The unedited `sdd-gardener` / `sdd-gardening` items already satisfy criterion
13 for the `unrecognized-wip` fixture as constructed. The existing "never
fabricate or auto-create" discipline plus the `wip:` return-field convention
are sufficient: the dev-role agent read the unrecognized file, respected its
stated scope, passed that constraint on to the subagent, and the subagent
reported it plainly without touching it. Adding prose to `AGENT.md` to handle
this exact case would be the "add prose a capable model already follows
without evidence it's needed" anti-pattern the harness design note explicitly
warns against — so Task 6 should be skipped as scoped.

Two residual observations to carry forward, neither of which is itself a
Task-6 trigger:

1. This RED run only demonstrates correct handling of a **self-describing**
   unrecognized directory (the fixture's own file text states its
   out-of-scope status, and the dev-role agent read and forwarded that text
   verbatim). It does not demonstrate handling of a **silent** unrecognized
   directory with no embedded disposition note — a harder case a future eval
   iteration could add if this needs stronger confirmation.
2. `wip-gate.sh` has no notion of "permanently excluded from gardening" — it
   will block merges on `docs/wip/legacy-import/` forever, since nothing ever
   removes that file from `docs/wip/` under the current design. Whether that's
   the intended terminal state, or a gap in the gate script (not the
   gardener), is a separate design question outside this task's scope.
