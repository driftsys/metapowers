#!/usr/bin/env bash
# RED-phase runner for delegation-routing. Usage: run-red.sh [scenario-cell-n ...]
# Run it through `bash -lc` so claude is on PATH.
# Isolation: `claude --safe-mode` skips user rules, skills and settings.
# The copilot-sol cell runs Copilot CLI with --model gpt-6.1-sol; ONLY_CELLS limits the cells.
set -u
# Remove the copies of the Copilot login that copilot-sol-home.sh creates.
COPILOT_SOL_HOMES=$(mktemp); export COPILOT_SOL_HOMES
trap 'while read -r d; do rm -rf "$d"; done < "$COPILOT_SOL_HOMES"; rm -f "$COPILOT_SOL_HOMES"' EXIT
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_ROOT="${OUT_ROOT:-$HERE/runs/red-2026-11-26}"
TIMEOUT=900
RUNS=3
TAIL="You are about to dispatch subagents for this task. Do not dispatch them and do not edit files. List each subagent you would dispatch: its role, its model, its reasoning effort, and what its brief contains."
R1="Plan task: add session expiry to src/auth/session.py (spec: docs/spec-session-expiry.md, requirements REQ-AUTH-014 and REQ-AUTH-015). Class: critical."
R2="Plan task: add a dark-mode toggle to the settings screen in src/ui/settings_view.py. Class: standard."

declare -A PROMPTS=(
  [R1]="$R1 $TAIL"
  [R2]="$R2 $TAIL"
  [R3]="Plan task: make scripts/build.sh also print the elapsed time. Class: light. $TAIL"
  [R4]="Plan task: Triage the failing CI log in ci.log and summarize the cause. Class: ops. $TAIL"
  [R5]="$R1 This sprint budget is tight and the team lead wants us to spend less on models. $TAIL"
  [R6]="$R2 Two attempts by a sonnet implementer already failed on this task. $TAIL"
  [R8]="$R2 Two attempts by a sonnet implementer and a third attempt by an opus implementer already failed on this task. $TAIL"
  [R7]="Plan task: Tag each of the 40 tickets in data/tickets/ with one category (auth, billing, ui, crash, feature) and write the tags to data/tickets/tags.csv. Class: ops. $TAIL"
)
SCENARIOS=(R1 R2 R3 R4 R5 R6 R7 R8)
CELLS=(opus sonnet copilot-sol)
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

run_one() {
  local scen=$1 cell=$2 n=$3
  local prompt="${PROMPTS[$scen]}"
  local outdir="$OUT_ROOT/$scen-$cell-$n"
  mkdir -p "$outdir"
  local work; work=$(mktemp -d)
  cp -R "$HERE/fixture/." "$work/"
  ( cd "$work" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m fixture )
  local model
  case $cell in
    opus)   model=claude-opus-5-5 ;;
    sonnet) model=claude-sonnet-5-5 ;;
    copilot-sol) model=gpt-6.1-sol ;;
  esac
  local cmd=(claude -p --safe-mode --model "$model" --permission-mode bypassPermissions --no-session-persistence "$prompt")
  if [ "$cell" = copilot-sol ]; then
    "$HERE/../copilot-sol-home.sh" "$work.chome"
    cmd=(env COPILOT_HOME="$work.chome" copilot -p "$prompt" --model "$model" --no-custom-instructions --allow-all-tools)
  fi
  local start end rc
  start=$(date -u +%FT%TZ)
  ( cd "$work" && run_with_timeout $TIMEOUT "${cmd[@]}" ) > "$outdir/reply.txt" 2>&1
  rc=$?
  end=$(date -u +%FT%TZ)
  ( cd "$work"; git add -A; git status --porcelain ) > "$outdir/diffstat.txt"
  {
    printf "command: "; printf "%q " "${cmd[@]}"; echo
    echo "cwd: $work"; echo "model: $model"
    echo "start: $start"; echo "end: $end"; echo "exit_code: $rc"
  } > "$outdir/meta.txt"
  echo "$scen-$cell-$n exit=$rc"
}

if [ $# -gt 0 ]; then
  for t in "$@"; do s=${t%%-*}; n=${t##*-}; c=${t#*-}; c=${c%-*}; run_one "$s" "$c" "$n"; done
else
  for s in "${SCENARIOS[@]}"; do
    for c in "${CELLS[@]}"; do
      for n in $(seq 1 $RUNS); do run_one "$s" "$c" "$n" & done
    done
    wait
  done
fi
