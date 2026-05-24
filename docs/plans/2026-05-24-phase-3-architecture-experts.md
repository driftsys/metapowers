# Metapowers Phase 3: Architecture Experts — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver 3 deep architecture expert skills that the software-architecture umbrella dispatches to.
**Architecture:** Each skill is a SSOT item in `skills/<name>/SKILL.md`. These are expert-level deep dives, not overviews — they contain patterns, anti-patterns, decision trees, and implementation guidance.
**Tech Stack:** Markdown with YAML frontmatter (upskill portable format), validated by `upskill lint`, formatted by `upskill fmt` and `dprint`.

---

## Task 1: Create `domain-driven-design` Skill

- [ ] Scaffold the skill: `upskill new skill domain-driven-design`
- [ ] Write full skill content to `skills/domain-driven-design/SKILL.md`:

```markdown
---
description: >
  Use when designing bounded contexts, defining aggregates, establishing ubiquitous language,
  mapping context boundaries, or applying tactical DDD patterns. Trigger when domain complexity
  warrants explicit modeling — not for simple CRUD. Also trigger when teams struggle with
  model boundaries, naming conflicts across modules, or aggregate consistency issues.
---

# Domain-Driven Design

## Activation

Trigger this skill when:
- Designing a new bounded context or decomposing a monolith
- Defining aggregate boundaries and consistency rules
- Resolving naming conflicts that signal implicit context boundaries
- Choosing integration patterns between contexts
- Running or interpreting event storming sessions

Do NOT trigger for simple CRUD applications or anemic domain models that don't warrant DDD.

## Strategic Design

### Bounded Contexts

A bounded context is a linguistic and model boundary — the same word means different things
in different contexts.

**Discovery signals:**
- Same term, different meanings across teams ("Account" in billing vs identity)
- Different change cadences in parts of the system
- Different domain experts for different areas
- Natural team boundaries

**Rules:**
1. One ubiquitous language per bounded context — no ambiguity within the boundary
2. Models do NOT leak across boundaries — translate at the edge
3. Size guided by team cognitive load, not technical convenience
4. Each context owns its persistence — no shared databases

### Context Mapping Patterns

| Pattern | When to Use | Direction |
|---------|-------------|-----------|
| **Shared Kernel** | Two teams co-own a small model subset; high trust | Symmetric |
| **Customer-Supplier** | Upstream serves downstream; downstream can negotiate | Upstream → Downstream |
| **Conformist** | Downstream accepts upstream model as-is; no negotiation power | Upstream → Downstream |
| **Anti-Corruption Layer (ACL)** | Protect your model from external/legacy model pollution | Downstream defense |
| **Open Host Service (OHS)** | Upstream publishes a well-defined protocol for many consumers | Upstream publishes |
| **Published Language** | Shared interchange format (often combined with OHS) | Shared schema |
| **Separate Ways** | No integration — contexts are independent | None |
| **Partnership** | Two teams coordinate releases; mutual dependency | Symmetric |

**Decision tree:**
```
Do you trust/control the upstream?
├── Yes, co-owned → Shared Kernel
├── Yes, can negotiate → Customer-Supplier
├── No, but model is acceptable → Conformist
├── No, and model would corrupt yours → Anti-Corruption Layer
└── No relationship needed → Separate Ways
```

### Anti-Corruption Layer Implementation

```
[Your Context] → [ACL: Translator + Adapter] → [External Context]
```

The ACL contains:
- **Translator**: Converts external concepts to your ubiquitous language
- **Adapter**: Handles protocol/transport differences
- **Facade**: Simplifies the external interface

Never let external model types leak past the ACL. Map to your own domain types.

## Tactical Design

### Entities vs Value Objects

| Aspect | Entity | Value Object |
|--------|--------|--------------|
| Identity | Has unique ID; tracked over time | No ID; defined by attributes |
| Equality | Same ID = same entity | Same attributes = same value |
| Mutability | Mutable (state changes over lifecycle) | Immutable (replace, don't modify) |
| Examples | User, Order, Account | Money, Address, DateRange |

**Prefer value objects.** They are simpler, testable, and thread-safe. Only use entities
when you need to track identity over time.

### Aggregates

An aggregate is a consistency boundary — a cluster of entities and value objects
treated as a single unit for data changes.

**Aggregate design rules:**
1. **One aggregate root** — external references only point to the root
2. **Reference other aggregates by ID only** — never hold object references across boundaries
3. **Keep aggregates small** — prefer single-entity aggregates; grow only when invariants demand it
4. **Transactions don't span aggregates** — use eventual consistency between aggregates
5. **Delete cascades within the aggregate** — if root is deleted, all children go with it

**Anti-patterns:**
- God aggregate (entire order + line items + payments + shipments) — split by invariant
- Aggregate holding references to other aggregates — use IDs
- Business rules spanning aggregates in one transaction — use domain events

### Domain Events

A domain event records something that happened in the domain that domain experts care about.

**Naming:** Past tense, ubiquitous language. `OrderPlaced`, `PaymentReceived`, `InventoryReserved`.

**Structure:**
- Event name (past tense verb phrase)
- Timestamp (when it occurred)
- Aggregate ID (which aggregate produced it)
- Payload (relevant state at time of occurrence — not the full aggregate)
- Causation/correlation IDs (for tracing)

**Rules:**
- Events are immutable facts — never modify after publication
- Events carry enough data for consumers to act without calling back
- Within an aggregate: raise events synchronously (same transaction)
- Between aggregates: dispatch asynchronously (eventual consistency)

### Repositories

A repository provides collection-like access to aggregates. It is the persistence
abstraction for the domain layer.

**Rules:**
- One repository per aggregate root (never for child entities)
- Interface defined in domain layer; implementation in infrastructure
- Methods speak ubiquitous language: `findActiveOrdersForCustomer()`, not `query(sql)`
- Returns fully reconstituted aggregates — no lazy loading leaking into domain

### Domain Services

Use a domain service when:
- An operation doesn't naturally belong to any single entity/value object
- The operation involves multiple aggregates
- The operation represents a domain concept (not just orchestration)

Do NOT use domain services as a dumping ground — if it fits on an entity, put it there.

### Factories

Use factories when aggregate creation is complex:
- Multiple valid construction paths
- Invariant validation at creation time
- Creation requires external data assembly

## Ubiquitous Language

### Discovery Techniques

1. **Listen to domain experts** — their nouns and verbs ARE the model
2. **Event storming** — domain events surface the language naturally
3. **Challenge synonyms** — if two words mean the same thing, pick one
4. **Challenge homonyms** — if one word means two things, you've found a context boundary

### Enforcement

- Code uses domain language: class names, method names, variable names
- Tests read like domain scenarios: `when order is placed, inventory is reserved`
- Documentation uses the same terms — no "technical translation"
- Reject pull requests that introduce synonyms or bypass the language
- Maintain a living glossary per bounded context

### Glossary Pattern

Each bounded context maintains a glossary:
```
| Term | Definition | Examples | NOT (anti-examples) |
```

Review the glossary in design sessions. Update it as understanding evolves.

## Event Storming Integration

Event storming sessions produce DDD artifacts naturally:

| Event Storming Artifact | DDD Artifact |
|------------------------|--------------|
| Domain Event (orange) | Domain Event |
| Command (blue) | Application Service method |
| Aggregate (yellow) | Aggregate |
| Policy (lilac) | Domain Service or Saga |
| External System (pink) | Anti-Corruption Layer boundary |
| Read Model (green) | Query/Projection |
| Hotspot (red/pink) | Complexity to investigate |

**Flow:** Events → Commands → Aggregates → Bounded Contexts → Context Map

## Decision Framework

```
Is the domain complex (many rules, edge cases, evolving)?
├── No → Skip DDD. Use transaction scripts or simple CRUD.
└── Yes →
    Is there access to domain experts?
    ├── No → DDD will fail. Get access first.
    └── Yes →
        Start with strategic design (contexts + mapping).
        Then apply tactical patterns ONLY where complexity justifies it.
        Not every context needs full tactical DDD — some are CRUD.
