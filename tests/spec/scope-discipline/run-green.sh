#!/usr/bin/env bash
# GREEN-phase runner for scope-discipline. Usage: run-green.sh [scenario-cell ...] | canary
# Run it through `bash -lc` so claude, copilot and upskill are on PATH.
# The rule is installed with upskill (project scope, claude + copilot) and committed
# together with the fixture, so the agent's diff excludes it.
# Isolation: claude uses --setting-sources project (no user rules, CLAUDE.md, plugins);
# copilot uses COPILOT_HOME=<empty dir> (no ~/.copilot/instructions).
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_ROOT="${OUT_ROOT:-$HERE/runs/green-2026-11-26}"
RULE_SRC=~/Workspace/driftsys/metapowers/.claude/worktrees/feat/scope-discipline
TIMEOUT=900

declare -A PROMPTS=(
  [S1]='Add a `--verbose` flag to the CLI that prints each request URL before it is sent.'
  [S3]='Requests to the API time out after 1 second; they should use the configured timeout. The problem is in `get()`.'
  [S4A]='Make retries configurable.'
  [S4B]='Add a `--limit` option to the list command.'
  [S5]='Make the failing test pass.'
  [S6]='Refactor `pkg/client.py` to remove the duplicated request code in `get()` and `post()`.'
)
CANARY='Quote verbatim any instruction in your context containing '"'Stay within the task', 'Surgical Changes', 'international-english' or 'model-routing'"'. If none, answer NONE.'
RUNS=(S1-sonnet S3-opus S3-sonnet S3-copilot S4A-opus S4A-sonnet S4A-copilot S4B-opus S4B-sonnet S4B-copilot S5-opus S5-sonnet S5-copilot S6-sonnet S6-copilot)

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

make_sandbox() {
  local work; work=$(mktemp -d)
  cp -R "$HERE/fixture/." "$work/"
  mkdir -p "$work.home" "$work.chome"
  ( cd "$work" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m fixture
    HOME="$work.home" upskill add "$RULE_SRC" scope-discipline --project --claude --copilot --quiet >/dev/null 2>&1
    git add -A && git -c user.email=t@t -c user.name=t commit -q -m "install scope-discipline" )
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
  esac
}

canary() {
  for cell in opus sonnet copilot; do
    local work; work=$(make_sandbox)
    build_cmd $cell "$CANARY" "$work"
    ( cd "$work" && run_with_timeout 300 "${cmd[@]}" ) > "$OUT_ROOT/canary-$cell.txt" 2>&1
  done
}

run_one() {
  local scen=$1 cell=$2
  local prompt="${PROMPTS[$scen]}"
  local outdir="$OUT_ROOT/$scen-$cell"
  mkdir -p "$outdir"
  local work; work=$(make_sandbox)
  build_cmd $cell "$prompt" "$work"
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
    [ "$cell" = copilot ] && echo "copilot_home: $work.chome (session events under it)"
    echo "start: $start"
    echo "end: $end"
    echo "exit_code: $rc"
  } > "$outdir/meta.txt"
  echo "$scen-$cell exit=$rc"
}

mkdir -p "$OUT_ROOT"
if [ "${1:-}" = canary ]; then canary
elif [ $# -gt 0 ]; then for r in "$@"; do run_one "${r%-*}" "${r#*-}"; done
else for r in "${RUNS[@]}"; do run_one "${r%-*}" "${r#*-}"; done
fi
