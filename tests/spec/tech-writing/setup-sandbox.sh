#!/usr/bin/env bash
# Throwaway sandbox for the tech-writing dev-role harness: a tiny consumer
# project with a source file, its passing test, and a doc that has DRIFTED from
# the code (stale signature). A fresh `claude` session opened here is asked to
# author/fix docs; we observe whether the house-style rule + umbrella shape the
# output. `green` installs the writingpowers bundle; `red` installs nothing.
set -euo pipefail

MODE="${1:?usage: setup-sandbox.sh <green|red> <dir>}"
DIR="${2:?usage: setup-sandbox.sh <green|red> <dir>}"
case "$MODE" in green | red) ;; *) echo "mode must be green|red" >&2; exit 2 ;; esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="$HERE/fixtures/sandbox"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)" # metapowers repo root
BUNDLE="$REPO_ROOT/skills/writingpowers.bundle.yaml"

rm -rf "$DIR"
mkdir -p "$DIR"
cd "$DIR"

git init -q --initial-branch=main
git config user.email "harness@tech-writing.test"
git config user.name "tech-writing harness"

cp -R "$FIXTURES"/. .

# Tests must be green BEFORE the agent runs (docs are reconciled against as-built).
# Suppress bytecode so no __pycache__ is staged into the seed commit below.
# The fixture's __main__ runner executes the asserts directly (no pytest dep).
PYTHONDONTWRITEBYTECODE=1 python3 test_calc.py > /dev/null

git add -A
git commit -q -m "chore: sandbox baseline (doc drifted from code)"

if [ "$MODE" = "green" ]; then
  upskill add "$BUNDLE" --project --quiet
fi

echo "sandbox ready: $DIR (mode=$MODE)"
