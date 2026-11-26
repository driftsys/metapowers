#!/usr/bin/env bash
# End-to-end test: install the metapowers bundle into a fresh consumer project
# and verify that all expected per-client outputs land in the right places with
# the right content.
#
# Run with: bash tools/bash_unit tests/e2e/install_test.sh
#
# Assumptions:
# - `upskill` is on PATH (version >= 0.7.4 — supporting-resource delivery added in
#   0.7.2; relaxed co-location naming, which lets the sdd-gardener agent keep its
#   divergent name inside the sdd-gardening/ dir, added in 0.7.4)
# - The script is invoked from the metapowers repo root (justfile recipe takes
#   care of this) — we resolve the repo root via `git rev-parse` to be safe.

set -u

METAPOWERS_ROOT="$(git rev-parse --show-toplevel)"
BUNDLE_PATH="$METAPOWERS_ROOT/skills/metapowers.bundle.yaml"
# The metapowers bundle no longer requires gardenpowers, so the tests of the
# gardenpowers items install that bundle directly.
GARDEN_BUNDLE_PATH="$METAPOWERS_ROOT/skills/gardenpowers.bundle.yaml"
DELEGATION_BUNDLE_PATH="$METAPOWERS_ROOT/skills/delegation-policies.bundle.yaml"
# The metapowers-core bundle holds the rules alone, with no Superpowers dependency.
CORE_BUNDLE_PATH="$METAPOWERS_ROOT/skills/metapowers-core.bundle.yaml"

# Per-test fixture: a brand-new temp directory acting as a consumer project.
# `setup` and `teardown` are bash_unit lifecycle hooks invoked for every test.
setup() {
    CONSUMER_DIR="$(mktemp -d)"
    cd "$CONSUMER_DIR" || fail "cannot cd into $CONSUMER_DIR"
    git init --quiet --initial-branch=main
    # Identify ourselves so the empty repo doesn't trip on missing config.
    git config user.email "e2e@metapowers.test"
    git config user.name "metapowers e2e"
}

teardown() {
    cd "$METAPOWERS_ROOT" || return
    rm -rf "$CONSUMER_DIR"
}

# ── Lockfile and output helpers ───────────────────────────────────────────────

# Print the installed items of the lockfile as sorted "kind:name" lines, one
# line per item of any kind (rules, skills, agents, commands, hooks).
lock_items() {
    python3 -c '
import json
lock = json.load(open(".upskill-lock.json"))
print("\n".join(sorted(i["kind"] + ":" + i["name"] for i in lock["items"])))
'
}

# Print the names of the bundle records of the lockfile, sorted, one per line.
lock_bundles() {
    python3 -c '
import json
lock = json.load(open(".upskill-lock.json"))
print("\n".join(sorted(b["name"] for b in lock["bundles"])))
'
}

# Print every file below the given directories, sorted, one per line.
files_under() {
    find "$@" -type f | LC_ALL=C sort
}

# Assert that the install holds exactly the two rules, for every client.
assert_exactly_both_rules() {
    local label="$1"
    assert_equals "rule:international-english
rule:scope-discipline" "$(lock_items)" \
        "$label must install exactly the two rules and no other item"
    assert_equals ".claude/rules/international-english.md
.claude/rules/scope-discipline.md" "$(files_under .claude)" \
        "$label must write exactly the two Claude rule files"
    assert_equals ".github/instructions/international-english.instructions.md
.github/instructions/scope-discipline.instructions.md" "$(files_under .github)" \
        "$label must write exactly the two Copilot instruction files"
    assert_equals ".agents/rules/international-english/RULE.md
.agents/rules/scope-discipline/RULE.md" "$(files_under .agents)" \
        "$label must write exactly the two opencode rule files"
}

# ── Bundle install round-trip ─────────────────────────────────────────────────

test_install_writes_claude_rule() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "expected Claude rule output at .claude/rules/scope-discipline.md"
}

test_install_writes_copilot_instructions() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .github/instructions/scope-discipline.instructions.md ]" \
        "expected Copilot output at .github/instructions/scope-discipline.instructions.md"
}

