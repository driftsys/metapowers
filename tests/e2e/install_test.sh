#!/usr/bin/env bash
# End-to-end test: install the metapowers bundle into a fresh consumer project
# and verify that all expected per-client outputs land in the right places with
# the right content.
#
# Run with: bash tools/bash_unit tests/e2e/install_test.sh
#
# Assumptions:
# - `upskill` is on PATH (version >= 0.7.2 — supporting-resource delivery, e.g.
#   the working-memory-lifecycle rule's wip-gate.sh, requires 0.7.2)
# - The script is invoked from the metapowers repo root (justfile recipe takes
#   care of this) — we resolve the repo root via `git rev-parse` to be safe.

set -u

METAPOWERS_ROOT="$(git rev-parse --show-toplevel)"
BUNDLE_PATH="$METAPOWERS_ROOT/skills/metapowers.bundle.yaml"

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
    assert "[ -f .claude/rules/karpathy-guidelines.md ]" \
        "expected Claude rule output at .claude/rules/karpathy-guidelines.md"
}

test_install_writes_copilot_instructions() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .github/instructions/karpathy-guidelines.instructions.md ]" \
        "expected Copilot output at .github/instructions/karpathy-guidelines.instructions.md"
}

test_install_writes_opencode_rule() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .agents/rules/karpathy-guidelines/RULE.md ]" \
        "expected opencode canonical-store output at .agents/rules/karpathy-guidelines/RULE.md"
}

test_install_delivers_rule_supporting_resource() {
    # The working-memory-lifecycle rule ships wip-gate.sh as a supporting resource.
    # upskill >= 0.7.2 must deliver sibling resource files alongside the rule body,
    # not just the entrypoint (regression guard for upskill#199).
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/working-memory-lifecycle/wip-gate.sh ]" \
        "expected wip-gate.sh delivered next to the Claude rule"
    assert "[ -f .agents/rules/working-memory-lifecycle/wip-gate.sh ]" \
        "expected wip-gate.sh delivered next to the opencode rule"
    assert "grep -q 'WIP-gate' .claude/rules/working-memory-lifecycle/wip-gate.sh" \
        "expected the delivered wip-gate.sh to carry its content, not be empty"
}

test_rule_body_preserves_content() {
    upskill add "$BUNDLE_PATH" --project --quiet
    # Spot-check: a known phrase from the SSOT body must survive generation.
    assert "grep -q 'Surgical Changes' .claude/rules/karpathy-guidelines.md" \
        "expected 'Surgical Changes' phrase in the generated rule body"
}

test_lockfile_records_rule() {
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .upskill-lock.json ]" \
        "expected lockfile at .upskill-lock.json"
    assert "grep -q 'karpathy-guidelines' .upskill-lock.json" \
        "expected karpathy-guidelines entry in the lockfile"
}

test_lockfile_records_bundle_resolution() {
    upskill add "$BUNDLE_PATH" --project --quiet
    # Transitively-resolved bundle (`requires: superpowers`) must appear too —
    # this verifies the bundle dependency walk worked.
    assert "grep -q 'superpowers' .upskill-lock.json" \
        "expected superpowers bundle to be recorded in the lockfile after transitive resolution"
}

test_plugin_install_does_not_block_items() {
    # If `claude` CLI is missing (typical on CI), the Superpowers plugin install
    # MUST warn-skip and the rest of the bundle MUST still install
    # (format-spec §3.7 warn-skip policy).
    upskill add "$BUNDLE_PATH" --project --quiet
    assert "[ -f .claude/rules/karpathy-guidelines.md ]" \
        "rule install must succeed regardless of plugin install outcome"
}
