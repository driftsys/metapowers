---
schema: 1
name: software-architecture
description: Architectural invariants — failure isolation, explicit contracts, data ownership
version: 0.1.0
---

## Invariants

These principles apply to every architectural decision. Violating them requires
explicit justification in an ADR.

### 1. Single Responsibility at Service Boundaries

Every service, module, or bounded context owns exactly one business capability.
If you cannot name what a component is responsible for in one sentence, it is
doing too much.

### 2. Explicit Contracts Between Components

All inter-component communication uses explicitly defined contracts:
- API schemas (OpenAPI, protobuf, GraphQL SDL)
- Event schemas (CloudEvents, Avro, JSON Schema)
- Shared-nothing: no shared databases, no shared mutable state

Never rely on implicit knowledge of another component's internals.

### 3. Failure Isolation (Bulkhead Pattern)

A failure in component A must not cascade to component B unless B explicitly
depends on A's output. Design for:
- Timeouts on all external calls
- Circuit breakers on repeated failures
- Fallback behavior (degraded mode, cached response, or explicit error)
- Supervision: crashed components restart without manual intervention

### 4. Data Ownership

Every piece of data has exactly one authoritative source. Other components may
cache or project that data, but the owner is the only writer. Ask:
- Who creates this data?
- Who is allowed to mutate it?
- Who is the source of truth when copies diverge?

### 5. Async by Default at Integration Points

Synchronous calls between services create temporal coupling. Prefer:
- Events/messages for notifications and state propagation
- Request/reply only when the caller cannot proceed without the response
- Idempotent consumers (at-least-once delivery is the baseline assumption)

### 6. Evolutionary Architecture

Design for change, not for prediction:
- Prefer reversible decisions over optimal ones
- Record irreversible decisions in ADRs with context and consequences
- Fitness functions: define measurable criteria (latency p99, coupling metrics,
  deployment frequency) and monitor them

## When to load the software-architecture skill

Load the `software-architecture` skill when:
- Designing a new system or subsystem from scratch
- Evaluating trade-offs between architectural patterns
- Facing a decision that affects multiple components
- Writing or reviewing an ADR
