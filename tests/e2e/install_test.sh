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

test_baseline_installs_both_rules() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "expected scope-discipline from the metapowers baseline"
    assert "[ -f .claude/rules/international-english.md ]" \
        "expected international-english from the metapowers baseline"
    assert_equals "international-english.md scope-discipline.md" \
        "$(ls .claude/rules | tr '\n' ' ' | sed 's/ $//')" \
        "the metapowers baseline must install exactly scope-discipline and international-english for Claude"
    assert "[ -f .github/instructions/international-english.instructions.md ]" \
        "expected Copilot international-english output from the metapowers baseline"
    assert "[ -f .agents/rules/international-english/RULE.md ]" \
        "expected opencode international-english output from the metapowers baseline"
}

test_core_bundle_installs_both_rules() {
    upskill add "$CORE_BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "expected scope-discipline from metapowers-core"
    assert "[ -f .claude/rules/international-english.md ]" \
        "expected international-english from metapowers-core"
    assert_equals "international-english.md scope-discipline.md" \
        "$(ls .claude/rules | tr '\n' ' ' | sed 's/ $//')" \
        "metapowers-core must install exactly scope-discipline and international-english for Claude"
    assert "[ -f .github/instructions/international-english.instructions.md ]" \
        "expected Copilot international-english output from metapowers-core"
    assert "[ -f .agents/rules/international-english/RULE.md ]" \
        "expected opencode international-english output from metapowers-core"
    # metapowers-core must stand alone: no other bundle may be recorded.
    assert "! grep -q '\"name\": \"superpowers\"' .upskill-lock.json" \
        "metapowers-core must not pull in the superpowers bundle"
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
    # Transitively-resolved bundle (`requires: superpowers`) must appear too —
    # this verifies the bundle dependency walk worked. The same walk must record
    # metapowers-core (`requires: metapowers-core`) as a dependency of metapowers.
    assert "grep -q 'superpowers' .upskill-lock.json" \
        "expected superpowers bundle to be recorded in the lockfile after transitive resolution"
    assert "grep -q '\"name\": \"metapowers-core\"' .upskill-lock.json" \
        "expected metapowers-core bundle to be recorded in the lockfile after transitive resolution"
}

test_plugin_install_does_not_block_items() {
    # If `claude` CLI is missing (typical on CI), the Superpowers plugin install
    # MUST warn-skip and the rest of the bundle MUST still install
    # (format-spec §3.7 warn-skip policy).
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/scope-discipline.md ]" \
        "rule install must succeed regardless of plugin install outcome"
}
