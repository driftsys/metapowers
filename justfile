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

# Run end-to-end install round-trip tests
test:
    bash tools/bash_unit tests/e2e/install_test.sh

# Validate commits on branch + lint + e2e tests — run before PR
verify:
    git std lint --range main..HEAD
    just lint
    just test

# Bump version, update changelog, commit, and tag
release:
    git std bump
