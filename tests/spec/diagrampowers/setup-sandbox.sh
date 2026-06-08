#!/usr/bin/env bash
# Build a throwaway sandbox for the diagrampowers OVER-ENGINEERING eval.
#
# The question this harness answers: do the diagramming skills change a capable
# model's output, or does a bare model already produce equivalent results? RED
# is the control (skills absent); GREEN installs the diagrampowers bundle.
#
# Usage:
#   setup-sandbox.sh red   <dir>   # control: NO diagram skills installed
#   setup-sandbox.sh green <dir>   # diagrampowers installed (live registry)
#
# Isolation (why this is a clean RED on a machine that dogfoods the skills):
# the diagram skills are installed USER-GLOBALLY here (~/.claude/skills/), so a
# naive `claude -p` would inherit them. The runner defeats that with
# `--setting-sources project,local` (drops the `user` scope where the global
# skills live) WITHOUT touching the user's install and WITHOUT breaking keychain
# auth. RED installs nothing into the sandbox -> zero diagram skills. GREEN
# installs diagrampowers into the sandbox's project-scope `.claude/` -> exactly
# the five skills under test, plus the bundled drawio shape-index resource.
# Verified: RED lists NONE, GREEN lists all five (see over-engineering-harness.md).
#
# The runner MUST pass `--setting-sources project,local`. This script only builds
# the sandbox; over-engineering-harness.md holds the run recipe and criteria.

set -euo pipefail

MODE="${1:?usage: setup-sandbox.sh <red|green> <dir>}"
DIR="${2:?usage: setup-sandbox.sh <red|green> <dir>}"

case "$MODE" in
  red | green) ;;
  *) echo "mode must be 'red' or 'green', got '$MODE'" >&2; exit 2 ;;
esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"          # metapowers repo root
BUNDLE="$REPO_ROOT/skills/diagrampowers.bundle.yaml"

rm -rf "$DIR"
mkdir -p "$DIR"
cd "$DIR"

git init -q --initial-branch=main
git config user.email "harness@diagrampowers.test"
git config user.name "diagrampowers harness"
printf '# sandbox\n\nA throwaway consumer project for the diagrampowers over-engineering eval.\n' > README.md
git add README.md
git commit -q -m "chore: baseline"

if [ "$MODE" = "green" ]; then
  upskill add "$BUNDLE" --project --quiet
fi

echo "sandbox ready: $DIR (mode=$MODE)"
if [ "$MODE" = "green" ]; then
  echo "installed project skills:"
  ls .claude/skills | sed 's/^/  /'
fi