```

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| Anemic Domain Model | Entities are data bags; logic in services | Move behavior onto entities |
| Smart UI | Business logic in controllers/UI | Extract domain layer |
| Shared Database | Contexts coupled via shared tables | Separate schemas, use events |
| Big Ball of Mud | No boundaries; everything knows everything | Identify contexts, draw lines |
| DDD Everywhere | Applying DDD to trivial CRUD | Reserve DDD for complex domains |
| Analysis Paralysis | Modeling forever without shipping | Time-box; model evolves with code |
```

- [ ] Validate: `upskill lint skills/domain-driven-design/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add domain-driven-design expert skill"`

---

## Task 2: Create `event-driven-architecture` Skill

- [ ] Scaffold the skill: `upskill new skill event-driven-architecture`
- [ ] Write full skill content to `skills/event-driven-architecture/SKILL.md`:

```markdown
---
description: >
  Use when designing event sourcing, CQRS, saga/process manager patterns, or asynchronous
  messaging architectures. Trigger when choosing between choreography and orchestration,
  implementing the outbox pattern, handling idempotency, or designing event schemas.
  Do NOT trigger for simple request-response APIs without async messaging.
---

# Event-Driven Architecture

## Activation

Trigger this skill when:
- Designing event-sourced systems or evaluating event sourcing as a persistence strategy
- Implementing CQRS (separating read and write models)
- Designing sagas for distributed transactions
- Implementing reliable event delivery (outbox, CDC)
- Handling idempotency in at-least-once delivery systems
- Designing event schemas and managing schema evolution

Do NOT trigger for synchronous request-response systems without messaging.

## Event Sourcing

### Core Concept

Store state as a sequence of immutable events rather than current state.
Rebuild current state by replaying events from the beginning.

```
Command → Aggregate → Event(s) → Event Store
                                      ↓
                              Projection → Read Model
