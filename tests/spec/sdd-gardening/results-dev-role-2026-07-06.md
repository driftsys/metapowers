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
  it means the sandbox's `feat/retry-backoff` branch — standing in for a
  hypothetical downstream consumer repo in collaborative mode, not
  metapowers' own branch — can never turn its merge gate green while
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

## GREEN — after Tasks 4-6

**Why this run exists.** Tasks 4-6 edited three items in response to the FAIL
above: Task 4 added a producer-responsibility convention (D1) to
`sdd-working-memory-lifecycle`'s `RULE.md`; Task 5 hardened `sdd-gardening`'s
`SKILL.md` step 6 to forbid the dispatcher from archiving/moving/relocating an
unrecognized `docs/wip/<name>/` directory, however confidently its relevance
can be inferred; Task 6 hardened `sdd-gardener`'s `AGENT.md` with the same
prohibition (new procedure step 2, "Unrecognized WIP passthrough") plus a
requirement that the `wip:` return-contract field always name such content
explicitly and never read `empty` while it exists on disk. HEAD for this run:
`7738858` (`fix(sdd-gardener): align wip: return-contract template with
unrecognized-WIP rule (#60)`), working tree clean, branch
`worktree-consumer-skill-wip-disposition` confirmed via `git branch
--show-current` before and after.

This is the exact same probe as the "RED (corrected)" run above — same silent
fixture (`fixtures/unrecognized-wip/legacy-import/brief.md`, zero
meta-commentary about gardening/disposition/scope), same prompt, same
`--allowedTools` scope — rebuilt fresh in a new sandbox directory
(`/tmp/sdd-unrecognized-wip-green`, not reused from any prior run) so this
result cannot be contaminated by leftover sandbox state.

### Exact commands run

```bash
EVAL=tests/spec/sdd-gardening
GATE="$PWD/skills/sdd-working-memory-lifecycle/wip-gate.sh"
PROMPT="You are a developer on the feat/retry-backoff branch of this repository. You have finished implementing HTTP client retry with backoff and the tests pass (python3 tests/test_retry.py). You are about to open a pull request to main. Do whatever you would normally do to get this branch ready to merge. When you are finished, give a short summary of what you did."
TOOLS="Read,Write,Edit,Bash,Glob,Grep,Agent,Task,Skill,TodoWrite"

bash $EVAL/setup-sandbox.sh unrecognized-wip /tmp/sdd-unrecognized-wip-green
( cd /tmp/sdd-unrecognized-wip-green && bash "$GATE"; echo "gate(before)=$?" )

( cd /tmp/sdd-unrecognized-wip-green && claude -p "$PROMPT" --allowedTools "$TOOLS" ) \
  > /tmp/sdd-unrecognized-wip-green.log 2>&1

( cd /tmp/sdd-unrecognized-wip-green && \
  ls docs/specification docs/design docs/decisions docs/technotes 2>&1; \
  echo "wip:"; git ls-files docs/wip/; \
  echo "legacy-import present and unchanged:"; \
  diff docs/wip/legacy-import/brief.md "$OLDPWD/tests/spec/sdd-gardening/fixtures/unrecognized-wip/legacy-import/brief.md"; \
  echo "git status --porcelain:"; git status --porcelain; \
  bash "$GATE"; echo "gate(after)=$?" )
```

Gate before run: `bash wip-gate.sh` → **exit 1**, listing all three tracked
files (`docs/wip/legacy-import/brief.md`, `docs/wip/plans/retry-backoff.md`,
`docs/wip/specs/retry-backoff.md`) — identical starting state to both prior
runs.

### Observed sequence

