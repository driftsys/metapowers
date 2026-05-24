# Curated Skills Expansion — Design Spec

## Summary

Expand `driftsys/metapowers` from 1 rule (karpathy-guidelines) to a curated
collection of 20 original skills + rules organized into 6 categories. All
content is original (written from scratch) because the ecosystem has no
high-quality portable content in these areas.

## Context

### Ecosystem gap analysis (2026-05-24)

| Area | Community content | Quality | Verdict |
|------|-------------------|---------|---------|
| Architecture (DDD, EDA, reactive) | None | — | Write from scratch |
| Security review | Partial (PR review rule) | 2/5 | Write from scratch |
| Privacy/GDPR | None | — | Write from scratch |
| Rust async/tokio | Generic Rust rule | 3/5 | Write from scratch |
| Kotlin coroutines/Flow | Framework rules only | 2/5 | Write from scratch |
| TypeScript strict/async | Generic TS quality rule | 3/5 | Write from scratch |
| Testing taxonomy | Framework-specific (Jest, Vitest) | 3/5 | Write strategy layer |
| Technical writing | How-to docs rule only | 2/5 | Write from scratch |
| Diagramming (Mermaid, PlantUML, draw.io) | MCP tools only, no authoring guidance | — | Write from scratch |
| Typography/layout | Nothing for docs | — | Write from scratch |
| Product ownership (ATDD, event storming, story mapping) | None | — | Write from scratch |

### What the ecosystem provides (not our lane)

- Framework cheat sheets (Next.js, Laravel, FastAPI, Flutter) — 80% of content
- Personal style preferences (formatting, naming)
- Meta-rules (anti-sycophancy, commit messages)

### Driftsys lane

Not "how to use the tool" but "how to think about the problem." Discipline,
precision, human-serving.

## Philosophy alignment

Every skill in this expansion MUST satisfy:

1. **Enforces discipline** — makes the agent more rigorous, not just faster
2. **Is human-serving** — output helps humans understand, review, or maintain
3. **Has precision** — specific actionable instructions (not vague best practices)
4. **Is client-portable** — works across Claude, Copilot, opencode
5. **Passes lint** — valid upskill format, no warnings under `--strict`
6. **Respects metapowers philosophy** — code+tests are SSOT, docs describe both

## Architecture

### Relationship to superpowers

```
superpowers (14 process skills)
    ↑ requires
metapowers (20 original items + karpathy-guidelines rule)
```

Superpowers teaches the agent HOW TO WORK (TDD, debugging, planning).
Metapowers teaches the agent WHAT TO THINK ABOUT (architecture, safety,
domains, documentation, product).

### Umbrella pattern

Two categories use the umbrella pattern (rule + expert skills):

- `software-architecture`: rule (always-loaded invariants) + 3 expert skills
- `product-discipline`: rule (always-loaded invariants) + 5 expert skills

The rule carries principles that always apply. The skills are loaded on-demand
when facing specific problems.

## Skill Inventory

### Category 1: Architecture (rule + 3 experts)

| Item | Kind | Purpose |
|------|------|---------|
| `software-architecture` | rule + skill | Always: failure isolation, explicit contracts, data ownership, async at boundaries. On-demand: pattern selection, trade-off analysis, C4 modeling |
| `domain-driven-design` | skill | Bounded contexts, aggregates, domain events, ubiquitous language, anti-corruption layers, context mapping |
| `event-driven-architecture` | skill | Event sourcing, CQRS, sagas, choreography vs orchestration, outbox pattern, idempotency |
| `reactive-systems` | skill | Reactive manifesto, back-pressure, supervision trees, circuit breakers, elasticity, message-driven |

### Category 2: Safety (3 skills)

| Item | Kind | Purpose |
|------|------|---------|
| `security-review` | skill | OWASP top 10, injection, auth/authz, secrets management, supply chain, dependency audit |
| `code-safety` | skill | Defensive coding, invariants, assertions, fail-fast, anti-hallucination (adapted from community anti-sycophancy patterns) |
| `privacy-compliance` | skill | GDPR, CCPA, data minimization, consent management, PII handling, retention policies, privacy by design, DPIAs |

### Category 3: Domain Expertise (3 skills)