```

### Event Store

**Requirements:**
- Append-only (events are immutable facts)
- Ordered per stream (aggregate instance)
- Optimistic concurrency (expected version on write)
- Global ordering (for cross-stream projections)

**Stream naming:** `{AggregateType}-{AggregateId}` (e.g., `Order-12345`)

### Projections

Projections (read models) are derived from events. They are disposable and rebuildable.

**Types:**
- **Inline/synchronous** — updated in same process, immediate consistency
- **Async/eventually consistent** — separate process, subscribes to event stream
- **Catch-up subscription** — reads from position, handles backfill + live

**Rules:**
- A projection can subscribe to multiple stream types
- Projections are optimized for specific queries (denormalized)
- If a projection is wrong, fix and rebuild — don't patch data

### Snapshots

When replay becomes slow (thousands of events), snapshot periodically:

```
Events 1-1000 → Snapshot @ version 1000
New replay: Load snapshot + replay events 1001-current
```

**Rules:**
- Snapshots are optimization, not source of truth — always rebuildable from events
- Snapshot every N events (100-1000 depending on aggregate complexity)
- Store snapshots alongside the stream or in a separate store
- Version snapshots — schema changes require snapshot invalidation

### Event Versioning and Upcasting

Events are immutable, but their shape evolves. Handle with upcasters:

```
Event v1 (stored) → Upcaster → Event v2 (in memory)
```

**Strategies:**
1. **Weak schema** — consumers ignore unknown fields, use defaults for missing
2. **Upcasting** — transform old shapes to new on read (pipeline of transformers)
3. **Copy-transform** — migrate entire store to new schema (expensive, rare)
4. **New event type** — deprecate old, emit new going forward (versioned names)

**Rules:**
- Never modify stored events
- Upcasters are pure functions: old shape → new shape
- Test upcasters against every historical version
- Document event changelog

## CQRS (Command Query Responsibility Segregation)

### Architecture

```
Commands → Command Handler → Domain Model → Events → Event Store
                                                          ↓
