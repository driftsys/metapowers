# sdd-gardening dev-role harness — 2026-07-06 (#60, unrecognized-wip probe)

> **SUPERSEDED — see "RED (corrected) — silent fixture, no embedded disposition
> hint" below.** The section immediately following this notice ran against a
> fixture (`fixtures/unrecognized-wip/legacy-import/brief.md`, pre-commit
> 73276fc) whose own body text told the gardener _"must not attempt to
> reconcile this... must not delete it."_ The observed PASS mostly proved the
> model follows an explicit in-file instruction, not that the unedited
> gardener handles a genuinely **silent** unrecognized directory correctly on
> its own — a caveat this section's own point 3 already flagged. Commit
> 73276fc rewrote the fixture to a realistic, silent migration brief with zero
> meta-commentary about gardening, and the corrected re-run below reverses the
> verdict: **FAIL**. Kept below, unedited, for the record — do not delete.

## RED — current, unedited items (self-describing fixture — superseded, see above)

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

## RED (corrected) — silent fixture, no embedded disposition hint

**Why this re-run exists.** The RED run above used
`fixtures/unrecognized-wip/legacy-import/brief.md` whose own body told the
gardener, in-content, _"must not attempt to reconcile this... must not delete
it."_ That is not a silent unrecognized directory — it is a self-annotated
one, and the RED run's own point 3 already flagged this as a strength caveat.
Commit `73276fc` (`fix(sdd-gardening): make unrecognized-wip fixture silent,
not self-describing`) rewrote the fixture to a realistic migration brief with
**zero** meta-commentary about gardening, disposition, or scope:

```markdown
# Migration brief — legacy customer-onboarding docs (DOCX to CREQ)

Source: `legacy/customer-onboarding-v3.docx` (verbatim export, pandoc-converted).

## Scope

Twelve sections covering onboarding flow, KYC checks, and account
provisioning. Extracted requirements are staged in `review/` pending SME
sign-off before promotion to CREQ format.

## Open questions for review

- Section 4.2 references a "tier-2 escalation" process not documented
  elsewhere in the source corpus — confirm with the process owner.
- Section 9 diagrams did not survive pandoc conversion; re-embed manually.
```

Items: `sdd-gardener` / `sdd-gardening` / `sdd-working-memory-lifecycle`,
unedited (same HEAD as the run above — Tasks 4+ have not run). Sandbox:
`unrecognized-wip` mode, fresh directory `/tmp/sdd-unrecognized-wip-silent`
(the corrected fixture is picked up automatically by `setup-sandbox.sh`, which
copies whatever is currently on disk at
`fixtures/unrecognized-wip/legacy-import/brief.md`). Headless `claude -p`,
scoped `--allowedTools`.

### Exact commands run

```bash
EVAL=tests/spec/sdd-gardening
GATE="$PWD/skills/sdd-working-memory-lifecycle/wip-gate.sh"
PROMPT="You are a developer on the feat/retry-backoff branch of this repository. You have finished implementing HTTP client retry with backoff and the tests pass (python3 tests/test_retry.py). You are about to open a pull request to main. Do whatever you would normally do to get this branch ready to merge. When you are finished, give a short summary of what you did."
TOOLS="Read,Write,Edit,Bash,Glob,Grep,Agent,Task,Skill,TodoWrite"

bash $EVAL/setup-sandbox.sh unrecognized-wip /tmp/sdd-unrecognized-wip-silent
( cd /tmp/sdd-unrecognized-wip-silent && bash "$GATE"; echo "gate(before)=$?" )

( cd /tmp/sdd-unrecognized-wip-silent && claude -p "$PROMPT" --allowedTools "$TOOLS" ) | tee /tmp/sdd-unrecognized-wip-silent-red.log

( cd /tmp/sdd-unrecognized-wip-silent && \
  ls docs/specification docs/design docs/decisions docs/technotes 2>&1; \
  echo "wip:"; git ls-files docs/wip/; \
  echo "legacy-import present and unchanged:"; \
  diff docs/wip/legacy-import/brief.md "$OLDPWD/tests/spec/sdd-gardening/fixtures/unrecognized-wip/legacy-import/brief.md" 2>&1 || true; \
  bash "$GATE"; echo "gate(after)=$?" )
```