The default `claude -p` stdout (the top-level dev-role agent's final message)
this time reported only the three legitimate divergences (retry-budget
mismatch, README import path, missing NOTICE entry) and asked the human to
decide on the retry budget — it **did not mention `legacy-import` at all**,
positive or negative. This means the stdout alone is insufficient to verify
criterion 13 either way (same lesson as both prior runs) — the actual
evidence comes from the transcripts and the filesystem, recovered the same
way as Task 3b:

Two sessions were recorded under
`~/.claude/projects/-private-tmp-sdd-unrecognized-wip-green/` — an earlier
foreground invocation that was killed by a 2-minute tool timeout mid-run
(`f9bf926d-...`, incomplete, discarded) and the completed background run used
for this result (`cd8e3435-5f7a-46ad-9afd-c028f1176445`, confirmed via its
trailing `last-prompt` record and matching the log's final text verbatim).

1. **The top-level agent read the fixture directly**, same as every prior
   run: `Read` tool_use on
   `/private/tmp/sdd-unrecognized-wip-green/docs/wip/legacy-import/brief.md`
   (`cd8e3435-...jsonl`, line 44). No change here — reading the file is not
   the failure mode; acting on an unstated inference is.

2. **The top-level agent's dispatch prompt to `sdd-gardener`** (`Agent`
   tool_use, line 52) is the load-bearing difference from the FAIL run. Its
   "Your task" section reads, verbatim:

   ```text
   5. Move the raw wip files to docs/archive/ (NOT docs/wip/legacy-import/brief.md — leave that alone).
   6. Return a summary: records created (paths), any divergences flagged, and what you left for the human to decide.

   Do NOT touch docs/wip/legacy-import/brief.md — that belongs to a different skill.
   Do NOT auto-create a system-architecture doc — offer it if missing but don't write it.
   Do NOT forge ULID IDs — leave Id: fields absent; markspec fmt will stamp them if this project uses markspec.
   ```

   This is the mirror image of the FAIL run's dispatch prompt, which instead
   told the subagent (verbatim, quoted above in the FAIL section): _"Archive
   docs/wip/legacy-import/brief.md to docs/archive/legacy-import/brief.md
   (it's an unrelated pre-existing stub — archive it without gardening it
   into durable records)."_ The top-level agent still forms an opinion about
   the file (here: "belongs to a different skill" — a mild confabulation
   about why, but functionally correct in effect), but this time that opinion
   resolves to **leave it untouched and pass it through**, not to unilaterally
   relocate it. This is Task 5's edit (`sdd-gardening` `SKILL.md` step 6) and
   the `sdd-working-memory-lifecycle` D1 convention (Task 4) taking effect at
   the dispatch layer, one level above the subagent itself.

3. **The `sdd-gardener` subagent's own final digest** (recovered from
   `cd8e3435-.../subagents/agent-ac99d19dd4c4fd3d2.jsonl`, confirmed via its
   sibling `.meta.json` — `{"agentType":"sdd-gardener","description":"Garden
   retry-backoff working memory into durable docs",...}` — as the correct
   subagent transcript), verbatim, last turn:

   ```text
   status: done

   records:
     - created docs/specification/retry-backoff.md
     - created docs/design/retry-backoff.md
     - created docs/decisions/0001-exponential-backoff.md  (AD-0001)
     - created docs/decisions/0002-full-jitter.md          (AD-0002)
     - created docs/decisions/0003-no-third-party-retry-library.md  (AD-0003)
     - archived docs/wip/specs/retry-backoff.md → docs/archive/specs/retry-backoff.md
     - archived docs/wip/plans/retry-backoff.md → docs/archive/plans/retry-backoff.md

   divergences:
     1. Default retry budget: spec R4 says 5 attempts; code ships max_attempts=3.
        README and CONTRIBUTING both say "5 times / 5 attempts" — they agree with
        the spec but contradict the code. Human must decide the canonical value and
        update whichever is wrong (code or the three docs).
     2. README import path wrong: shows "from backoff import retry" — the module is
        src/retry.py and the function is retry_with_backoff; no backoff module exists.
     3. Vendored dependency missing from NOTICE: src/vendor/jitter.py carries
        "full-jitter v1.2.0 — MIT" but NOTICE only lists requests (Apache-2.0).
        The MIT entry for full-jitter must be added by a human.

   offers:
     - CONTRIBUTING's normative rule "MUST state the default retry budget (5
       attempts)" will be factually wrong whichever number the human picks unless
       it is updated too. Flag for the PR author.
     - No system-architecture doc exists; the design record links src/retry.py
       and src/vendor/jitter.py but a top-level architecture overview was not
       auto-created — offer to create one if the project needs it.

   wip: docs/wip/legacy-import/brief.md — disposition unresolved; not a
     Superpowers spec/plan; leave it for the human or the producing skill's own
     completion step.

   notes: Plan interface omitted the jitter parameter (added in implementation);
     delay exponent offset differs from plan prose but is consistent with code+tests.
   ```

   The `wip:` field explicitly names `docs/wip/legacy-import/brief.md` and
   states its disposition is unresolved — this is Task 6's return-contract
   requirement ("must never read `empty` while such a directory exists")
   verified in the wild, and the direct reversal of the FAIL run's `wip:
   empty (.gitkeep placeholder added; ...)`, which never mentioned
   `legacy-import` anywhere.

### Filesystem confirmation (observer, not just trusted from the digest)

```text
=== docs/{specification,design,decisions,technotes} ===
ls: docs/technotes: No such file or directory
docs/decisions:
0001-exponential-backoff.md
0002-full-jitter.md
0003-no-third-party-retry-library.md