| Item | Kind | Purpose |
|------|------|---------|
| `rust-expert` | skill | Ownership, lifetimes, async/tokio (select!, spawn, channels, graceful shutdown), error handling (thiserror/anyhow), unsafe review, FFI |
| `kotlin-expert` | skill | Coroutines, Flow (StateFlow vs SharedFlow), structured concurrency, supervisorScope, Channel patterns, Compose integration |
| `typescript-expert` | skill | Strict mode, discriminated unions, conditional types, async patterns, module design, type narrowing, branded types |

### Category 4: Discipline (1 skill)

| Item | Kind | Purpose |
|------|------|---------|
| `testing-taxonomy` | skill | When to use unit/integration/e2e/property/contract/mutation tests. Test pyramid vs trophy. Fixture strategies. Flaky test triage. |

### Category 5: Documentation (3 skills)

| Item | Kind | Purpose |
|------|------|---------|
| `tech-writing` | skill | Diataxis framework, ADR format, API documentation, changelogs, prose clarity, audience awareness, information hierarchy |
| `diagramming` | skill | Mermaid syntax, PlantUML, draw.io XML, SVG, C4 model, sequence/state/activity diagrams, when to use which format, layout principles |
| `typography-and-layout` | skill | Heading hierarchy, whitespace rhythm, information architecture, table design, code block formatting, PDF/HTML layout, accessibility |

### Category 6: Product (rule + 5 experts)

| Item | Kind | Purpose |
|------|------|---------|
| `product-discipline` | rule + skill | Always: every story has AC, issue hierarchy enforced, prioritization explicit. On-demand: framework selection (RICE, MoSCoW, severity×effort) |
| `atdd` | skill | Acceptance Test-Driven Development: Given/When/Then, living documentation, spec by example, Gherkin patterns |
| `event-storming` | skill | Domain discovery: commands, events, aggregates, hotspots, pivotal events, big-picture vs design-level |
| `story-mapping` | skill | User story mapping: backbone, walking skeleton, release slicing, MVP identification, narrative flow |
| `cuj-analysis` | skill | Critical User Journeys: happy path, edge cases, failure modes, journey metrics, drop-off analysis |
| `issue-modeling` | skill | Issue types (epic/story/task/debt/bug), hierarchy, labels, severity/effort/priority matrix, triage workflow |

## Bundle Manifest

```yaml
schema: 1
name: metapowers
description: Curated starter pack — architecture, safety, domain expertise, documentation, and product discipline
license: MIT
items:
  rules:
    - karpathy-guidelines
    - software-architecture
    - product-discipline
  skills:
    - software-architecture
    - domain-driven-design
    - event-driven-architecture
    - reactive-systems
    - security-review
    - code-safety
    - privacy-compliance
    - rust-expert
    - kotlin-expert
    - typescript-expert
    - testing-taxonomy
    - tech-writing
    - diagramming
    - typography-and-layout
    - product-discipline
    - atdd
    - event-storming
    - story-mapping
    - cuj-analysis
    - issue-modeling
requires:
  - name: superpowers
metadata:
  version: 0.2.0
```

## Installation UX

```bash
# Full install (superpowers + metapowers)
upskill add driftsys/metapowers --claude --copilot --opencode

# Individual skill
upskill add driftsys/metapowers --items rust-expert --claude
```

## Delivery order

Phase 1 (highest value, biggest gaps):
- `software-architecture` (rule + skill)
- `security-review`
- `tech-writing`
- `diagramming`
- `product-discipline` (rule + skill)

Phase 2 (domain expertise):
- `rust-expert`
- `kotlin-expert`
- `typescript-expert`
- `testing-taxonomy`

Phase 3 (architecture experts):
- `domain-driven-design`
- `event-driven-architecture`
- `reactive-systems`

Phase 4 (product experts + remaining):
- `atdd`
- `event-storming`
- `story-mapping`
- `cuj-analysis`
- `issue-modeling`
- `code-safety`
- `privacy-compliance`
- `typography-and-layout`

## Success criteria

- All items pass `upskill lint --strict`
- All items pass `upskill fmt` (idempotent)
- Bundle resolves without conflicts
- Installing metapowers in a fresh repo produces working per-client outputs
- Each skill is specific enough that an agent following it produces measurably different output than without it