Queries → Query Handler → Read Model ← Projection ← Event Stream
```

### Command Side
- Validates business rules
- Enforces invariants
- Produces events
- Knows nothing about read optimization

### Query Side
- Optimized for specific query patterns
- Denormalized (one read model per screen/use case)
- Eventually consistent with command side
- Can have multiple independent read models

### Consistency Gap

The time between command acceptance and read model update is the "consistency window."

**Strategies:**
- **Accept it** — UI shows "processing" state; poll or push update
- **Read-your-writes** — after command, read from event stream directly for that user
- **Causal consistency** — track version; reject stale reads from client

### Read Model Rebuilding

When projection logic changes, rebuild from event stream:
1. Create new projection (versioned name or blue-green)
2. Replay all events through new projection logic
3. Swap traffic to new read model
4. Delete old read model

## Saga Patterns

### Choreography vs Orchestration

| Aspect | Choreography | Orchestration |
|--------|-------------|---------------|
| Coupling | Low — services react to events | Higher — orchestrator knows steps |
| Visibility | Scattered across services | Centralized in orchestrator |
| Complexity | Grows fast with steps | Linear growth |
| Failure handling | Each service compensates independently | Orchestrator manages compensation |
| Best for | 2-4 step simple flows | 5+ steps or complex branching |

**Decision rule:** Start with choreography for simple flows. Switch to orchestration
when debugging distributed flows becomes painful (usually >4 services).

### Orchestration Implementation

```
Saga Orchestrator:
  Step 1: ReserveInventory → success/failure
  Step 2: ChargePayment → success/failure
  Step 3: ShipOrder → success/failure

  On failure at step N:
    Compensate steps N-1 → 1 in reverse order
```

**State machine:** Each saga instance has a state (pending, step1_complete, compensating, etc.)
Persist state — sagas must survive process restarts.

### Compensation

Compensation undoes the semantic effect of a step (not necessarily the exact operation).

**Rules:**
- Every step that has side effects MUST have a compensation
- Compensation must be idempotent (may be retried)
- Compensations execute in reverse order
- Some actions are non-compensatable (sending email) — schedule them last

### Timeout Handling

- Every saga step has a deadline
- On timeout: retry (if idempotent) or compensate
- Saga itself has a global timeout — if exceeded, compensate all completed steps
- Use dead-letter queues for steps that neither succeed nor fail

## Outbox Pattern

### Problem

Dual-write problem: updating database AND publishing event must be atomic.
If either fails independently, system becomes inconsistent.

### Solution: Transactional Outbox

```
BEGIN TRANSACTION
  1. Update domain table
  2. Insert event into outbox table (same database)
COMMIT

Separate process:
  3. Poll outbox table for unpublished events
  4. Publish to message broker
  5. Mark as published (or delete)
