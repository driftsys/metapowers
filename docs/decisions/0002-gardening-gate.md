# AD-0002: Gardening gate as a blocking-but-resolvable review thread

**Context.** A `main`-targeting branch must not merge ungardened working memory,
but the gate should be a gate, not a wall — a rare, legitimate override must
exist and be auditable.

**Options.** A hard pass/fail CI check with admin-merge bypass; a committed
marker file; a CI label; a blocking review thread resolvable either by gardening
or by accepting the debt.

**Decision.** Split the gate into a host-agnostic detector (`wip-gate.sh` —
exits non-zero and lists the ungardened files when tracked `docs/wip/` is
non-empty, ignoring `.gitkeep`) and a host-specific wrapper that surfaces it as a
blocking review thread. The thread auto-resolves when a later push empties
`docs/wip/`. The override is "accept the debt": self-serve by anyone, but it
requires an explicit reason mirrored into a visible marker (a sticky summary plus
a label) so approvers cannot miss it — the standing approval requirement, not a
silent dismiss, is what holds the line.

**Consequences.** Good — a portable detector; the override is visible and logged
in the PR rather than an invisible privileged bypass. Bad — the review-thread
wrapper is host-specific and is a separate implementation (deferred); the
detector alone is only a hard gate.

Related: [AD-0001](0001-working-memory-location-and-mode.md)
