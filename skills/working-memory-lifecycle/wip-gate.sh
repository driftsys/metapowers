#!/usr/bin/env bash
# WIP-gate: fail when ungardened Superpowers working memory would reach main.
#
# A non-empty (tracked) wip/superpowers/ means the branch has working memory that
# has not been gardened into docs/ yet. Run as a required CI check on
# main-targeting branches. In private mode (wip/superpowers/ gitignored) nothing
# is tracked, so this passes trivially.
#
# Usage: ci/wip-gate.sh   (exit 0 = clean, exit 1 = ungardened WIP present)

set -euo pipefail

tracked=$(git ls-files wip/superpowers/)

if [ -n "$tracked" ]; then
  echo "WIP-gate: ungardened working memory present in wip/superpowers/:" >&2
  echo "$tracked" | sed 's/^/  /' >&2
  echo >&2
  echo "Run the sdd-gardening skill to garden it into docs/ before merging." >&2
  exit 1
fi

echo "WIP-gate: wip/superpowers/ is clean."
