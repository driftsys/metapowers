# AGENTS.md

Instructions for AI coding agents working in this repository.

## Project

metapowers is a **source registry** for AI-assistance content — skills, rules,
and bundles — distributed via [upskill](https://github.com/driftsys/upskill) to
Claude Code, GitHub Copilot, and opencode.

metapowers has no runtime of its own. It is content that upskill installs into
consuming repositories. This repo holds canonical SSOT (single source of truth)
items in the [portable format](https://github.com/driftsys/upskill/blob/main/docs/format-spec.md);
per-client outputs are generated at install time.

metapowers extends [Superpowers](https://github.com/obra/superpowers) by adding
the engineering-documentation layer: it turns the working artifacts Superpowers
produces (specs, plans) into durable engineering records (requirements,
architecture, design, decisions).

## Project philosophy (load-bearing)

These five points are non-negotiable. Skills and rules in this registry MUST
align with them.

1. **The code and its tests are co-equal sources of truth.** Code without tests
   is unverified. Tests without code are wishes. Together they are the SSOT.

2. **Requirements and architecture are documentation, not source of truth.**
   They exist so humans can understand and evolve the system. When documentation
   and code+tests diverge, the code+tests win and the documentation is updated.
   Never the reverse.

3. **TDD discipline is non-negotiable.** Not for code quality alone — for
   hallucination prevention. The red-green-refactor cycle (write failing test
   → verify it fails → implement → verify it passes) prevents AI implementations
   from claiming success on tests that never ran. This is the single most
   important property metapowers preserves from Superpowers.

4. **Specs are working memory, not durable artifacts.** Superpowers' specs and
   plans live in `.scratch/superpowers/` (gitignored). Durable engineering
   records are extracted from them into `docs/` only when they carry value
   beyond the implementation session.

5. **metapowers is not spec-driven.** It is explicitly NOT spec-kit or BMAD.
   The spec is not the source of truth. The framing line is: _"Tests are the
   spec. Code is the implementation. Documentation describes both."_

If you find yourself writing content that suggests specs are authoritative,
that documentation drives implementation, or that markdown design docs are
contractual — stop. Those framings belong to other methodologies, not this one.

## Repository layout

```text
metapowers/
├── skills/                   # SSOT items and bundle manifests
│   ├── <name>/
│   │   ├── SKILL.md          # or RULE.md or AGENT.md
│   │   └── ...               # optional supporting resources
│   └── <name>.bundle.yaml    # bundle manifests live alongside items
├── docs/                     # reference documentation
└── .scratch/superpowers/     # gitignored working memory (specs, plans)
```

`<item-root>` and `<bundle-root>` are both `skills/`. Items live in their own
directories (kind determined by entrypoint filename: `SKILL.md`, `RULE.md`, or
`AGENT.md`). Bundle manifests are flat `*.bundle.yaml` files alongside item
directories. Tracked upstream: a future upskill release may allow separating
bundles into a sibling `bundles/` directory ([upskill#161](https://github.com/driftsys/upskill/issues/161)).

## Conventions metapowers establishes in consuming repos

When metapowers content is installed in a downstream project, it establishes:

```text
docs/
├── requirements/      # human-curated requirements with stable IDs
├── decisions/         # ADRs, promoted from Superpowers specs when warranted
├── architecture/      # component-grouped architecture docs
└── design/            # per-feature design docs, drafted from spec+plan

.scratch/
└── superpowers/       # Superpowers working memory (gitignored)
    ├── specs/
    └── plans/
```

Naming rules:

- **ADRs**: zero-padded four-digit numbering, hyphen-separated slugs
  (`0001-use-grpc-for-ipc.md`). Aligned with MADR / adr-tools.
- **Design docs**: slug only, no date prefix (`auth-token-rotation.md`).
- **Architecture component files**: named after the logical subsystem as the
  team talks about it (`auth-service.md`, not `crate-foo-bar.md`).
- **Requirements**: stable flat numeric IDs (`REQ-0142`). Subsystem grouping
  happens via the file the requirement lives in, not the ID.

## Commands

```bash
just fmt                     # format Markdown (dprint + markdownlint --fix)
just lint                    # lint Markdown (dprint check + markdownlint)
just verify                  # commit lint + markdown lint — run before PR

upskill new skill <name>     # scaffold skills/<name>/SKILL.md
upskill new rule <name>      # scaffold skills/<name>/RULE.md
upskill lint                 # validate items against format spec
upskill lint --strict        # CI mode
upskill fmt                  # canonicalise YAML frontmatter
```

`just fmt` / `just lint` cover community files and `docs/`. Item content under
`skills/` and `bundles/` is validated and formatted via `upskill lint` and
`upskill fmt`.

## Workflow

Follow [CONTRIBUTING.md](CONTRIBUTING.md) for issue model, PR process, and
review flow.

**Agent-specific rules:**

- **Start from the issue.** Read the acceptance criteria, propose an approach,
  and wait for approval before authoring content.
- **One item per directory.** Each skill or rule gets its own directory under
  `skills/`. Do not bundle multiple items into one directory unless they share
  a name and represent a tightly-coupled set (see format spec §2.1).
- **Validate before commit.** Run `upskill lint --strict` and `dprint check`
  before submitting a PR. Generated content must pass both.
- **Single PR = item + examples + docs.** Every pull request ships the
  authored item, any supporting examples, and updated documentation together.
- **Commits.** Use Conventional Commits — `feat`, `fix`, `refactor`, `docs`,
  `chore`. Imperative mood. One commit per PR.

## When authoring skills and rules

- **Skills** teach a procedure. Write them as imperative step-by-step content
  the agent should follow when activated.
- **Rules** constrain behaviour. Write them as standing instructions — what to
  always do or never do — that apply across an entire session.
- Use the philosophy section above as the litmus test. If a skill or rule
  treats markdown specs as authoritative, or bypasses TDD discipline, it does
  not belong in metapowers.

<!-- git-std:bootstrap -->

## Post-clone setup

Run `./bootstrap` after `git clone` or `git worktree add`.
