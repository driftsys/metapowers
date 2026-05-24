---
schema: 1
name: product-discipline
description: Product ownership techniques — prioritization frameworks, backlog grooming, issue modeling
version: 0.1.0
---

## When to use this skill

Use when grooming backlogs, prioritizing competing work, writing acceptance
criteria, or helping a PO structure their workflow.

## Prioritization Frameworks

### Severity × Effort Matrix

```text
          XS    S     M     L     XL
K0     P0    P0    P0    P1    P1
K1     P0    P1    P1    P2    drop
K2     P1    P2    P2    drop  drop
```

- **P0:** Do immediately (current sprint)
- **P1:** Plan for next sprint
- **P2:** Backlog (do when capacity allows)
- **drop:** Not worth the investment — close or park

### RICE Scoring

```text
Score = (Reach × Impact × Confidence) / Effort
```

| Factor | Scale |
|--------|-------|
| Reach | Number of users/events per quarter |
| Impact | 0.25 (minimal), 0.5 (low), 1 (medium), 2 (high), 3 (massive) |
| Confidence | 0.5 (low), 0.8 (medium), 1.0 (high) |
| Effort | Person-weeks |

Use RICE when comparing unrelated initiatives. Use severity×effort when
triaging within a known domain.

### MoSCoW

- **Must have:** System doesn't work without it
- **Should have:** Important but workaround exists
- **Could have:** Nice to have, low effort
- **Won't have (this time):** Explicitly out of scope

Use MoSCoW for release scoping. Not for sprint planning.

## Writing Acceptance Criteria

### Given/When/Then Format

```gherkin
Given [precondition / initial state]
When [action / trigger]
Then [expected outcome / observable result]
```

**Rules:**
- One behavior per scenario
- Preconditions are explicit (not assumed)
- Outcomes are observable (not internal state)
- Cover: happy path, validation failure, edge case, authorization

### Example

```gherkin
Feature: Password reset

Scenario: Successful reset
  Given a registered user with email "user@example.com"
  When they request a password reset
  Then they receive a reset email within 60 seconds
  And the reset link expires after 24 hours

Scenario: Unregistered email
  Given no user exists with email "unknown@example.com"
  When someone requests a password reset for that email
  Then no email is sent
  And the response is identical to the success case (no information leak)
```

## Issue Types

| Type | Purpose | Required fields |
|------|---------|-----------------|
| **Epic** | Groups related work toward a business goal | Goal, success metrics, child issues |
| **Story** | User-facing requirement | AC (Given/When/Then), epic link, severity, effort |
| **Task** | Technical requirement | Description, epic link, severity, effort |
| **Debt** | Refactoring or review finding | Origin (PR/review), epic link, severity, effort |
| **Bug** | Defect in existing behavior | Repro steps, expected vs actual, severity, effort |

## Expert Skills

For deeper guidance on specific techniques:
- **Acceptance Test-Driven Development** → `atdd` skill
- **Domain discovery workshops** → `event-storming` skill
- **Release planning and slicing** → `story-mapping` skill
- **User journey analysis** → `cuj-analysis` skill
- **Issue hierarchy and triage** → `issue-modeling` skill