test_install_writes_opencode_rule() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .agents/rules/scope-discipline/RULE.md ]" \
        "expected opencode canonical-store output at .agents/rules/scope-discipline/RULE.md"
}

test_install_delivers_rule_supporting_resource() {
    # The sdd-working-memory-lifecycle rule ships wip-gate.sh as a supporting resource.
    # upskill >= 0.7.2 must deliver sibling resource files alongside the rule body,
    # not just the entrypoint (regression guard for upskill#199).
    upskill add "$GARDEN_BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/sdd-working-memory-lifecycle/wip-gate.sh ]" \
        "expected wip-gate.sh delivered next to the Claude rule"
    assert "[ -f .agents/rules/sdd-working-memory-lifecycle/wip-gate.sh ]" \
        "expected wip-gate.sh delivered next to the opencode rule"
    assert "grep -q 'WIP-gate' .claude/rules/sdd-working-memory-lifecycle/wip-gate.sh" \
        "expected the delivered wip-gate.sh to carry its content, not be empty"
}

test_colocated_agent_keeps_divergent_name() {
    # The sdd-gardener agent is co-located in the sdd-gardening/ directory but keeps
    # its own divergent name (upskill >= 0.7.4 relaxed co-location naming). It must
    # install under its effective name, not the directory name.
    upskill add "$GARDEN_BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/agents/sdd-gardener.md ]" \
        "expected the agent installed under its divergent name (.claude/agents/sdd-gardener.md)"
    assert "[ ! -f .claude/agents/sdd-gardening.md ]" \
        "agent must NOT install under the directory name (.claude/agents/sdd-gardening.md)"
    assert "[ -f .claude/skills/sdd-gardening/SKILL.md ]" \
        "expected the co-located skill still installed under the directory name"
}

test_baseline_installs_core_rules_and_delegation_policies() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert_equals "rule:delegation-basics
rule:delegation-classes
rule:international-english
rule:scope-discipline
skill:delegation-routing" "$(lock_items)" \
        "the metapowers baseline must install exactly the items of metapowers-core and delegation-policies"
    assert_equals ".claude/rules/delegation-basics.md
.claude/rules/delegation-classes.md
.claude/rules/international-english.md
.claude/rules/scope-discipline.md
.claude/skills/delegation-routing/SKILL.md" "$(files_under .claude)" \
        "the metapowers baseline must write exactly these Claude Code files"
    assert_equals ".github/instructions/delegation-basics.instructions.md
.github/instructions/delegation-classes.instructions.md
.github/instructions/international-english.instructions.md
.github/instructions/scope-discipline.instructions.md
.github/skills/delegation-routing/SKILL.md" "$(files_under .github)" \
        "the metapowers baseline must write exactly these Copilot files"
    assert_equals ".agents/rules/delegation-basics/RULE.md
.agents/rules/delegation-classes/RULE.md
.agents/rules/international-english/RULE.md
.agents/rules/scope-discipline/RULE.md
.agents/skills/delegation-routing/SKILL.md" "$(files_under .agents)" \
        "the metapowers baseline must write exactly these opencode files"
}

test_core_bundle_installs_both_rules() {
    upskill add "$CORE_BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "expected scope-discipline from metapowers-core"
    assert "[ -f .claude/rules/international-english.md ]" \
        "expected international-english from metapowers-core"
    assert_exactly_both_rules "metapowers-core"
    # metapowers-core must stand alone: the lockfile records this bundle only.
    assert_equals "metapowers-core" "$(lock_bundles)" \
        "metapowers-core must be the only bundle recorded in the lockfile"
}

test_rule_body_preserves_content() {
    upskill add "$BUNDLE_PATH" --project --quiet
    # Spot-check: a known phrase from the SSOT body must survive generation.
    assert "grep -q 'Stay within the task' .claude/rules/scope-discipline.md" \
        "expected 'Stay within the task' phrase in the generated rule body"
}

test_lockfile_records_rule() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .upskill-lock.json ]" \
        "expected lockfile at .upskill-lock.json"
    assert "grep -q 'scope-discipline' .upskill-lock.json" \
        "expected scope-discipline entry in the lockfile"
}