```

### Delivery Mechanisms

| Mechanism | Pros | Cons |
|-----------|------|------|
| **Polling Publisher** | Simple, no infrastructure | Latency, database load |
| **CDC (Change Data Capture)** | Low latency, no polling | Infrastructure complexity (Debezium) |
| **Transaction log tailing** | Lowest latency | Database-specific, complex |

### Outbox Table Schema

```sql
CREATE TABLE outbox (
    id UUID PRIMARY KEY,
    aggregate_type VARCHAR NOT NULL,
    aggregate_id VARCHAR NOT NULL,
    event_type VARCHAR NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    published_at TIMESTAMP NULL
);
```

## Idempotency

### Why It Matters

At-least-once delivery means consumers may see the same event multiple times.
Every consumer must handle duplicates safely.

### Strategies

1. **Idempotency key** — sender assigns unique key; receiver deduplicates
   ```
   Event { id: "evt-123", ... }
   Consumer: IF NOT processed("evt-123") THEN process AND mark("evt-123")
   ```

2. **Natural idempotency** — operation is inherently safe to repeat
   - `SET balance = 100` is idempotent
   - `SET balance = balance + 10` is NOT idempotent

3. **Conditional writes** — only apply if current state matches expected
   ```
   UPDATE accounts SET balance = 90 WHERE id = X AND balance = 100
   ```

4. **Deduplication table** — store processed event IDs with TTL
   ```sql
   CREATE TABLE processed_events (
       event_id UUID PRIMARY KEY,
       processed_at TIMESTAMP,
       expires_at TIMESTAMP
   );
   ```

### At-Least-Once vs Exactly-Once

Exactly-once delivery is impossible in distributed systems. What people mean is
**effectively-once processing**: at-least-once delivery + idempotent consumers.

## Event Design

### Naming Conventions

- Past tense: something happened (`OrderPlaced`, not `PlaceOrder`)
- Domain language: use terms domain experts recognize
- Specific: `PaymentCardDeclined` not `PaymentFailed` (include reason in name when meaningful)

### Schema Guidelines

- Include enough data for consumers to act without callbacks
- Don't include entire aggregate state (over-sharing creates coupling)
- Include correlation ID for tracing across services
- Include causation ID (which command/event caused this)
- Include timestamp and aggregate version

### CloudEvents Spec

Standard envelope for events:
```json
{
  "specversion": "1.0",
  "id": "evt-uuid",
  "source": "/orders/service",
  "type": "com.example.order.placed.v1",
  "time": "2026-01-15T12:00:00Z",
  "datacontenttype": "application/json",
  "data": { ... }
}
```

### Schema Evolution Rules

1. **Adding fields** — safe (consumers ignore unknown)
2. **Removing fields** — breaking (consumers may depend on them)
3. **Renaming fields** — breaking (equivalent to remove + add)
4. **Changing types** — breaking

For breaking changes: new event type with version suffix (`OrderPlaced.v2`).

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| Event as command | Events named as imperatives (`SendEmail`) | Past tense; events are facts |
| Too chatty | Hundreds of tiny events per operation | Batch related changes; right granularity |
| Event soup | No clear ownership; events everywhere | Bounded context ownership |
| Missing idempotency | Duplicate processing on redelivery | Deduplication + idempotent handlers |
| Distributed monolith | Services coupled by shared event schemas | Separate schemas per context; translate at ACL |
| CQRS everywhere | Simple CRUD forced into CQRS | Reserve for complex read/write asymmetry |
```

- [ ] Validate: `upskill lint skills/event-driven-architecture/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add event-driven-architecture expert skill"`

---

## Task 3: Create `reactive-systems` Skill

- [ ] Scaffold the skill: `upskill new skill reactive-systems`
- [ ] Write full skill content to `skills/reactive-systems/SKILL.md`:

```markdown
---
description: >
  Use when designing systems following the Reactive Manifesto — responsive, resilient,
  elastic, and message-driven. Trigger when implementing back-pressure, supervision trees,
  circuit breakers, actor-based concurrency, or reactive streams. Do NOT trigger for simple
  async/await code without back-pressure or resilience concerns.
---

# Reactive Systems

## Activation

Trigger this skill when:
- Designing systems that must remain responsive under varying load
- Implementing back-pressure to handle producer-consumer speed mismatch
- Designing supervision hierarchies for fault tolerance
- Implementing circuit breakers for external dependency protection
- Scaling horizontally with location transparency
- Choosing between actor model, reactive streams, or event loop architectures

Do NOT trigger for simple async code, basic HTTP servers, or systems without resilience requirements.

## The Reactive Manifesto

Four interconnected properties:

```
        Responsive
       /          \
  Resilient    Elastic
       \          /
     Message-Driven
