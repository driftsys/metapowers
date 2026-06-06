# Changelog

## [0.2.0] (2026-06-06)

### Bug Fixes

- **release:** repair lockstep version bump hook; align items to project version
  ([33a58fb])
- **superpowers:** install claude superpowers from the anthropic-vetted
  marketplace ([b673b6e])

[0.2.0]: https://github.com/driftsys/metapowers/compare/v0.1.1...v0.2.0
[33a58fb]: https://github.com/driftsys/metapowers/commit/33a58fb
[b673b6e]: https://github.com/driftsys/metapowers/commit/b673b6e

## [0.1.1] (2026-06-06)

### Refactoring

- reframe tech-diagramming-drawio as a pure no-MCP skill ([b63fc56])

### Features

- **sdd-gardening:** substrate-neutral gardener on the ratified docs/wip
  taxonomy ([50a7ae1]), closes 39.
- **sdd:** ratify working-memory lifecycle — docs/wip taxonomy & review-thread
  gate ([fd2a7a4]), closes 19.
- teach tech-diagramming-d2 compact layout defaults ([238e84c])

[0.1.1]: https://github.com/driftsys/metapowers/compare/v0.1.0...v0.1.1
[b63fc56]: https://github.com/driftsys/metapowers/commit/b63fc56
[50a7ae1]: https://github.com/driftsys/metapowers/commit/50a7ae1
[fd2a7a4]: https://github.com/driftsys/metapowers/commit/fd2a7a4
[238e84c]: https://github.com/driftsys/metapowers/commit/238e84c

## 0.1.0 (2026-06-04)

### Documentation

- add working-memory lifecycle & gardening tech note for review ([b464cae])

### Features

- **tech-diagramming:** gate draw.io on layout help, fall back to D2 without MCP
  ([ca9c3bb]), refs [#15], [#24], [#13], epic #3.
- **diagrampowers:** register tech-diagrammer orchestrator agent ([93afb84])
- **tech-diagrammer:** author diagram-heavy orchestrator subagent ([95b0a11])
- **diagrampowers:** register draw.io skill + per-tool installer agents (v0.2.0)
  ([646f025])
- **tech-diagramming-drawio:** author draw.io format skill + installer subagent
  ([c9a4a20])
- **tech-diagramming-d2:** add installer subagent; polish font/version notes
  ([c35a976])
- **tech-diagramming-plantuml:** add co-located PlantUML installer subagent
  ([32069fe])
- **tech-diagramming-d2:** author D2 format skill ([0740ac3])
- **tech-diagramming-ascii:** author ASCII format skill ([48a0fcb])
- add tech-diagramming umbrella + PlantUML skills (Phase 1) ([0364930])
- **sdd-gardening:** add working-memory lifecycle rule, gardening skill &
  subagent ([e490060])
- **superpowers:** declare opencode plugin install via config-write ([ce88819])
- **superpowers:** install via GitHub Copilot CLI plugin too ([7af7e3b])
- add baseline content, e2e tests, and version bumper ([d2c52b6])

### Bug Fixes

- restore sdd-gardener agent name; upskill 0.7.6 compatibility ([db2a5e3])
- **tech-diagramming:** make draw.io fallback shape-aware; fix installer +
  render facts ([8636465]), refs [#15], [#13], [#24], epic #3.

### Refactoring

- namespace the working-memory-lifecycle rule as sdd-working-memory-lifecycle
  ([5a11cb4])
- **tech-diagramming:** co-locate orchestrator as tech-diagramming/AGENT.md
  ([642abfb])
- **tech-diagramming:** umbrella dispatches per-tool installer subagents; drop
  ensure-tools.sh ([c46a923])
- extract diagrampowers bundle; metapowers requires it ([1ee1760])
- **sdd-gardening:** co-locate sdd-gardener agent into the skill directory
  ([4d3f1b9])
- **sdd-gardening:** align decision records to docs/decisions/ ([fdf416d])

### BREAKING CHANGES

- the rule's installed name/path changes from
  working-memory-lifecycle to sdd-working-memory-lifecycle; consumers re-running
  `upskill add`/`update` will see the rule re-rendered under the new name.

[b464cae]: https://github.com/driftsys/metapowers/commit/b464cae
[ca9c3bb]: https://github.com/driftsys/metapowers/commit/ca9c3bb
[#15]: https://github.com/driftsys/metapowers/issues/15
[#24]: https://github.com/driftsys/metapowers/issues/24
[#13]: https://github.com/driftsys/metapowers/issues/13
[93afb84]: https://github.com/driftsys/metapowers/commit/93afb84
[95b0a11]: https://github.com/driftsys/metapowers/commit/95b0a11
[646f025]: https://github.com/driftsys/metapowers/commit/646f025
[c9a4a20]: https://github.com/driftsys/metapowers/commit/c9a4a20
[c35a976]: https://github.com/driftsys/metapowers/commit/c35a976
[32069fe]: https://github.com/driftsys/metapowers/commit/32069fe
[0740ac3]: https://github.com/driftsys/metapowers/commit/0740ac3
[48a0fcb]: https://github.com/driftsys/metapowers/commit/48a0fcb
[0364930]: https://github.com/driftsys/metapowers/commit/0364930
[e490060]: https://github.com/driftsys/metapowers/commit/e490060
[ce88819]: https://github.com/driftsys/metapowers/commit/ce88819
[7af7e3b]: https://github.com/driftsys/metapowers/commit/7af7e3b
[d2c52b6]: https://github.com/driftsys/metapowers/commit/d2c52b6
[db2a5e3]: https://github.com/driftsys/metapowers/commit/db2a5e3
[8636465]: https://github.com/driftsys/metapowers/commit/8636465
[5a11cb4]: https://github.com/driftsys/metapowers/commit/5a11cb4
[642abfb]: https://github.com/driftsys/metapowers/commit/642abfb
[c46a923]: https://github.com/driftsys/metapowers/commit/c46a923
[1ee1760]: https://github.com/driftsys/metapowers/commit/1ee1760
[4d3f1b9]: https://github.com/driftsys/metapowers/commit/4d3f1b9
[fdf416d]: https://github.com/driftsys/metapowers/commit/fdf416d