test_lockfile_records_bundle_resolution() {
    upskill add "$BUNDLE_PATH" --project --quiet
    # The bundle dependency walk must record exactly metapowers itself and the
    # bundles it requires: delegation-policies, metapowers-core and superpowers.
    assert_equals "delegation-policies
metapowers
metapowers-core
superpowers" "$(lock_bundles)" \
        "expected exactly the delegation-policies, metapowers, metapowers-core and superpowers bundles in the lockfile"
}

test_plugin_install_does_not_block_items() {
    # If `claude` CLI is missing (typical on CI), the Superpowers plugin install
    # MUST warn-skip and the rest of the bundle MUST still install
    # (format-spec §3.7 warn-skip policy).
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "rule install must succeed regardless of plugin install outcome"
}

# ── delegation-policies bundle ────────────────────────────────────────────────

# Install the delegation-policies bundle without touching the real user
# configuration: HOME points at a temp directory, and stub client CLIs that
# exit 1 come first on PATH. The bundle declares no plugins, so no stub should
# run.
dp_install() {
    local isolation cli
    isolation="$(mktemp -d)"
    mkdir -p "$isolation/bin" "$isolation/home"
    for cli in claude copilot code opencode; do
        printf '#!/bin/sh\nexit 1\n' >"$isolation/bin/$cli"
        chmod +x "$isolation/bin/$cli"
    done
    HOME="$isolation/home" PATH="$isolation/bin:$PATH" \
        upskill add "$DELEGATION_BUNDLE_PATH" --project --quiet
    rm -rf "$isolation"
}

test_delegation_policies_installs_exactly_its_items() {
    dp_install
    assert_equals "rule:delegation-basics
rule:delegation-classes
skill:delegation-routing" "$(lock_items)" \
        "the bundle must install exactly two rules and one skill"
    assert_equals "delegation-policies" "$(lock_bundles)" \
        "delegation-policies must be the only bundle recorded in the lockfile"
    assert_equals ".claude/rules/delegation-basics.md
.claude/rules/delegation-classes.md
.claude/skills/delegation-routing/SKILL.md" "$(files_under .claude)" \
        "the bundle must write exactly these Claude Code files"
    assert_equals ".github/instructions/delegation-basics.instructions.md
.github/instructions/delegation-classes.instructions.md
.github/skills/delegation-routing/SKILL.md" "$(files_under .github)" \
        "the bundle must write exactly these Copilot files"
    assert_equals ".agents/rules/delegation-basics/RULE.md
.agents/rules/delegation-classes/RULE.md
.agents/skills/delegation-routing/SKILL.md" "$(files_under .agents)" \
        "the bundle must write exactly these opencode files"
}

test_delegation_routing_skill_keeps_only_the_client_model_table() {
    dp_install
    local claude_skill=.claude/skills/delegation-routing/SKILL.md
    local copilot_skill=.github/skills/delegation-routing/SKILL.md
    assert "grep -qF 'Claude Code offers one model family' $claude_skill" \
        "the Claude Code skill must keep the Claude block"
    assert "! grep -qF 'gpt-*-sol' $claude_skill" \
        "the Claude Code skill must not hold the Copilot or Codex tables"
    assert "! grep -qF 'Codex offers one model family' $claude_skill" \
        "the Claude Code skill must not hold the Codex block"
    assert "! grep -qF '@client' $claude_skill" \
        "the Claude Code skill must not keep a client delimiter"
    assert "grep -qF 'gpt-*-sol' $copilot_skill" \
        "the Copilot skill must keep the Copilot table"
    assert "! grep -qF 'Claude Code offers one model family' $copilot_skill" \
        "the Copilot skill must not hold the Claude-only text"
    assert "! grep -qF 'Codex offers one model family' $copilot_skill" \
        "the Copilot skill must not hold the Codex block"
    assert "! grep -qF '@client' $copilot_skill" \
        "the Copilot skill must not keep a client delimiter"
}

test_model_routing_rule_is_gone() {
    # The rule was renamed to delegation-basics.
    assert "[ ! -e \"$METAPOWERS_ROOT/skills/model-routing\" ]" \
        "skills/model-routing must not exist after the rename to delegation-basics"
}
