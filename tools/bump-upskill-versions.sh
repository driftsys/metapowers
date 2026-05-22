#!/usr/bin/env bash
# Bump `metadata.version` in every upskill SSOT file to the version passed in $1.
#
# Invoked by .githooks/post-version.hooks during `git std bump`. Auto-discovers
# every bundle manifest and every RULE.md / SKILL.md / AGENT.md under skills/
# so that new items get bumped without editing config — a workaround until
# git-std supports globs in `[[version_files]]` (driftsys/git-std#506).
#
# Match strategy: the line `  version: "..."` (2-space indent — the canonical
# nesting under `metadata:`). Top-level YAML keys are flush-left and untouched.
# The hook stages every file it modifies so git-std's subsequent commit picks
# them up (git-std does not auto-stage hook-modified files).

set -euo pipefail

new_version="${1:?usage: $0 <new-version>}"

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

files=()
while IFS= read -r -d '' f; do
    files+=("$f")
done < <(
    find skills -maxdepth 1 -name '*.bundle.yaml' -print0 2>/dev/null
    find skills -mindepth 2 -maxdepth 2 \( -name 'RULE.md' -o -name 'SKILL.md' -o -name 'AGENT.md' \) -print0 2>/dev/null
)

count=0
for file in "${files[@]}"; do
    if grep -qE '^  version: "[^"]*"$' "$file"; then
        sed -i.bak -E 's/^  version: "[^"]*"$/  version: "'"$new_version"'"/' "$file"
        rm -f "$file.bak"
        git add "$file"
        printf '  %s: bumped to %s\n' "$file" "$new_version"
        count=$((count + 1))
    fi
done

printf 'Bumped %d upskill SSOT files to %s\n' "$count" "$new_version"
