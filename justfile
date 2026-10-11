[private]
default:
    @just --list

# Format community files, docs/, and skills/
fmt:
    dprint fmt
    npx markdownlint-cli2 --fix
    upskill fmt skills

# Lint community files, docs/, and skills/
lint:
    dprint check
    npx markdownlint-cli2
    upskill lint skills --strict

# Run install round-trip, reference regression and worktree observer tests
test:
    python3 tests/spec/sdd-gardening/test_reference_regressions.py
    bash tools/bash_unit tests/e2e/install_test.sh
    PYTHONDONTWRITEBYTECODE=1 python3 tests/spec/sdd-gardening/worktree-observer.test.py
    PYTHONDONTWRITEBYTECODE=1 python3 tests/spec/sdd-gardening/check-observer-mutations.py

# Validate commits on branch + lint + e2e tests — run before PR
verify:
    git std lint --range main..HEAD
    just lint
    just test

# Bump version, update changelog, commit, and tag
release:
    git std bump
