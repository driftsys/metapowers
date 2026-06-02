#!/usr/bin/env bash
# Build a throwaway sandbox repo that reproduces the END of a Superpowers cycle:
# a finished feature on a branch, tests green, working memory still in
# wip/superpowers/, and an empty docs/. This is the fixture the dev-role harness
# (dev-role-harness.md) runs a fresh agent against.
#
# Usage:
#   setup-sandbox.sh green <dir>   # install the metapowers bundle (live registry)
#   setup-sandbox.sh red   <dir>   # control: NO metapowers items installed
#
# In GREEN mode the metapowers items (working-memory-lifecycle RULE, the
# sdd-gardening SKILL + its co-located sdd-gardening AGENT) are installed into the
# sandbox's .claude/ via `upskill add`, so a `claude` session opened there discovers and
# can activate them — a genuine live registry, not a handed-in description.
# In RED mode they are absent, to confirm the items are what produce the triad.
#
# The sandbox deliberately does NOT contain the wip-gate.sh script: its comments
# and error message name the sdd-gardening skill and the whole garden->archive
# procedure, so staging it would leak the procedure to the agent and contaminate
# the RED baseline (observed in the 2026-06-02 run). The gate is OBSERVER tooling
# — run it from the metapowers repo with cwd set to the sandbox:
#   ( cd <sandbox> && bash <metapowers>/skills/working-memory-lifecycle/wip-gate.sh )
# It only needs `git ls-files wip/superpowers/`, which resolves against cwd.

set -euo pipefail

MODE="${1:?usage: setup-sandbox.sh <green|red> <dir>}"
DIR="${2:?usage: setup-sandbox.sh <green|red> <dir>}"

case "$MODE" in
  green | red) ;;
  *) echo "mode must be 'green' or 'red', got '$MODE'" >&2; exit 2 ;;
esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="$HERE/fixtures/sandbox"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"          # metapowers repo root
BUNDLE="$REPO_ROOT/skills/metapowers.bundle.yaml"

rm -rf "$DIR"
mkdir -p "$DIR"
cd "$DIR"

git init -q --initial-branch=main
git config user.email "harness@sdd-gardening.test"
git config user.name "sdd-gardening harness"

# main has only a baseline so the feature branch carries (and tracks) wip/.
printf '# sandbox\n\nA throwaway consumer project for the sdd-gardening dev-role harness.\n' > README.md
git add README.md
git commit -q -m "chore: baseline"

git switch -q -c feat/retry-backoff

# Lay down the finished feature: working memory + implementation + tests.
cp -R "$FIXTURES"/. .
mkdir -p docs

# Tests must be green BEFORE the agent runs (gardening reconciles against as-built).
# Suppress bytecode so no __pycache__ is staged into the seed commit below.
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_retry.py > /dev/null

git add -A
git commit -q -m "feat: HTTP client retry with backoff (wip not yet gardened)"

if [ "$MODE" = "green" ]; then
  upskill add "$BUNDLE" --project --quiet
fi

echo "sandbox ready: $DIR (mode=$MODE, branch=$(git branch --show-current))"
echo "tracked working memory:"
git ls-files wip/superpowers/ | sed 's/^/  /'