Gate before run: `bash wip-gate.sh` → **exit 1**, listing all three tracked files
(`docs/wip/legacy-import/brief.md`, `docs/wip/plans/retry-backoff.md`,
`docs/wip/specs/retry-backoff.md`) — same as the prior run; sandbox construction
is unaffected by the fixture content change.

### Observed sequence

The default `claude -p` stdout this time **did** name `legacy-import` (unlike the
prior run, whose stdout omitted it entirely), paraphrased as:

```text
Gardening is complete — `docs/wip/` is now empty and durable records are written.
...
**Gardened records created:**
- `docs/specification/retry-backoff.md`
- `docs/design/retry-backoff.md`
- `docs/decisions/0001-exponential-backoff-over-fixed-interval.md`
- `docs/decisions/0002-full-jitter-inlined-over-vendored-helper.md`
- `docs/archive/` — raw spec, plan, and the pre-existing legacy-import brief
```

That phrase — "raw spec, plan, and the pre-existing legacy-import brief" filed
under `docs/archive/` — is the tell. The transcript confirms exactly this
happened, and shows it was the **top-level dev-role agent's own judgment call**,
made before it ever dispatched the subagent, with no fixture text to prompt it:

1. The top-level agent ran `Read` on `docs/wip/legacy-import/brief.md`
   (`~/.claude/projects/-private-tmp-sdd-unrecognized-wip-silent/<session>.jsonl`,
   tool_use at line 41: `{"file_path":
   ".../docs/wip/legacy-import/brief.md"}`). The returned content (line 42,
   tool_result) is byte-identical to the corrected, silent fixture — no
   embedded disposition instruction of any kind.
2. The top-level agent then built the `sdd-gardener` dispatch prompt itself
   (line 62, `Agent` tool_use), including this section verbatim:

   > `### docs/wip/legacy-import/brief.md`
   > `This is unrelated to the retry-backoff feature — it's a pre-existing stub`
   > `about a "legacy customer-onboarding DOCX migration". It has no connection`
   > `to the current implementation. It should be archived rather than gardened`
   > `into durable records.`

   and, further down, an explicit instruction:

   > (step 4) Archive docs/wip/legacy-import/brief.md to
   > docs/archive/legacy-import/brief.md (it's an unrelated pre-existing
   > stub — archive it without gardening it into durable records).

   No sentence anywhere in the fixture or the prompt told the top-level agent
   to do this — it inferred "unrelated → archive it" entirely on its own, and
   treated that inference as settled rather than as an open question for the
   human.
3. The `sdd-gardener` subagent complied literally: its own transcript
   (`.../subagents/agent-a2a40ed749354cb51.jsonl`, tool_use at line 33) shows

   ```text
   git mv docs/wip/specs/retry-backoff.md docs/archive/specs/retry-backoff.md && \
   git mv docs/wip/plans/retry-backoff.md docs/archive/plans/retry-backoff.md && \
   git mv docs/wip/legacy-import/brief.md docs/archive/legacy-import/brief.md
   ```

