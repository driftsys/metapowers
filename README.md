# metapowers

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Extend [Superpowers](https://github.com/obra/superpowers) with a structured documentation framework. metapowers is a skills registry that turns engineering artifacts into durable records.

## What metapowers is

metapowers is part of the [driftsys](https://github.com/driftsys) project. It distributes skills, rules, and bundles via [upskill](https://github.com/driftsys/upskill) to Claude Code, GitHub Copilot, and opencode.

**The code and its tests are the source of truth. Requirements and architecture are how humans understand and evolve the system. TDD is how we make sure the truth stays trustworthy.**

metapowers extends Superpowers' TDD discipline by capturing the working artifacts (specs, plans, architecture decisions) into durable engineering records — so the _why_ and _how_ remain clear as code evolves.

- **Skills** teach procedures: "to accomplish X, follow these steps"
- **Rules** provide always-on guidance: "never do X", "always check Y"
- **Bundles** curate collections for specific workflows

Content is authored once in canonical form, then distributed to consuming repositories via upskill.

## Quick start

Requires [upskill](https://github.com/driftsys/upskill) **≥ 0.7.2** — earlier
versions do not install items' supporting resources (e.g. the
`working-memory-lifecycle` rule's `wip-gate.sh` CI script).

```bash
# Install a skill into your project
upskill add driftsys/metapowers

# Or install a curated bundle
upskill add driftsys/metapowers baseline
```

See the [upskill documentation](https://driftsys.github.io/upskill/) for more commands.

## Documentation

- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute skills, rules, and bundles
- [docs/](docs/) — Reference documentation
- [Superpowers documentation](https://github.com/obra/superpowers)
- [upskill documentation](https://driftsys.github.io/upskill/)

## Community

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for our community standards.

## License

MIT

<!-- git-std:bootstrap -->

## Post-clone setup

Run `./bootstrap` after `git clone` or `git worktree add`.
