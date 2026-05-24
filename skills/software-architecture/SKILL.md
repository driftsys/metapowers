---
schema: 1
name: software-architecture
description: Pattern selection, trade-off analysis, and architectural decision-making
version: 0.1.0
---

## When to use this skill

Use when facing architectural decisions: choosing patterns, evaluating
trade-offs, designing system boundaries, or writing ADRs.

## Process

### 1. Identify the Decision

Before choosing a pattern, name the decision explicitly:
- What capability are we adding or changing?
- What quality attributes matter most? (latency, throughput, consistency,
  availability, maintainability, cost)
- What constraints exist? (team size, timeline, existing infrastructure,
  compliance)

### 2. Evaluate Patterns

For each candidate pattern, assess:

| Criterion | Questions |
|-----------|-----------|
| Fitness | Does it optimize for the quality attributes that matter? |
| Complexity | Can the team operate it? What's the cognitive load? |
| Reversibility | How hard is it to migrate away if it's wrong? |
| Precedent | Is there prior art in this codebase or organization? |

### 3. Common Patterns — Decision Tree

**Data flow:**
- Request/response needed? → REST, gRPC, GraphQL
- Fire-and-forget notification? → Events (Kafka, NATS, SQS)
- Need to replay history? → Event Sourcing
- Need different read/write models? → CQRS

**Component structure:**
- Single team, single deploy? → Modular monolith
- Multiple teams, independent deploy? → Microservices
- Complex domain logic? → Domain-Driven Design (load `domain-driven-design` skill)
- High throughput, back-pressure needed? → Reactive (load `reactive-systems` skill)
- Long-running multi-step process? → Saga / orchestration (load `event-driven-architecture` skill)

**Resilience:**
- External dependency unreliable? → Circuit breaker + fallback
- Need to survive partial failures? → Bulkhead isolation
- Need consistency across services? → Saga with compensation

### 4. Record the Decision

Every irreversible architectural decision gets an ADR:

```markdown
# NNNN — [Decision Title]

## Status: [Proposed | Accepted | Deprecated | Superseded by NNNN]

## Context
[What forces are at play? What constraints exist?]

## Decision
[What did we decide? Be specific.]

## Consequences
[What becomes easier? What becomes harder? What risks remain?]
```

### 5. Validate with Fitness Functions

After implementing, define measurable criteria:
- Latency: p50, p95, p99 targets
- Coupling: number of cross-service synchronous calls
- Autonomy: can each service deploy independently?
- Resilience: what happens when dependency X is down for 5 minutes?

## Expert Skills

For deeper guidance on specific patterns:
- **Domain-Driven Design** → `domain-driven-design` skill
- **Event Sourcing / CQRS / Sagas** → `event-driven-architecture` skill
- **Reactive Manifesto / Back-pressure** → `reactive-systems` skill