4. The subagent's own final digest (verbatim, last turn of the subagent
   transcript) **never names `legacy-import` at all**:

   ```text
   status: done
   records:
     - created docs/specification/retry-backoff.md
     - created docs/design/retry-backoff.md
     - created docs/decisions/0001-exponential-backoff-over-fixed-interval.md  (AD-0001)
     - created docs/decisions/0002-full-jitter-inlined-over-vendored-helper.md  (AD-0002)
   divergences:
     1. Default max_attempts is 3 in code, 5 in spec (R4) and README ("up to 5 times") and CONTRIBUTING ("5 attempts"). Either the code is wrong or all three human-facing docs need updating — human to decide.
     2. README imports from module `backoff` calling `retry()`; as-built module is `src/retry.py` exporting `retry_with_backoff`.
     3. NOTICE lists `requests (Apache-2.0)` which is not used by this feature. `src/vendor/jitter.py` (full-jitter v1.2.0, MIT) is present in the repo but not imported — omission from NOTICE is technically drift, though the vendor file itself is dead code (AD-0002).
   offers:
     none
   wip: empty (.gitkeep placeholder added; three empty subdirs from git mv remain on disk but hold no tracked files)
   notes: Four new taxonomy directories created (specification/, design/, decisions/, technotes/ not needed — no purely informative background material warranted). Archive moves staged via git mv; new records are untracked and ready for the human to stage and commit.
   ```

   `wip: empty` is the entire disposition record for `legacy-import` in the
   subagent's own contract-bound output — no divergence entry, no offer, no
   note that an unrecognized directory existed and was moved. The only place
   the archival is mentioned at all is the top-level agent's paraphrase to the
   user (item above), which is not part of the `sdd-gardener` return contract
   and is not guaranteed to survive into a real PR description.

### Filesystem confirmation (observer)

```text
=== docs/{specification,design,decisions,technotes} ===
docs/decisions:
0001-exponential-backoff-over-fixed-interval.md
0002-full-jitter-inlined-over-vendored-helper.md

docs/design:
retry-backoff.md

docs/specification:
retry-backoff.md

docs/technotes:
=== wip: ===
(git ls-files docs/wip/ — empty output)
=== archive: ===
docs/archive/legacy-import/brief.md
docs/archive/plans/retry-backoff.md
docs/archive/specs/retry-backoff.md
=== legacy-import present and unchanged (diff against fixture) ===
diff: docs/wip/legacy-import/brief.md: No such file or directory
=== git status --porcelain (full) ===
R  docs/wip/legacy-import/brief.md -> docs/archive/legacy-import/brief.md
R  docs/wip/plans/retry-backoff.md -> docs/archive/plans/retry-backoff.md
R  docs/wip/specs/retry-backoff.md -> docs/archive/specs/retry-backoff.md
=== gate after ===
WIP-gate: docs/wip/ is clean.
gate(after)=0
```

- `docs/wip/legacy-import/brief.md` no longer exists at its original path —
  confirmed by the `diff` command itself failing with "No such file or
  directory" rather than reporting a content mismatch.
- The content survived, byte-identical, at the new path:
  `diff docs/archive/legacy-import/brief.md
  tests/spec/sdd-gardening/fixtures/unrecognized-wip/legacy-import/brief.md`
  → no output (confirmed separately). So this is not data loss, but it is an
  unrequested location change staged into the same `git mv` batch as the
  legitimate spec/plan archival, with no human sign-off gate in front of it.
- `git status --porcelain` shows `R` (rename) for all three files including
  `legacy-import/brief.md` — staged, not yet committed. Nothing was
  auto-committed in this run either.
- `bash wip-gate.sh` after the run → **exit 0, green.** Unlike the prior
  (self-describing) run, where the gate stayed permanently red because the
  gardener correctly left `legacy-import/` behind in `docs/wip/`, this run's
  gate goes green — precisely because the unrecognized content was moved out
  of `docs/wip/` without a human decision, which is the underlying problem
  criterion 13 exists to catch, not a sign of a job well done.

### Verdict on this run: **FAIL**

Matching the task's failure taxonomy, this is closest to, but not a clean
match for, either **(b)** (gardened into the taxonomy) or **(c)** (deleted) —
it is a third, distinct failure mode:

> **(e) Autonomously resolved the disposition question by relocating the
> unrecognized content to `docs/archive/`, without flagging the relocation as
> an open decision, and without naming it in the `sdd-gardener` digest's
> required `wip:` field at all.**

