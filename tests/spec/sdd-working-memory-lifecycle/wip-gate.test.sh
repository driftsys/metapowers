#!/usr/bin/env bash
# Behavioural test for skills/sdd-working-memory-lifecycle/wip-gate.sh
# plain bash, no bats dependency

GATE="$(cd "$(dirname "$0")/../../../skills/sdd-working-memory-lifecycle" && pwd)/wip-gate.sh"
PASS=0
FAIL=0

run_case() {
  local name="$1"
  local body="$2"
  local repo
  repo="$(mktemp -d)"
  (
    set -uo pipefail
    cd "$repo" || exit 1
    git init -q
    git config user.email t@t.t
    git config user.name t
    eval "$body"
  )
  local result=$?
  rm -rf "$repo"
  if [ "$result" -eq 0 ]; then
    echo "PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $name"
    FAIL=$((FAIL + 1))
  fi
}

# Case 1: passes when docs/wip is empty
run_case "passes when docs/wip is empty" '
  output=$(bash "$GATE" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
'

# Case 2: fails when tracked docs/wip holds ungardened work
run_case "fails when tracked docs/wip holds ungardened work" '
  mkdir -p docs/wip/specs
  echo "draft" > docs/wip/specs/feature.md
  git add docs/wip/specs/feature.md
  output=$(bash "$GATE" 2>&1)
  status=$?
  [ "$status" -eq 1 ] && [[ "$output" == *"docs/wip/specs/feature.md"* ]]
'

# Case 3: ignores .gitkeep placeholders
run_case "ignores .gitkeep placeholders" '
  mkdir -p docs/wip/specs
  touch docs/wip/specs/.gitkeep
  git add docs/wip/specs/.gitkeep
  output=$(bash "$GATE" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
'

# Case 4: ignores a lone docs/wip/README.md folder placeholder
run_case "ignores docs/wip/README.md placeholder" '
  mkdir -p docs/wip
  echo "# Working memory" > docs/wip/README.md
  git add docs/wip/README.md
  output=$(bash "$GATE" 2>&1)
  status=$?
  [ "$status" -eq 0 ]
'

# Case 5: still catches real work alongside a README placeholder
run_case "catches real work alongside a README placeholder" '
  mkdir -p docs/wip/specs
  echo "# Working memory" > docs/wip/README.md
  echo "draft" > docs/wip/specs/feature.md
  git add docs/wip/README.md docs/wip/specs/feature.md
  output=$(bash "$GATE" 2>&1)
  status=$?
  [ "$status" -eq 1 ] && [[ "$output" == *"docs/wip/specs/feature.md"* ]] && [[ "$output" != *"docs/wip/README.md"* ]]
'

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
