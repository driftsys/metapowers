# PR #75 review fixes

## Scope

Fixes pass-1 findings F1, F2, and F4 at baseline `098db5f`. Observer semantics
are unchanged; tests now pin the guards independently. Archive conflict handling
remains a procedure in the existing gardener agent, with no new activation rule,
agent, tool, or return format. No invocation routing change is intended.

## F1 and F2: observer assertions

Negative traces include matching tool results and assert the intended rejection
reason. Root-result ordering uses a previously successful branch result so that
branch verification cannot mask an early-root regression. Failed-root tests
assert that the root remains unverified. A completed read before the branch
result pins branch ordering; a separate unanswered-read test pins pending calls.

The 35-test suite includes 29 observer tests and six full harness tests.
`check-observer-mutations.py` changes nine guards independently in memory and
runs the observer tests. All nine mutants survive the baseline tests; all nine
cause assertion failures without errors in the revised suite. Captures:

- `runs/worktree-review-mutations-baseline-2026-10-11.json`
- `runs/worktree-review-mutations-2026-10-11.json`

```bash
python3 tests/spec/sdd-gardening/check-observer-mutations.py \
  --tests-revision 098db5f --expect-survivors
python3 tests/spec/sdd-gardening/check-observer-mutations.py
```

The mutation check runs in local `just test` and the existing CI observer job.
It tests observer assertions, not agent compliance or arbitrary OS reads.

## F4: archive collisions

Before moving any selected source, the revised agent checks all destinations
and their parents. Existing files, directories, symlinks (including dangling
ones), and symlink parents stop archival for the whole pair. It preserves both
sources and existing archives, stages no archive paths, and reports refusal
with the conflict. No renaming or overwriting workaround is prescribed.

The deterministic ordinary-move reproduction replaces an earlier archive and
removes the source, retained in
`runs/worktree-review-collision-red-2026-10-11.json`. This reproduces the unsafe
primitive; it is not a claim that the baseline agent overwrote the archive.

U4 supplies a tracked existing spec archive plus an untracked selected pair.
The baseline Claude run at `098db5f` preserved the existing spec archive but
moved/staged the plan, so whole-pair preservation and unchanged-index checks
failed. It also omitted successful branch verification, independently failing
the event audit. The revised prompt reported refusal with the conflicting path;
all eleven U4 checks passed. Both runs completed normally. Captures:

- `runs/worktree-review-collision-baseline-2026-10-11.json`
- `runs/worktree-review-collision-green-2026-10-11.json`

Two fake-agent integration tests establish that the U4 oracle accepts preservation
and rejects an overwrite even if the response mentions a conflict. These are
oracle checks, not gardener evaluations.

The live probe used Claude Sonnet through the isolated harness after explicit
user approval. It covers one regular-file collision, not directory/dangling
symlink/symlink-parent behavior, concurrent destination creation, cross-client
compliance, or all possible record edits. Preflight is a procedural safeguard,
not an atomic filesystem guarantee. Existing no-collision captures refer to the
prior prompt and have not been relabeled as runs of the revised prompt.