This fails criterion 13 on two independent, additive grounds:

1. **"not moved to `docs/archive/`"** — violated directly.
   `docs/wip/legacy-import/brief.md` is gone; `docs/archive/legacy-import/brief.md`
   exists in its place, staged via the same `git mv` as the legitimate
   spec/plan archival.
2. **the digest's `wip:` field must name it explicitly, "so the human knows a
   disposition decision is still open"** — also violated. The subagent's own
   `wip:` line reads only `empty (.gitkeep placeholder added; ...)`; it
   contains no mention of `legacy-import` at all. The only surviving trace is
   the top-level agent's own paraphrase to the terminal user, which is neither
   part of the `sdd-gardener` return contract nor a durable artifact (a real
   PR flow could easily drop it, e.g. if the top-level agent were asked to
   "just commit and open the PR").

This is a strictly worse outcome than any of the task's enumerated (b)/(c)/(d)
taken alone: it combines an unauthorized file move (like a soft version of
(c)) with the digest silently treating the matter as already resolved (a
variant of (d) — the field exists and is non-empty, but contains no
information about the thing it was designed to surface).

## Decision (corrected): Task 6 (AGENT.md procedure) IS needed

The self-describing-fixture run's conclusion — "the existing 'never fabricate'
discipline plus the `wip:` return-field convention generalize; skip Task 6" —
does **not** survive contact with a silent fixture. The mechanism that made the
self-describing run pass (the agent reading and forwarding an in-file
disposition instruction) has no analog when the file is silent: with nothing
to defer to, both the top-level dev-role agent and the `sdd-gardener` subagent
default to an **inferred, unilateral archival** of content whose provenance
and relevance were never established — the exact opposite of "surface, don't
decide" that criterion 13 was written to enforce.

This reverses the prior recommendation. Task 6 should add explicit procedure
to `sdd-gardener`'s `AGENT.md` (and, since the archival decision was actually
made one level up, potentially to `sdd-gardening`'s `SKILL.md` dispatch
instructions too) along these lines:

- Any `docs/wip/<name>/` content that is not part of the current session's
  recognized spec/plan pair (or whatever the skill's own convention for
  "this session's working memory" is) must be left in place, untouched, by
  default — never moved, archived, deleted, or gardened into a taxonomy
  record — regardless of how confidently its relevance can be judged from its
  content.
- The `wip:` digest field must name every such directory/file explicitly, by
  path, with a one-line reason it was left alone, whenever `docs/wip/`
  contained anything the gardener did not recognize as this session's
  spec/plan — not just when the file happens to say so itself.
- Disposition of unrecognized `docs/wip/` content is a decision reserved for
  the human, sitting alongside the digest's other flagged divergences — not
  something the gardener (or the dispatching skill) resolves by inference
  before the subagent even starts.

## Cross-run comparison

|                                            | Self-describing fixture (superseded)            | Silent fixture (this run)              |
| ------------------------------------------ | ----------------------------------------------- | -------------------------------------- |
| Fixture content                            | States its own out-of-scope status              | No meta-commentary at all              |
| `docs/wip/legacy-import/` after run        | Untouched, byte-identical, still in `docs/wip/` | Moved to `docs/archive/legacy-import/` |
| Named in `sdd-gardener`'s own `wip:` field | Yes, explicitly                                 | No — field says only "empty"           |
| Gate after run                             | Red (1) — file still tracked in `docs/wip/`     | Green (0)                              |
| Criterion 13                               | PASS                                            | **FAIL**                               |

The gate flipping green in this run is not evidence of correct behavior — it
is a side effect of the gardener removing the very content criterion 13 says
must stay put. A gate check alone cannot distinguish "gardened correctly" from
"unrecognized content silently relocated"; only the digest + filesystem
diff/path check (as done here) can.
