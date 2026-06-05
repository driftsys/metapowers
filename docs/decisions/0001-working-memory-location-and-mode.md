# AD-0001: Working-memory location, lifecycle, and mode

**Context.** A Superpowers session produces specs and plans (working memory)
that must be visible to collaborators yet never become a shadow source of
truth. We need one place for in-progress work, a rule for what happens to the
raw artifacts after gardening, and a default for whether that work is shared.

**Options.** Top-level `wip/superpowers/` with a separate `archive/`; a
gitignored `.scratch/`; working memory under `docs/` (`docs/wip/` +
`docs/archive/`).

**Decision.** In-progress specs and plans live in `docs/wip/`. When the work
lands and durable records are written, the raw originals move to `docs/archive/`
— never deleted. `docs/wip/` is tracked by default (collaborative); a project
goes private by gitignoring `docs/wip/`, which is the only switch — no config
flag. Co-locating the whole draft → durable → retired lifecycle under `docs/`
keeps it in one tree.

**Consequences.** Good — one history for spec/plan and code; reviewers see
rationale as diffs; raw rationale is recoverable from `docs/archive/` rather
than git archaeology. Bad — a tracked `docs/wip/` must be gardened before merge
(enforced by AD-0002); private mode forgoes shared visibility and git-based
recovery of the raw.

Supersedes: the working-memory-lifecycle technote's `wip/superpowers/` path.
Related: [AD-0002](0002-gardening-gate.md), [AD-0003](0003-durable-records-taxonomy.md)
