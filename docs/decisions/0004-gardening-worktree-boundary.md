# AD-0004: Keep gardening worktree preparation in metapowers

**Context.** Gardening delegates reads, record updates and archive moves to a
subagent. Its initial directory does not establish which feature checkout the
dispatcher assigned. New worktrees also need repository setup and do not carry
ignored, untracked or uncommitted working memory. The installed Superpowers
7.0.0 worktree skill detects package-manager setup but omits repository bootstrap
discovery and working-memory transfer.

**Options.** Wait for an upstream Superpowers change; create a separate general
setup skill; or extend the existing gardening dispatcher, gardener and lifecycle
rule.

**Decision.** Keep this boundary in metapowers: the dispatcher prepares the
checkout and passes its absolute root; the gardener verifies it before handling
feature material. The dispatcher follows documented repository setup and copies
only selected missing working memory while preserving source originals and
existing destination files. Differing copies need resolution before use.
An upstream Superpowers improvement is separate work; this change does not
modify the installed upstream plugin or depend on its release schedule.

**Consequences.** Consumers receive the protection with the gardening items they
already install, without another skill activation or plugin dependency. The
small lifecycle reminder loads with the existing rule; detailed steps remain in
the on-demand dispatcher. Older callers that omit the checkout root now receive
a refusal and must supply it. This is an explicit input contract, not a claim
that every client starts subagents in the wrong directory.

Related: [issue #64](https://github.com/driftsys/metapowers/issues/64),
[worktree evaluation](../../tests/spec/sdd-gardening/worktree-scenarios.md).
