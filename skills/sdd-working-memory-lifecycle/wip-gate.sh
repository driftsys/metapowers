#!/usr/bin/env bash
# WIP-gate: fail when ungardened Superpowers working memory would reach main.
#
# A non-empty (tracked) docs/wip/ means the branch has working memory that has
# not been gardened into the durable docs/ records yet. Run as a required CI
# check on main-targeting branches. In private mode (docs/wip/ gitignored)
# nothing is tracked, so this passes trivially.
#
# Usage: ci/wip-gate.sh   (exit 0 = clean, exit 1 = ungardened WIP present)

set -euo pipefail

# Placeholder files (.gitkeep, and the folder's own README.md) only preserve
# the docs/wip/ directory structure and its documentation after gardening —
# they are not ungardened work, so they must not trip the gate.
tracked=$(git ls-files docs/wip/ | grep -vE '/(\.gitkeep|README\.md)$' || true)

if [ -n "$tracked" ]; then
  echo "WIP-gate: ungardened working memory present in docs/wip/:" >&2
  echo "$tracked" | sed 's/^/  /' >&2
  echo >&2
  echo "Run the sdd-gardening skill to garden it into docs/ before merging." >&2
  exit 1
fi

echo "WIP-gate: docs/wip/ is clean."