```

| Property | Means | Achieved By |
|----------|-------|-------------|
| **Responsive** | Consistent response times; usable | Resilience + elasticity underneath |
| **Resilient** | Stays responsive during failure | Replication, containment, isolation, delegation |
| **Elastic** | Stays responsive under load | Scale out/in; no bottlenecks; no central state |
| **Message-Driven** | Async message passing; loose coupling | Non-blocking communication; back-pressure |

### Message-Driven vs Event-Driven

| Aspect | Message-Driven | Event-Driven |
|--------|---------------|--------------|
| Addressing | Directed to specific recipient | Broadcast/published to subscribers |
| Coupling | Sender knows recipient | Publisher doesn't know consumers |
| Back-pressure | Built-in (mailbox, flow control) | Harder (consumers have no upstream signal) |
| Use in reactive | Foundation layer | Often built on top of message-driven |

Reactive systems are message-driven at the foundation, which enables both resilience
(failure as messages) and elasticity (location-transparent routing).

## Back-Pressure

### The Problem

When a producer is faster than a consumer, something must give:
- Unbounded buffering → OOM crash
- Dropping silently → data loss
- Blocking producer → cascading slowdown upstream

### Strategies

| Strategy | Behavior | When to Use |
|----------|----------|-------------|
| **Buffer** | Queue N items; fail/drop when full | Burst absorption; known max |
| **Drop (newest)** | Discard incoming when full | Telemetry; latest-wins data |
| **Drop (oldest)** | Discard oldest buffered item | Sensor data; only latest matters |
| **Latest** | Keep only most recent; discard rest | UI updates; status polling |
| **Error/fail** | Signal failure upstream | When data loss is unacceptable |
| **Throttle** | Rate-limit producer | API gateways; known capacity |
| **Dynamic (reactive pull)** | Consumer requests N items | Reactive streams; optimal |

### Reactive Streams Protocol

```
Subscriber → request(n) → Publisher
Publisher → onNext(item) [up to n times] → Subscriber
Publisher → onComplete/onError → Subscriber
```

**Key rule:** Publisher MUST NOT emit more items than requested. This is the
back-pressure contract. Violating it defeats the entire purpose.

### Implementation Patterns

**Bounded mailbox (actor model):**
```
Actor mailbox capacity: 1000
On full: drop oldest / reject / apply back-pressure to sender
```

**Flow control (streaming):**
```
Consumer pulls: "give me 100 items"
Producer sends up to 100
Consumer processes, then pulls again
```

**Rate limiter (gateway):**
```
Token bucket: 1000 req/s capacity
Exceeding: return 429 / queue / shed load
```

## Supervision

### Concept

Instead of handling every failure inline, delegate failure handling to a supervisor
that has broader context.

```
         [Supervisor]
        /     |      \
  [Worker] [Worker] [Worker]
```

The supervisor decides what to do when a child fails. Workers focus only on
their happy path.

### Restart Strategies

| Strategy | Behavior | When to Use |
|----------|----------|-------------|
| **One-for-one** | Restart only failed child | Children are independent |
| **All-for-one** | Restart all children | Children are interdependent |
| **Rest-for-one** | Restart failed + all started after it | Ordered dependencies |

### Escalation

If a supervisor can't handle the failure (e.g., too many restarts in a window),
it escalates to ITS supervisor. This continues up the tree until someone handles it
or the system shuts down gracefully.

**Restart intensity:** `max_restarts` within `time_window`. Exceeding = escalate.

### Supervision Tree Design

```
[Application Supervisor] — one-for-one
├── [Database Supervisor] — one-for-one
│   ├── [Connection Pool]
│   └── [Migration Worker]
├── [HTTP Supervisor] — one-for-one
│   ├── [Listener]
│   └── [Request Workers] — one-for-one (dynamic)
└── [Background Jobs Supervisor] — one-for-one
    ├── [Scheduler]
    └── [Job Workers] — one-for-one (dynamic)