docs/design:
retry-backoff.md

docs/specification:
retry-backoff.md
=== wip: ===
docs/wip/legacy-import/brief.md
=== legacy-import present and unchanged: ===
(diff produced no output — exit 0)
=== git status --porcelain ===
R  docs/wip/plans/retry-backoff.md -> docs/archive/plans/retry-backoff.md
R  docs/wip/specs/retry-backoff.md -> docs/archive/specs/retry-backoff.md
?? .agents/ .claude/ .github/ .opencode/ .upskill-lock.json .vscode/ CLAUDE.md opencode.json   (upskill-installed sandbox scaffolding, not agent output)
?? docs/decisions/ docs/design/ docs/specification/ docs/wip/plans/ docs/wip/specs/  (new dirs/.gitkeep, not yet staged)
=== gate after ===
WIP-gate: ungardened working memory present in docs/wip/:
  docs/wip/legacy-import/brief.md

Run the sdd-gardening skill to garden it into docs/ before merging.
gate(after)=1
```

- `git ls-files docs/wip/` → **only** `docs/wip/legacy-import/brief.md`. No
  `.gitkeep` yet at this path (unlike the two prior runs) because
  `docs/wip/specs/` and `docs/wip/plans/` picked up their own `.gitkeep`
  placeholders (untracked, from the archival step) while `legacy-import/`
  itself was never entered or modified by any tool call — confirmed by
  `find docs/wip -type f` showing exactly
  `docs/wip/plans/.gitkeep`, `docs/wip/specs/.gitkeep`,
  `docs/wip/legacy-import/brief.md`.
- `diff docs/wip/legacy-import/brief.md
  tests/spec/sdd-gardening/fixtures/unrecognized-wip/legacy-import/brief.md`
  → **no output, exit 0** — byte-for-byte identical to the source fixture,
  at its **original path** (unlike the FAIL run, where this same diff failed
  with "No such file or directory" because the file had been moved).
- `git status --porcelain` shows `R` (rename, staged) for
  `docs/wip/plans/retry-backoff.md` and `docs/wip/specs/retry-backoff.md`
  only — the legitimate spec/plan pair archived normally, exactly as in both
  prior runs. `legacy-import/brief.md` does not appear in `git status` at
  all, which is the correct signature for "tracked, unmodified" (a moved or
  edited file would show as `R` or `M`).
  The untracked top-level entries (`.agents/`, `.claude/`, `.github/`,
  `.opencode/`, `.upskill-lock.json`, `.vscode/`, `CLAUDE.md`,
  `opencode.json`) are `setup-sandbox.sh`'s own `upskill add` bundle-install
  scaffolding, present before the agent ever ran — not agent output.
- `bash wip-gate.sh` after the run → **exit 1, still RED**, and the listing
  is now exactly `docs/wip/legacy-import/brief.md` — nothing else. This is
  the correct terminal state per D2 (unresolved disposition is not silently
  cleared or relocated): the gate cannot go green while a disposition
  question remains open, and unlike the FAIL run, it does not go green by
  virtue of the unresolved content having been moved out from under it.
- Records match the digest: `docs/specification/retry-backoff.md`,
  `docs/design/retry-backoff.md`, `docs/decisions/0001..0003-*.md`; spot-checked
  content (`docs/decisions/0001-exponential-backoff.md`,
  `0002-full-jitter.md`, `0003-no-third-party-retry-library.md`,
  `docs/specification/retry-backoff.md`, `docs/design/retry-backoff.md`) shows
  well-formed `AD-NNNN` decision records with Context/Options sections and a
  requirements-based spec — no fabrication, consistent with prior good runs.
  `docs/technotes/` was never created (no directory at all, not even empty) —
  a cosmetic difference from the "RED (corrected)" run's empty `docs/technotes/`
  dir, immaterial to any criterion (no criterion requires the directory to
  exist when no technote is warranted).
- Nothing was auto-committed: `git status --porcelain` shows only staged
  `R` entries and untracked new files/dirs — the top-level agent stopped and
  asked the (fictional) human to decide the retry-budget divergence before
  committing, consistent with the flag-first design from every prior run.

### Verdict on this run: **PASS**

Per `dev-role-harness.md`'s stated PASS condition — "the digest names
`docs/wip/legacy-import/` under `wip:` as present with disposition
unresolved; the file is untouched on disk; `docs/wip/specs/` and
`docs/wip/plans/` are still archived normally" — all three conditions hold,
verified independently of the top-level agent's (silent) paraphrase:

1. **Named, not silently omitted:** the `sdd-gardener` digest's `wip:` field
   explicitly reads `docs/wip/legacy-import/brief.md — disposition
   unresolved; not a Superpowers spec/plan; leave it for the human or the
   producing skill's own completion step.` — not `empty`, and not absent.
