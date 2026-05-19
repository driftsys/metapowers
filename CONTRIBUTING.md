# Contributing to metapowers

For org-wide guidelines — AI policy, commit messages, pull request workflow,
code review, issue model, and documentation style — see the
[driftsys contributing guide][org-contributing] and [process][org-process].

This file covers what is specific to the metapowers repository.

[org-contributing]: https://github.com/driftsys/.github/blob/main/CONTRIBUTING.md
[org-process]: https://github.com/driftsys/.github/blob/main/PROCESS.md

## Reporting issues

Open bugs and feature requests at
<https://github.com/driftsys/metapowers/issues>.

## What metapowers contains

metapowers is a **source registry** for AI-assistance content, distributed via
[upskill](https://github.com/driftsys/upskill). It contains three kinds of
items plus bundle manifests:

| Kind   | Entrypoint    | Purpose                                   |
| ------ | ------------- | ----------------------------------------- |
| Skill  | `SKILL.md`    | On-demand procedural content              |
| Rule   | `RULE.md`     | Always-on behavioural guidance            |
| Bundle | `*.bundle.md` | Curated set of items distributed together |

See the [upskill format spec][format-spec] for the on-disk contract.

[format-spec]: https://github.com/driftsys/upskill/blob/main/docs/format-spec.md

## Repository layout

```text
metapowers/
├── skills/                   # SSOT items — skills and rules
│   └── <name>/
│       ├── SKILL.md          # or RULE.md
│       └── ...               # optional supporting resources
├── bundles/                  # bundle manifests
│   └── <name>.bundle.md
└── docs/                     # reference documentation
```

## Dev setup

You need:

- **[just]**: command runner
- **[upskill]**: for `lint`, `fmt`, and `new` commands
- **[dprint]**: Markdown formatter
- **[markdownlint-cli2]**: Markdown linter (invoked via `npx`)

```bash
# Clone
git clone https://github.com/driftsys/metapowers.git
cd metapowers
./bootstrap          # post-clone setup
```

[just]: https://github.com/casey/just
[upskill]: https://github.com/driftsys/upskill
[dprint]: https://dprint.dev
[markdownlint-cli2]: https://github.com/DavidAnson/markdownlint-cli2

## Authoring workflow

### Create a new item

```bash
upskill new skill <name>     # scaffolds skills/<name>/SKILL.md
upskill new rule <name>      # scaffolds skills/<name>/RULE.md
```

### Validate before commit

```bash
just fmt                     # format Markdown (community files + docs/)
just lint                    # lint Markdown (dprint check + markdownlint)
just verify                  # commit lint + markdown lint — run before PR

upskill lint                 # validate items against the format spec
upskill lint --strict        # CI mode (warnings become errors)
upskill fmt                  # canonicalise YAML frontmatter
```

`just fmt` / `just lint` cover community files and `docs/`. Item content
under `skills/` and `bundles/` is validated and formatted via `upskill`.

## Project philosophy

metapowers commits to a specific stance:

1. **The code and its tests are co-equal sources of truth.** Code without
   tests is unverified. Tests without code are wishes. Together they are the
   SSOT.

2. **Requirements and architecture are documentation, not source of truth.**
   They exist so humans can understand and evolve the system. When
   documentation and code+tests diverge, the code+tests win and the
   documentation is updated.

3. **TDD discipline is non-negotiable.** Not for code quality alone — for
   hallucination prevention. The red-green-refactor cycle prevents AI
   implementations from claiming success on tests that never ran.

4. **Specs are working memory, not durable artifacts.** Superpowers specs
   and plans live in `.scratch/superpowers/` (gitignored). Durable
   engineering records are extracted into `docs/` only when they carry value
   beyond the implementation session.

5. **metapowers is not spec-driven.** It is explicitly NOT spec-kit or BMAD.
   The spec is not the source of truth. _"Tests are the spec. Code is the
   implementation. Documentation describes both."_

When proposing skills or rules that contradict this stance — for example,
content that treats markdown design docs as contractual or specs as
authoritative — those changes will not be accepted.

## Pull requests

Single PR = item + tests/examples + updated documentation together. Follow
Conventional Commits — `feat`, `fix`, `refactor`, `docs`, `chore`. Imperative
mood.
