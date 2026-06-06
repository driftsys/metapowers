---
schema: 1
name: acme-sdd-substrate
description: Standing substrate for durable engineering records. Applies whenever durable records are gardened into docs/specification, docs/design, docs/decisions, or docs/technotes.
---

When gardening turns specs and plans into durable records under
`docs/specification/`, `docs/design/`, `docs/decisions/`, or `docs/technotes/`,
author those records in the **ACME-SDD substrate**:

- Begin every durable record file with this exact first line, verbatim:
  `<!-- substrate: ACME-SDD v1 -->`
- In `docs/specification/`, write each requirement as its own line of the form
  `REQ-<n>: <statement>` (one requirement per line).

This substrate applies to the durable records only; the raw specs and plans in
`docs/wip/` and the archived originals in `docs/archive/` are unchanged.