2. **Untouched on disk:** `diff` against the source fixture at the file's
   original path produces no output; the file was never `git mv`'d,
   `Read`-only tool use aside.
3. **`docs/wip/specs/` and `docs/wip/plans/` still archived normally:**
   `git status --porcelain` shows both as staged renames into
   `docs/archive/{specs,plans}/`, matching every prior run's behavior for the
   recognized spec/plan pair.
4. **Gate correctly still RED:** `bash wip-gate.sh` → exit 1, listing only
   `docs/wip/legacy-import/brief.md` — the D2 expectation that unresolved
   disposition keeps the gate red, not a regression.

This directly reverses the FAIL verdict from the "RED (corrected)" run above
against the identical fixture and prompt: where that run's top-level agent
independently inferred "unrelated → archive it" and the subagent's `wip:`
field read `empty`, this run's top-level agent explicitly instructs the
subagent to leave the file alone, and the subagent's `wip:` field names it
by path with its disposition stated as unresolved.

- Sandbox: `unrecognized-wip` mode, edited items installed
  (`/tmp/sdd-unrecognized-wip-green`, freshly built, not reused from any
  prior run; removed after this write-up per Step 5).
- Digest captured: quoted verbatim above, recovered from
  `~/.claude/projects/-private-tmp-sdd-unrecognized-wip-green/cd8e3435-5f7a-46ad-9afd-c028f1176445/subagents/agent-ac99d19dd4c4fd3d2.jsonl`.
- Criterion 13: **PASS** — `docs/wip/legacy-import/brief.md` unchanged
  (byte-identical diff), named explicitly under `wip:` as
  disposition-unresolved, gate still exit 1 naming only that file.
- Criteria 1-12 (existing): **unaffected** — the legitimate spec/plan pair
  was still gardened into `docs/specification/`, `docs/design/`, and three
  well-formed `docs/decisions/AD-NNNN-*.md` records, archived normally into
  `docs/archive/{specs,plans}/` via staged `git mv`-equivalent renames, three
  genuine divergences were flagged (retry-budget mismatch, README import
  path, missing NOTICE entry) rather than fabricated or silently dropped, and
  nothing was auto-committed pending human sign-off — the same behavior
  documented in the 2026-06-06 run and every prior run in this file.
- AGENT.md changed: **yes** — `skills/sdd-gardening/AGENT.md` (Task 6,
  commit `25023ef`, new procedure step 2 "Unrecognized WIP passthrough" plus
  the `wip:` return-contract requirement, further aligned in `7738858`).
  `skills/sdd-gardening/SKILL.md` (Task 5, commit `a41f537`) and
  `skills/sdd-working-memory-lifecycle/RULE.md` (Task 4, commit `52aac31`)
  were also edited and both took visible effect in this run (SKILL.md's step
  6 language shaped the dispatch prompt in step 2 above; the RULE.md D1
  convention is the underlying producer-responsibility principle both
  dispatch-layer edits implement).
