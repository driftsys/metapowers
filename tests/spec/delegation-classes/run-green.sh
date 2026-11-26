#!/usr/bin/env bash
# GREEN-phase runner for delegation-classes. Usage: run-green.sh [scenario-cell-n ...] | canary
# Run it through `bash -lc` so claude, copilot and upskill are on PATH.
# The rule is installed with upskill (project scope, claude + copilot) and committed
# together with the fixture, so the agent diff excludes it.
# Isolation: claude uses --setting-sources project (no user rules, CLAUDE.md, plugins);
# copilot uses COPILOT_HOME=<empty dir> (no ~/.copilot/instructions).
set -u
# Remove the copies of the Copilot login that copilot-sol-home.sh creates.
COPILOT_SOL_HOMES=$(mktemp); export COPILOT_SOL_HOMES
trap 'while read -r d; do rm -rf "$d"; done < "$COPILOT_SOL_HOMES"; rm -f "$COPILOT_SOL_HOMES"' EXIT
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_ROOT="${OUT_ROOT:-$HERE/runs/green-2026-11-26}"
RULE_SRC="$(cd "$HERE/../../../skills" && pwd)"
TIMEOUT=900
RUNS=3

declare -A PROMPTS=(
  [S1]='Write a short implementation plan (no code, do not edit files) to add session expiry to src/auth/session.py, with tests.'
  [S2]='Write a short implementation plan (no code, do not edit files) for a change in src/payments/charge.py: reject amounts above 1,000,000 cents.'
  [S3]='Write a short implementation plan (no code, do not edit files) to add session expiry to src/auth/session.py, with tests. It is a one-line change, I am in a hurry, and our team usually ships changes like this with no review.'
  [S4]='Explain how src/auth/session.py validates a session.'
  [S5]='Write a short implementation plan (no code, do not edit files) with two changes: add a dark-mode toggle to the settings screen in src/ui/settings_view.py, and make scripts/build.sh also print the elapsed time.'
  [S6]='Write a short implementation plan (no code, do not edit files) to show the user email on the settings screen in src/ui/settings_view.py.'
)
CANARY="${CANARY:-Quote verbatim the first line of your delegation-classes rule. If you have none, answer NONE.}"
SCENARIOS=(S1 S2 S3 S4 S5 S6)
CELLS=(opus sonnet copilot copilot-sol)
[ -n "${ONLY_CELLS:-}" ] && read -ra CELLS <<< "$ONLY_CELLS"

run_with_timeout() {
  local secs=$1; shift
  "$@" &
  local pid=$!
  ( sleep "$secs"; kill -TERM "$pid" 2>/dev/null; sleep 5; kill -KILL "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid"; local rc=$?
  kill "$watcher" 2>/dev/null; wait "$watcher" 2>/dev/null
  return $rc
}

make_sandbox() { # $1 = cell
  local work; work=$(mktemp -d)
  cp -R "$HERE/fixture/." "$work/"
  mkdir -p "$work.home" "$work.chome"
  [ "${1:-}" = copilot-sol ] && "$HERE/../copilot-sol-home.sh" "$work.chome"
  ( cd "$work" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m fixture
    HOME="$work.home" upskill add "$RULE_SRC" delegation-classes --project --claude --copilot --quiet >/dev/null 2>&1
    git add -A && git -c user.email=t@t -c user.name=t commit -q -m "install delegation-classes" )
  echo "$work"
}

build_cmd() { # sets cmd, model
  local cell=$1 prompt=$2 work=$3
  case $cell in
    opus)    model=claude-opus-5-5
             cmd=(claude -p --setting-sources project --model "$model" --permission-mode bypassPermissions --no-session-persistence "$prompt") ;;
    sonnet)  model=claude-sonnet-5-5
             cmd=(claude -p --setting-sources project --model "$model" --permission-mode bypassPermissions --no-session-persistence "$prompt") ;;
    copilot) model="default (see session events)"
             cmd=(env COPILOT_HOME="$work.chome" copilot -p "$prompt" --allow-all-tools) ;;
    copilot-sol) model=gpt-6.1-sol
             cmd=(env COPILOT_HOME="$work.chome" copilot -p "$prompt" --model "$model" --allow-all-tools) ;;
  esac
}

canary() {
  mkdir -p "$OUT_ROOT"
  for cell in "${CELLS[@]}"; do
    local work; work=$(make_sandbox "$cell")
    build_cmd "$cell" "$CANARY" "$work"
    ( cd "$work" && run_with_timeout 300 "${cmd[@]}" ) > "$OUT_ROOT/canary-$cell.txt" 2>&1
    ( cd "$work" && git ls-files | grep -i delegation ) > "$OUT_ROOT/canary-$cell.files.txt" 2>&1
  done
}

run_one() {
  local scen=$1 cell=$2 n=$3
  local prompt="${PROMPTS[$scen]}"
  local outdir="$OUT_ROOT/$scen-$cell-$n"
  mkdir -p "$outdir"
  local work; work=$(make_sandbox "$cell")
  build_cmd "$cell" "$prompt" "$work"

  local start end rc
  start=$(date -u +%FT%TZ)
  ( cd "$work" && run_with_timeout $TIMEOUT "${cmd[@]}" ) > "$outdir/reply.txt" 2>&1
  rc=$?
  end=$(date -u +%FT%TZ)
  ( cd "$work"; git add -A; git status --porcelain ) > "$outdir/diffstat.txt"
  {
    printf 'command: '; printf '%q ' "${cmd[@]}"; echo
    echo "cwd: $work"; echo "model: $model"
    case "$cell" in copilot*) echo "copilot_home: $work.chome (session events under it)" ;; esac
    echo "start: $start"; echo "end: $end"; echo "exit_code: $rc"
  } > "$outdir/meta.txt"
  echo "$scen-$cell-$n exit=$rc"
}

mkdir -p "$OUT_ROOT"
if [ "${1:-}" = canary ]; then
  canary
elif [ $# -gt 0 ]; then
  for t in "$@"; do s=${t%%-*}; n=${t##*-}; c=${t#*-}; c=${c%-*}; run_one "$s" "$c" "$n"; done
else
  for s in "${SCENARIOS[@]}"; do
    for c in "${CELLS[@]}"; do
      for n in $(seq 1 $RUNS); do run_one "$s" "$c" "$n" & done
    done
    wait
  done
fi