```

**Rules:**
- Leaf nodes do work; interior nodes supervise
- Keep supervision trees shallow (2-3 levels typical)
- Stateful actors need recovery strategy (event sourcing, checkpointing)
- Stateless actors just restart fresh

### Let It Crash Philosophy

Don't write defensive code for every edge case inside workers:
- Handle expected domain errors normally
- For unexpected/transient failures: crash and let supervisor restart
- This produces simpler code and clearer failure boundaries
- BUT: protect external-facing boundaries (don't crash on bad user input)

## Circuit Breakers

### States

```
[Closed] ──failures exceed threshold──→ [Open]
   ↑                                       │
   │                                  timeout expires
   │                                       ↓
   └──── success ────── [Half-Open] ──failure──→ [Open]
```

| State | Behavior |
|-------|----------|
| **Closed** | Requests pass through; failures counted |
| **Open** | Requests fail immediately (fast-fail); no calls to dependency |
| **Half-Open** | Limited probe requests; success → close; failure → reopen |

### Configuration Parameters

| Parameter | Description | Typical Range |
|-----------|-------------|---------------|
| `failure_threshold` | Failures before opening | 5-50 |
| `success_threshold` | Successes in half-open to close | 1-5 |
| `timeout` | Time in open before half-open | 10-60 seconds |
| `failure_rate_threshold` | % failure rate to trigger (alternative) | 50-80% |
| `slow_call_threshold` | Latency that counts as failure | 2-10 seconds |
| `ring_buffer_size` | Window of calls to evaluate | 10-100 |

### Fallback Strategies

When circuit is open, don't just fail — provide graceful degradation:

| Strategy | Example |
|----------|---------|
| **Cached response** | Return last known good value |
| **Default value** | Return safe default |
| **Alternative service** | Route to backup provider |
| **Queue for later** | Accept and process async when service recovers |
| **Reduced functionality** | Disable non-critical feature |

### Anti-Patterns

- Circuit breaker per instance (should be per dependency/endpoint)
- Timeout too short (normal latency jitter opens circuit)
- No monitoring (circuit opens silently; nobody notices)
- No fallback (open circuit = hard failure for users)

## Elasticity

### Principles

- **No single point of contention** — sharded state; no global locks
- **Location transparency** — components communicate via addresses; physical location irrelevant
- **Scale out, not up** — add instances, don't make one instance bigger
- **Stateless where possible** — state in external store; processes are disposable

### Sharding

Distribute state across N nodes using a partition key:

```
hash(entity_id) % shard_count → shard assignment
```

**Consistent hashing:** Minimizes redistribution when nodes added/removed.
Only `K/N` keys move (K=keys, N=nodes) vs. full reshuffle.

### Location Transparency

Components communicate via logical addresses, not physical:
```
send(message, to: "/orders/processor")  // logical
                                        // router resolves to physical node
```

This enables:
- Moving actors/services between nodes without code changes
- Load balancing across instances transparently
- Failover by reassigning logical address to healthy node

### Auto-Scaling Signals

| Signal | Scale Direction | Caveat |
|--------|----------------|--------|
| CPU utilization > 70% | Out | Lagging indicator |
| Queue depth growing | Out | Good leading indicator |
| Response latency P99 increasing | Out | Reactive; combine with predictive |
| Queue depth near zero | In | Don't scale to zero if startup is slow |
| Scheduled (time-based) | Out/In | Known patterns (business hours, batch jobs) |

## Implementation Patterns

### Actor Model

Actors are lightweight concurrent entities that:
- Encapsulate state (no shared mutable state)
- Communicate via async messages only
- Process one message at a time (no internal concurrency)
- Can create child actors (supervision)

**When to use:**
- Many independent stateful entities (user sessions, IoT devices, game entities)
- Complex concurrency with shared state
- Systems requiring supervision/fault tolerance

**Implementations:** Akka (JVM), Erlang/OTP, Microsoft Orleans (.NET), Ractor (Rust)

### Reactive Streams

Asynchronous stream processing with built-in back-pressure.

**Core interfaces:**
- Publisher: produces items
- Subscriber: consumes items
- Subscription: mediates flow control (request/cancel)
- Processor: both publisher and subscriber (transform)

**Implementations:** Project Reactor (Java), RxJava, Akka Streams, Tokio streams (Rust)

**Operator categories:**
- Transform: map, flatMap, scan
- Filter: filter, take, skip, distinct
- Combine: merge, zip, concat
- Error: retry, onErrorResume, timeout
- Back-pressure: buffer, sample, debounce

### Event Loop (Single-Threaded Async)

One thread handles many connections via non-blocking I/O:

```
while true:
  events = poll(registered_fds, timeout)
  for event in events:
    handle(event)  // non-blocking callback
