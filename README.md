# metapowers

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Extend [Superpowers](https://github.com/obra/superpowers) with a structured documentation framework. metapowers is a skills registry that turns engineering artifacts into durable records.

## What metapowers is

metapowers is part of the [driftsys](https://github.com/driftsys) project. It distributes skills, rules, and bundles via [upskill](https://github.com/driftsys/upskill) to Claude Code, GitHub Copilot, and opencode.

**The code and its tests are the source of truth. Requirements and architecture are how humans understand and evolve the system. TDD is how we make sure the truth stays trustworthy.**

metapowers extends Superpowers' TDD discipline by capturing useful decisions, requirements, and design descriptions during development, then reconciling them with code and tests before archiving specs and plans. Code and lasting documentation reference durable records directly, so their rationale remains available when working memory moves.

- **Skills** teach procedures: "to accomplish X, follow these steps"
- **Rules** provide always-on guidance: "never do X", "always check Y"
- **Bundles** curate collections for specific workflows

Content is authored once in canonical form, then distributed to consuming repositories via upskill.

## Quick start

Requires [upskill](https://github.com/driftsys/upskill) **≥ 0.7.4** — earlier
versions do not install items' supporting resources (e.g. the
`sdd-working-memory-lifecycle` rule's `wip-gate.sh` CI script, added in 0.7.2) and do
not support a co-located agent keeping a divergent name (the `sdd-gardener` agent
lives in the `sdd-gardening/` directory; relaxed co-location naming landed in
0.7.4).

```bash
# Install the full metapowers registry into your project
upskill add driftsys/metapowers

# Or install a single curated bundle (e.g. the metapowers baseline)
upskill add driftsys/metapowers metapowers
```

The metapowers baseline requires Superpowers and the `metapowers-core` and
`delegation-policies` bundles. The `metapowers-core` bundle installs the
scope-discipline and international-english rules alone, without Superpowers.

See the [upskill documentation](https://driftsys.github.io/upskill/) for more commands.

## upskill plugins

This repository publishes one plugin named `upskill` for each client: one for
Claude Code and one for Copilot CLI. Each plugin is the upskill integration for
that client. Today it does one thing: when a session starts, it reports the
available upskill updates.

- In Claude Code, the plugin runs `upskill update --notice`. The user sees the
  line at the start of the session, once for each set of updates, and the agent
  receives it.
- In Copilot CLI, only the agent receives the line, so the plugin asks the agent
  to tell the user. It runs `upskill update --notice --repeat`, so the line is
  given at every session start until `upskill update` runs.

The Claude Code plugin needs upskill 0.9.0 or later on your `PATH`, and the
Copilot CLI plugin needs upskill 0.9.1 or later. With an older binary the
Copilot CLI plugin prints nothing.

The sources are maintained in
[driftsys/upskill](https://github.com/driftsys/upskill) under `plugins/`. The
copy in this repository is a published copy.

```bash
# Claude Code
claude plugin marketplace add driftsys/metapowers
claude plugin install upskill@metapowers

# Copilot CLI
copilot plugin marketplace add driftsys/metapowers
copilot plugin install upskill@metapowers
```

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
