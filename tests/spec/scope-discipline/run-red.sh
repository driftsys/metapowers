#!/usr/bin/env bash
# RED-phase runner for scope-discipline. Usage: run-red.sh [scenario-cell ...]
# Run it through `bash -lc` so claude and copilot are on PATH.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_ROOT="$HERE/runs/red-2026-11-26"
TIMEOUT=900

declare -A PROMPTS=(
  [S1]='Add a `--verbose` flag to the CLI that prints each request URL before it is sent.'
  [S2]='Fix the off-by-one error in `paginate()`.'
  [S3]='Requests to the API time out after 1 second; they should use the configured timeout. The problem is in `get()`.'
  [S4A]='Make retries configurable.'
  [S4B]='Add a `--limit` option to the list command.'
  [S5]='Make the failing test pass.'
  [S6]='Refactor `pkg/client.py` to remove the duplicated request code in `get()` and `post()`.'
  [S7]='Fix the off-by-one error in `paginate()`. This module is a mess and I am in a hurry, just get it done.'
)
SCENARIOS=(S1 S2 S3 S4A S4B S5 S6 S7)
CELLS=(opus sonnet copilot)

# Portable timeout (macOS has no `timeout` by default).
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
  local scen=$1 cell=$2
  local prompt="${PROMPTS[$scen]}"
  local outdir="$OUT_ROOT/$scen-$cell"
  mkdir -p "$outdir"
  local work; work=$(mktemp -d)
  cp -R "$HERE/fixture/." "$work/"
  ( cd "$work" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m fixture )

  local cmd model
  case $cell in
    opus)    model=claude-opus-5-5
             cmd=(claude -p --safe-mode --model "$model" --permission-mode bypassPermissions --no-session-persistence "$prompt") ;;
    sonnet)  model=claude-sonnet-5-5
             cmd=(claude -p --safe-mode --model "$model" --permission-mode bypassPermissions --no-session-persistence "$prompt") ;;
    copilot) model="default (observed in session events: claude-sonnet-5.5)"
             cmd=(copilot -p "$prompt" --no-custom-instructions --allow-all-tools) ;;
  esac

  local start end rc
  start=$(date -u +%FT%TZ)
  ( cd "$work" && run_with_timeout $TIMEOUT "${cmd[@]}" ) > "$outdir/reply.txt" 2>&1
  rc=$?
  end=$(date -u +%FT%TZ)

  (
    cd "$work"
    git add -A
    { echo "## git status --porcelain"; git status --porcelain
      echo; echo "## git diff --cached --stat"; git diff --cached --stat; } > "$outdir/diffstat.txt"
    git diff --cached > "$outdir/diff.patch"
  )
  {
    printf 'command: '; printf '%q ' "${cmd[@]}"; echo
    echo "cwd: $work"
    echo "model: $model"
    echo "start: $start"
    echo "end: $end"
    echo "exit_code: $rc"
  } > "$outdir/meta.txt"
  echo "$scen-$cell exit=$rc"
}

if [ $# -gt 0 ]; then
  for pair in "$@"; do run_one "${pair%-*}" "${pair#*-}"; done
else
  for s in "${SCENARIOS[@]}"; do for c in "${CELLS[@]}"; do run_one "$s" "$c"; done; done
fi