```

**When to use:**
- I/O-bound workloads (web servers, proxies)
- Simpler mental model than full actor systems
- Don't need stateful supervision

**Implementations:** Node.js, Tokio (Rust), Netty (Java), libuv (C)

**Rule:** Never block the event loop. Offload CPU-heavy work to a thread pool.

## Decision Framework

```
Need resilience + elasticity + responsiveness?
├── No → Standard request-response is fine
└── Yes →
    Need stateful entities with supervision?
    ├── Yes → Actor model (Akka, Erlang/OTP, Orleans)
    └── No →
        Need streaming data with back-pressure?
        ├── Yes → Reactive streams (Reactor, RxJava, Akka Streams)
        └── No →
            Need high-concurrency I/O?
            ├── Yes → Event loop (Tokio, Node.js, Netty)
            └── No → Re-evaluate if you need reactive at all
```

## Anti-Patterns

| Anti-Pattern | Symptom | Fix |
|-------------|---------|-----|
| Reactive everywhere | Simple CRUD wrapped in reactive complexity | Reserve for systems that need it |
| Blocking in async | Thread pool exhaustion; latency spikes | Isolate blocking calls; use dedicated pools |
| Unbounded queues | OOM under load | Bound everything; apply back-pressure |
| No supervision | One failure takes down entire system | Design supervision tree |
| Synchronous in disguise | Async calls with immediate `.get()`/`.block()` | Compose async chains; block only at edges |
| Global state | Can't scale out; single point of contention | Shard state; use location-transparent messaging |
```

- [ ] Validate: `upskill lint skills/reactive-systems/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(skills): add reactive-systems expert skill"`

---

## Task 4: Update Bundle Manifest

- [ ] Edit `metapowers.bundle.yaml`:
  - Add under `items:`:
    ```yaml
    - kind: skill
      name: domain-driven-design
      path: skills/domain-driven-design/SKILL.md

    - kind: skill
      name: event-driven-architecture
      path: skills/event-driven-architecture/SKILL.md

    - kind: skill
      name: reactive-systems
      path: skills/reactive-systems/SKILL.md
    ```
  - Bump `version:` to `0.4.0`
- [ ] Validate bundle: `upskill lint`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git commit -m "feat(bundle): add phase-3 architecture experts, bump to v0.4.0"`

---

## Task 5: Final Validation and PR

- [ ] Run full check: `upskill lint --strict` (all items pass)
- [ ] Run `upskill fmt` (no changes — already formatted)
- [ ] Run `dprint check` (no changes)
- [ ] Push branch: `git push -u origin feat/phase-3-architecture-experts`
- [ ] Create PR:
  ```
  Title: feat(skills): Phase 3 — Architecture expert skills
  Body:
  ## Summary
  Adds 3 architecture expert skills for Phase 3 of the metapowers curated expansion:
  - `domain-driven-design` — Strategic & tactical DDD patterns
  - `event-driven-architecture` — Event sourcing, CQRS, sagas, outbox, idempotency
  - `reactive-systems` — Reactive manifesto, back-pressure, supervision, circuit breakers

  Bumps bundle to v0.4.0.

  ## Checklist
  - [x] All skills pass `upskill lint --strict`
  - [x] Formatted with `upskill fmt` + `dprint`
  - [x] Bundle manifest updated and validated
  ```
- [ ] Verify CI passes
