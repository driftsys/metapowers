#!/usr/bin/env bash
# Build a throwaway sandbox repo that reproduces the END of a Superpowers cycle:
# a finished feature on a branch, tests green, working memory still in docs/wip/,
# and no gardened docs/ records yet. This is the fixture the dev-role harness
# (dev-role-harness.md) runs a fresh agent against.
#
# Usage:
#   setup-sandbox.sh green              <dir>   # metapowers bundle installed (live registry)
#   setup-sandbox.sh green-empty        <dir>   # green + no Superpowers working memory (over-fire probe)
#   setup-sandbox.sh override           <dir>   # green + a synthetic substrate override rule
#   setup-sandbox.sh red                <dir>   # control: NO metapowers items installed
#   setup-sandbox.sh unrecognized-wip   <dir>   # green + an extra docs/wip/<name>/ dir outside the spec/plan pair
#   setup-sandbox.sh project-layout     <dir>   # green, but in the project's own layout (flat docs/wip/, bare-slug decisions)
#   setup-sandbox.sh project-layout-ids <dir>   # project-layout + an AD-NNNN id in each existing decision record
#
# In GREEN/OVERRIDE the metapowers items (sdd-working-memory-lifecycle RULE, the
# sdd-gardening SKILL + its co-located sdd-gardener AGENT) are installed into the
# sandbox's .claude/ via `upskill add`, so a `claude` session opened there
# discovers and can activate them. OVERRIDE additionally drops an always-loaded
# project rule (fixtures/substrate-rule/acme-sdd-substrate.md) into
# .claude/rules/, reproducing a downstream bundle that overrides the authoring
# substrate. RED installs nothing, to confirm the items are load-bearing.
#
# The sandbox deliberately does NOT contain wip-gate.sh: its comments and error
# message name the sdd-gardening skill and the garden->archive procedure, so
# staging it would leak the procedure and contaminate the RED baseline. The gate
# is OBSERVER tooling — run it from the metapowers repo with cwd set to the
# sandbox:
#   ( cd <sandbox> && bash <metapowers>/skills/sdd-working-memory-lifecycle/wip-gate.sh )
# It only needs `git ls-files docs/wip/`, which resolves against cwd.

set -euo pipefail

USAGE="usage: setup-sandbox.sh <green|green-empty|override|red|unrecognized-wip|project-layout|project-layout-ids> <dir>"
MODE="${1:?$USAGE}"
DIR="${2:?$USAGE}"

case "$MODE" in
  green | green-empty | override | red | unrecognized-wip | project-layout | project-layout-ids) ;;
  *) echo "mode must be 'green', 'green-empty', 'override', 'red', 'unrecognized-wip', 'project-layout', or 'project-layout-ids', got '$MODE'" >&2; exit 2 ;;
esac

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES="$HERE/fixtures/sandbox"
PROJECT_LAYOUT="$HERE/fixtures/project-layout"
SUBSTRATE_RULE="$HERE/fixtures/substrate-rule/acme-sdd-substrate.md"
REPO_ROOT="$(cd "$HERE/../../.." && pwd)"          # metapowers repo root
BUNDLE="$REPO_ROOT/skills/metapowers.bundle.yaml"

rm -rf "$DIR"
mkdir -p "$DIR"
cd "$DIR"

git init -q --initial-branch=main
git config user.email "harness@sdd-gardening.test"
git config user.name "sdd-gardening harness"

# main has only a baseline so the feature branch carries (and tracks) docs/wip/.
printf '# sandbox\n\nA throwaway consumer project for the sdd-gardening dev-role harness.\n\nRequires Python 3.9 or newer.\n' > README.md
# A pre-existing NOTICE that does NOT mention the vendored jitter the feature adds
# (src/vendor/jitter.py) — the consistency pass should flag the missing attribution.
printf 'NOTICE\n\nThis product bundles third-party software:\n\n- requests (Apache-2.0)\n' > NOTICE
git add README.md NOTICE
git commit -q -m "chore: baseline"

git switch -q -c feat/retry-backoff

# Lay down the finished feature: working memory + implementation + tests.
cp -R "$FIXTURES"/. .

# green-empty: a finished feature with NO Superpowers working memory — the rule
# must NOT fabricate gardening here (over-fire probe).
if [ "$MODE" = "green-empty" ]; then
  rm -rf docs/wip
fi

# unrecognized-wip: green fixture + an extra docs/wip/<name>/ directory that
# is NOT the Superpowers spec/plan pair — probes the D2 fallback (surface,
# don't garden, don't delete). See #60.
if [ "$MODE" = "unrecognized-wip" ]; then
  mkdir -p docs/wip/legacy-import
  cp "$HERE/fixtures/unrecognized-wip/legacy-import/brief.md" docs/wip/legacy-import/brief.md
fi

# project-layout: the same feature, in a project whose docs follow its own
# convention instead of the default. The spec and plan move to dated files in a
# flat docs/wip/, and the overlay adds bare-slug decision records with no AD-
# ids, a flat docs/archive/ plus a per-story folder that holds no spec or plan,
# docs/wip/README.md, and a held capture on the same topic that is not part of
# the spec/plan pair. project-layout-ids also adds an AD-NNNN id to each
# existing decision record, so the file-naming rule and the id rule can be
# tested apart.
if [ "$MODE" = "project-layout" ] || [ "$MODE" = "project-layout-ids" ]; then
  mv docs/wip/specs/retry-backoff.md docs/wip/2026-09-05-retry-backoff-design.md
  mv docs/wip/plans/retry-backoff.md docs/wip/2026-09-05-retry-backoff-plan.md
  rmdir docs/wip/specs docs/wip/plans
  cp -R "$PROJECT_LAYOUT"/. .
fi
if [ "$MODE" = "project-layout-ids" ]; then
  printf '\nId: AD-0007\n' >> docs/decisions/http-client-timeouts.md
  printf '\nId: AD-0008\n' >> docs/decisions/review-before-ready-not-before-open.md
fi

# Tests must be green BEFORE the agent runs (gardening reconciles against as-built).
# Suppress bytecode so no __pycache__ is staged into the seed commit below.
PYTHONDONTWRITEBYTECODE=1 python3 tests/test_retry.py > /dev/null

git add -A
git commit -q -m "feat: HTTP client retry with backoff (wip not yet gardened)"

if [ "$MODE" != "red" ]; then
  upskill add "$BUNDLE" --project --quiet
fi

if [ "$MODE" = "override" ]; then
  # Drop the override rule into the live working tree — Claude Code auto-loads
  # .claude/rules/*.md regardless of git state. Leave it untracked, exactly like
  # the upskill-installed .claude/ output above; no asymmetric partial commit.
  mkdir -p .claude/rules
  cp "$SUBSTRATE_RULE" .claude/rules/acme-sdd-substrate.md
fi

echo "sandbox ready: $DIR (mode=$MODE, branch=$(git branch --show-current))"
echo "tracked working memory:"
git ls-files docs/wip/ | sed 's/^/  /'
