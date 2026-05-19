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

# Validate commits on branch and lint — run before PR
verify:
    git std lint --range main..HEAD
    just lint

# Bump version, update changelog, commit, and tag
release:
    git std bump
