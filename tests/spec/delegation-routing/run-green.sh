#!/usr/bin/env bash
# GREEN-phase runner for delegation-routing. Usage: run-green.sh [scenario-cell-n ...] | canary
# Run it through `bash -lc` so claude and upskill are on PATH.
# The whole bundle (delegation-basics, delegation-classes, delegation-routing) is
# installed into each fixture copy with `upskill add <bundle> --project --claude`
# and committed with the fixture, so the agent diff excludes it.
# Isolation: claude uses --setting-sources project (no user rules, CLAUDE.md,
# plugins); upskill runs with HOME set to an empty directory.
# The transcript (stream-json) is kept to see tool calls; meta.txt records whether
# the run invoked the delegation-routing skill.
# The copilot-sol cell runs Copilot CLI with --model gpt-6.1-sol, installs with --copilot,
# and isolates with COPILOT_HOME=<empty dir>. ONLY_CELLS limits the cells.
set -u
# Remove the copies of the Copilot login that copilot-sol-home.sh creates.
COPILOT_SOL_HOMES=$(mktemp); export COPILOT_SOL_HOMES
trap 'while read -r d; do rm -rf "$d"; done < "$COPILOT_SOL_HOMES"; rm -f "$COPILOT_SOL_HOMES"' EXIT
HERE="$(cd "$(dirname "$0")" && pwd)"
OUT_ROOT="${OUT_ROOT:-$HERE/runs/green-2026-11-26}"
BUNDLE="$(cd "$HERE/../../../skills" && pwd)/delegation-policies.bundle.yaml"
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
CANARY="${CANARY:-Which skill would you load before dispatching subagents for a classified task, and what is its first sentence?}"
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

make_sandbox() {
  local cell=${1:-claude} client=--claude
  [ "$cell" = copilot-sol ] && client=--copilot
  local work; work=$(mktemp -d)
  cp -R "$HERE/fixture/." "$work/"
  mkdir -p "$work.home" "$work.chome"
  [ "$cell" = copilot-sol ] && "$HERE/../copilot-sol-home.sh" "$work.chome"
  ( cd "$work" && git init -q && git add -A && git -c user.email=t@t -c user.name=t commit -q -m fixture
    HOME="$work.home" upskill add "$BUNDLE" --project $client --quiet >/dev/null 2>&1
    git add -A && git -c user.email=t@t -c user.name=t commit -q -m "install delegation-policies" )
  echo "$work"
}

build_cmd() { # sets cmd, model
  local cell=$1 prompt=$2 work=${3:-}
  case $cell in
    opus)   model=claude-opus-5-5 ;;
    sonnet) model=claude-sonnet-5-5 ;;
    copilot-sol) model=gpt-6.1-sol ;;
  esac
  cmd=(claude -p --setting-sources project --model "$model" --permission-mode bypassPermissions --no-session-persistence --output-format stream-json --verbose "$prompt")
  if [ "$cell" = copilot-sol ]; then
    cmd=(env COPILOT_HOME="$work.chome" copilot -p "$prompt" --model "$model" --allow-all-tools)
  fi
}

extract() { # transcript.jsonl -> reply.txt, skill flag on stdout
  local dir=$1 chome=${2:-}
  if [ -n "$chome" ]; then # copilot: plain-text reply, session events under COPILOT_HOME
    cp "$dir/transcript.jsonl" "$dir/reply.txt"
    if grep -rqi "delegation-routing" "$chome" 2>/dev/null; then echo yes-in-session-events; else echo no; fi
    return
  fi
  jq -r 'select(.type=="result") | .result' "$dir/transcript.jsonl" > "$dir/reply.txt" 2>/dev/null
  if jq -e 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Skill" and ((.input.skill // "") | test("delegation-routing")))' "$dir/transcript.jsonl" >/dev/null 2>&1; then
    echo yes
  elif jq -e 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use" and .name=="Read" and ((.input.file_path // "") | test("delegation-routing")))' "$dir/transcript.jsonl" >/dev/null 2>&1; then
    echo read-file
  else
    echo no
  fi
}

canary() {
  mkdir -p "$OUT_ROOT"
  for cell in "${CELLS[@]}"; do
    local work; work=$(make_sandbox "$cell")
    build_cmd "$cell" "$CANARY" "$work"
    mkdir -p "$OUT_ROOT/canary-$cell"
    ( cd "$work" && run_with_timeout 300 "${cmd[@]}" ) > "$OUT_ROOT/canary-$cell/transcript.jsonl" 2>&1
    extract "$OUT_ROOT/canary-$cell" "$([ "$cell" = copilot-sol ] && echo "$work.chome")" > "$OUT_ROOT/canary-$cell/skill.txt"
    cp "$OUT_ROOT/canary-$cell/reply.txt" "$OUT_ROOT/canary-$cell.txt"
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

  local start end rc skill
  start=$(date -u +%FT%TZ)
  ( cd "$work" && run_with_timeout $TIMEOUT "${cmd[@]}" ) > "$outdir/transcript.jsonl" 2>&1
  rc=$?
  end=$(date -u +%FT%TZ)
  skill=$(extract "$outdir" "$([ "$cell" = copilot-sol ] && echo "$work.chome")")
  ( cd "$work"; git add -A; git status --porcelain ) > "$outdir/diffstat.txt"
  {
    printf 'command: '; printf '%q ' "${cmd[@]}"; echo
    echo "cwd: $work"; echo "model: $model"
    echo "start: $start"; echo "end: $end"; echo "exit_code: $rc"
    echo "invoked_delegation_routing: $skill"
  } > "$outdir/meta.txt"
  echo "$scen-$cell-$n exit=$rc skill=$skill"
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
