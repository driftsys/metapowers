---
schema: 1
name: product-discipline
description: Product ownership invariants — acceptance criteria, issue hierarchy, prioritization
version: 0.1.0
---

## Invariants

These rules apply to all product/backlog work. They ensure traceability,
clarity, and disciplined prioritization.

### 1. Every Story Has Acceptance Criteria

No story enters a sprint or gets assigned without explicit acceptance criteria.
Acceptance criteria are:
- Written in Given/When/Then or checklist format
- Testable (an engineer can write a test from them)
- Complete (cover happy path + key error cases)

A story without AC is a wish, not a requirement.

### 2. Issue Hierarchy Is Enforced

```text
Initiative (label only)
  → Epic (issue + labels)
    → Story (user-facing requirement)
    → Task (technical requirement)
    → Debt (refactoring / review findings)
```

- Every story/task/debt links to its parent epic
- Epics link to their initiative
- No orphan issues — everything traces to business value

### 3. Prioritization Is Explicit

Every item has:
- **Severity** (K0: must-have, K1: should-fix, K2: nice-to-have)
- **Effort** (XS, S, M, L, XL)
- **Priority** (derived from severity × effort matrix)

Never prioritize by gut feel alone. The matrix exists to make trade-offs
visible and debatable.

### 4. One Deliverable Per Issue

An issue describes one thing to build, fix, or improve. If it requires the
word "and" to describe, split it.

### 5. Definition of Done

An issue is done when:
- Code is merged to main
- Tests pass (unit + integration + acceptance)
- Documentation is updated (if behavior changed)
- The acceptance criteria are demonstrably met

"Done" is not "code written." Done is "value delivered and verified."

## When to load the product-discipline skill

Load the `product-discipline` skill when:
- Grooming or refining a backlog
- Prioritizing work across competing demands
- Defining acceptance criteria for a new feature
- Choosing a prioritization framework (RICE, MoSCoW, severity×effort)
