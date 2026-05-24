# Metapowers Phase 2: Domain Expertise — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four domain-expertise skills that give AI agents deep, actionable knowledge in Rust, Kotlin, TypeScript, and testing strategy — producing measurably better code than unguided generation.
**Architecture:** Four independent skills in `skills/<name>/SKILL.md`, each 100–200 lines of expert-level content with decision trees, code examples, anti-patterns, and checklists. Registered in `metapowers.bundle.yaml`.
**Tech Stack:** Markdown with YAML frontmatter (upskill portable format), validated by `upskill lint`, formatted by `upskill fmt` and `dprint`.

---

## Task 1: Scaffold and write `rust-expert`

- [ ] Run `upskill new skill rust-expert`
- [ ] Write full skill content to `skills/rust-expert/SKILL.md`:

````markdown
---
description: >
  Use when working with Rust language, FFI/JNI integration with Android/Kotlin,
  unsafe code review, memory safety, or safety-critical native components
activation: auto
---

# Rust Expert

## Ownership & Borrowing

### Decision: Borrow vs Clone vs Move

```text
Need the value after this call?
├── No  → move it (pass by value)
└── Yes
    ├── Caller only reads? → &T (shared borrow)
    ├── Caller mutates?    → &mut T (exclusive borrow)
    └── Multiple owners needed?
        ├── Single-threaded → Rc<T>
        └── Multi-threaded  → Arc<T>
```
````

**Clone only when:**

- The type is cheap to clone (small Copy types, short strings)
- You genuinely need independent ownership in two places
- Satisfying the borrow checker would require unsafe or lifetime gymnastics

**Anti-pattern — Defensive `.clone()`:**

```rust
// BAD: cloning to silence the borrow checker
let name = self.name.clone();
self.process(&name);

// GOOD: restructure to avoid the conflict
let result = self.compute_name();
self.process(&result);
```

### Lifetime Annotations

**When you need explicit lifetimes:**

- Function returns a reference derived from an input
- Struct holds a reference
- Multiple reference params and the compiler can't infer which output borrows from

**Elision rules (you get these free):**

1. Each input reference gets its own lifetime
2. If exactly one input lifetime, output gets that lifetime
3. If `&self` or `&mut self`, output gets `self`'s lifetime

```rust
// Explicit needed: two inputs, ambiguous output
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str

// Not needed: single input lifetime
fn first_word(s: &str) -> &str
```

**Anti-pattern — Overly broad lifetimes:**

```rust
// BAD: forces both to live as long as the longest
struct Parser<'a> {
    input: &'a str,
    buffer: &'a mut Vec<u8>, // buffer doesn't need same lifetime as input
}

// GOOD: separate lifetimes
struct Parser<'a, 'b> {
    input: &'a str,
    buffer: &'b mut Vec<u8>,
}
```

## Async / Tokio

### Task Spawning

```rust
// CPU-bound work: use spawn_blocking
let result = tokio::task::spawn_blocking(move || {
    expensive_computation(&data)
}).await?;

// IO-bound concurrent work: use tokio::spawn
let handle = tokio::spawn(async move {
    fetch_data(url).await
});
```

### select! Patterns

```rust
// Graceful shutdown pattern
loop {
    tokio::select! {
        // IMPORTANT: put shutdown branch first for priority
        _ = shutdown_rx.recv() => {
            info!("shutting down");
            break;
        }
        msg = rx.recv() => {
            match msg {
                Some(m) => handle(m).await,
                None => break, // channel closed
            }
        }
    }
}
```

**Cancellation safety checklist:**

- Is the future in each `select!` branch cancellation-safe?
- `tokio::sync::mpsc::Receiver::recv()` — SAFE
- `tokio::io::AsyncReadExt::read()` — NOT SAFE (partial reads lost)
- If unsafe, use `tokio::pin!` + a persistent future outside the loop

### Channel Selection

| Channel     | Use when                                  |
| ----------- | ----------------------------------------- |
| `mpsc`      | Multiple producers, one consumer          |
| `oneshot`   | Single response (request/reply)           |
| `broadcast` | Multiple consumers, all get every message |
| `watch`     | Latest-value only, multiple consumers     |

### Graceful Shutdown

```rust
// 1. Create a shutdown signal
let (shutdown_tx, mut shutdown_rx) = tokio::sync::broadcast::channel(1);

// 2. Pass to all tasks
// 3. On SIGTERM/SIGINT:
shutdown_tx.send(()).ok();

// 4. Each task checks:
tokio::select! {
    _ = shutdown_rx.recv() => return Ok(()),
    result = do_work() => handle(result),
}

// 5. Await all task handles with timeout
tokio::time::timeout(Duration::from_secs(30), join_all(handles)).await?;
```

## Error Handling

### When to use which

| Crate       | Use for                                                         |
| ----------- | --------------------------------------------------------------- |
| `thiserror` | Library code, public error types, errors that callers match on  |
| `anyhow`    | Application code, CLI tools, where you just propagate + context |

### Context pattern (anyhow)

```rust
// BAD: naked ?
let file = File::open(path)?;

// GOOD: context for debugging
let file = File::open(path)
    .with_context(|| format!("failed to open config at {}", path.display()))?;
```

### Error enum design (thiserror)

```rust
#[derive(Debug, thiserror::Error)]
pub enum ParseError {
    #[error("invalid header at line {line}: {reason}")]
    InvalidHeader { line: usize, reason: String },

    #[error("unexpected EOF after {bytes_read} bytes")]
    UnexpectedEof { bytes_read: u64 },

    #[error(transparent)]
    Io(#[from] std::io::Error),
}
```

**Anti-pattern — Stringly typed errors:**

```rust
// BAD
Err(anyhow!("parse error")) // no structure, no context

// GOOD
Err(ParseError::InvalidHeader { line: 42, reason: "missing version".into() })
```

## Unsafe Code

### Audit Checklist

Before writing or approving `unsafe`:

1. **Is unsafe actually required?** Can safe abstractions achieve this?
2. **What invariant does this rely on?** Document it in a `// SAFETY:` comment
3. **Who upholds the invariant?** The caller? The module? A type?
4. **What happens if the invariant breaks?** UB? Data race? Memory corruption?
5. **Is the unsafe surface minimal?** Wrap in a safe API as tightly as possible
6. **Are there tests for boundary conditions?** Miri, ASAN, edge cases?

```rust
// SAFETY: `ptr` is guaranteed non-null and aligned by the allocator in `new()`.
// The lifetime of the returned reference is tied to `&self`, preventing use-after-free.
unsafe { &*self.ptr }
```

### Soundness Rules

- Never create `&mut T` aliases (instant UB)
- Never create dangling references
- Never break type invariants (e.g., invalid UTF-8 in String)
- Run `cargo +nightly miri test` on all unsafe code paths

## FFI / C Interop

### Safe Wrapper Pattern

```rust
// Raw FFI binding
extern "C" {
    fn c_process(data: *const u8, len: usize) -> i32;
}

// Safe wrapper
pub fn process(data: &[u8]) -> Result<(), FfiError> {
    // SAFETY: data.as_ptr() is valid for data.len() bytes,
    // and c_process does not retain the pointer.
    let ret = unsafe { c_process(data.as_ptr(), data.len()) };
    match ret {
        0 => Ok(()),
        e => Err(FfiError::from_code(e)),
    }
}
```

### CString/CStr Checklist

- Use `CString::new(s)?` for owned strings passed to C (checks for interior nulls)
- Use `CStr::from_ptr(ptr)` for borrowing C strings (unsafe, must be null-terminated)
- Never let a `CString` drop while C still holds the pointer

```text
- [ ] Validate: `upskill lint skills/rust-expert/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git add skills/rust-expert && git commit -m "feat(skills): add rust-expert domain skill"`
```

---

## Task 2: Scaffold and write `kotlin-expert`

- [ ] Run `upskill new skill kotlin-expert`
- [ ] Write full skill content to `skills/kotlin-expert/SKILL.md`:

````markdown
---
description: >
  Use when working with Kotlin language features, coroutines, Flow, Jetpack
  Compose UI, DSL design, or Android SDK integration
activation: auto
---

# Kotlin Expert

## Coroutines

### Structured Concurrency

Every coroutine must have a parent scope. Never use `GlobalScope` in production.

```kotlin
// BAD: fire-and-forget, leaks if class is destroyed
GlobalScope.launch { fetchData() }

// GOOD: tied to lifecycle
class MyViewModel : ViewModel() {
    fun load() {
        viewModelScope.launch {
            val data = repository.fetch()
            _state.value = data
        }
    }
}
```
````

### coroutineScope vs supervisorScope

| Scope             | Child failure behavior                          | Use when                                       |
| ----------------- | ----------------------------------------------- | ---------------------------------------------- |
| `coroutineScope`  | Any child failure cancels all siblings + parent | All-or-nothing parallel work                   |
| `supervisorScope` | Child failure does NOT cancel siblings          | Independent parallel tasks, partial failure OK |

```kotlin
// All-or-nothing: if one fails, cancel all
suspend fun fetchBoth(): Pair<A, B> = coroutineScope {
    val a = async { fetchA() }
    val b = async { fetchB() }
    a.await() to b.await()
}

// Independent: log errors individually
suspend fun refreshAll() = supervisorScope {
    launch { refreshUsers() }   // if this fails...
    launch { refreshPosts() }   // ...this keeps running
}
```

### Cancellation

```kotlin
// Check cancellation in long-running loops
suspend fun processItems(items: List<Item>) {
    for (item in items) {
        ensureActive() // throws CancellationException if cancelled
        process(item)
    }
}

// Use withContext for CPU-bound work (moves to Dispatchers.Default)
suspend fun parse(data: ByteArray): Result = withContext(Dispatchers.Default) {
    heavyParsing(data)
}
```

### Dispatcher Selection

| Dispatcher                   | Use for                              |
| ---------------------------- | ------------------------------------ |
| `Dispatchers.Main`           | UI updates only                      |
| `Dispatchers.IO`             | Blocking I/O (file, network, DB)     |
| `Dispatchers.Default`        | CPU-intensive computation            |
| `Dispatchers.Main.immediate` | Avoid re-dispatch if already on Main |

## Flow

### Cold vs Hot

| Type         | Cold/Hot | Replay       | Use case                                |
| ------------ | -------- | ------------ | --------------------------------------- |
| `Flow`       | Cold     | None         | One-shot streams, transformations       |
| `StateFlow`  | Hot      | 1 (latest)   | UI state, always has a current value    |
| `SharedFlow` | Hot      | Configurable | Events, 0 replay = no replay on new sub |

### StateFlow vs SharedFlow Decision

```text
Does it represent current state?
├── Yes → StateFlow (requires initial value, .value accessor)
│   └── Does UI need to observe it? → Expose as StateFlow<UiState>
└── No → Is it an event/action?
    ├── Yes → SharedFlow(replay = 0) — events should not replay
    └── Multiple subscribers need history? → SharedFlow(replay = N)
```

### Operators & Patterns

```kotlin
// Debounce search input
searchFlow
    .debounce(300)
    .distinctUntilChanged()
    .flatMapLatest { query -> repository.search(query) }
    .catch { emit(SearchResult.Error(it)) }
    .collect { updateUi(it) }

// Combine multiple states
combine(userFlow, settingsFlow) { user, settings ->
    UiState(user, settings)
}.stateIn(
    scope = viewModelScope,
    started = SharingStarted.WhileSubscribed(5000),
    initialValue = UiState.Loading
)
```

**Anti-pattern — collecting in init without lifecycle awareness:**

```kotlin
// BAD: collects forever, even when UI is gone
init { scope.launch { flow.collect { ... } } }

// GOOD: use WhileSubscribed or repeatOnLifecycle
```

### Backpressure

```kotlin
// Buffer when producer is faster than consumer
flow.buffer(capacity = 64)

// Or drop old values
flow.conflate() // keeps only latest

// Or use Channel with specific strategy
val channel = Channel<Event>(
    capacity = 64,
    onBufferOverflow = BufferOverflow.DROP_OLDEST
)
```

## Channel Patterns

| Type       | Capacity | Behavior                                      |
| ---------- | -------- | --------------------------------------------- |
| Rendezvous | 0        | Sender suspends until receiver ready          |
| Buffered   | N        | Sender suspends when buffer full              |
| Conflated  | 1        | Only latest value kept, never suspends sender |
| Unlimited  | MAX      | Never suspends sender (OOM risk)              |

```kotlin
// Fan-out: multiple consumers share work
val tasks = Channel<Task>(capacity = 100)
repeat(4) { workerId ->
    launch { for (task in tasks) process(task) }
}

// Actor pattern: serialize access to mutable state
val actor = Channel<Msg>(Channel.BUFFERED)
launch {
    var state = initialState
    for (msg in actor) { state = reduce(state, msg) }
}
```

## Compose Integration

### collectAsState

```kotlin
@Composable
fun UserScreen(viewModel: UserViewModel) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    // Recomposes only when state changes
    UserContent(state)
}
```

### Side Effects

| Effect                     | Use when                                    |
| -------------------------- | ------------------------------------------- |
| `LaunchedEffect(key)`      | Run suspend fun when key changes            |
| `rememberCoroutineScope()` | Launch from callbacks (onClick)             |
| `DisposableEffect(key)`    | Setup/teardown (listeners)                  |
| `SideEffect`               | Non-suspend side effect every recomposition |

```kotlin
// One-shot load
LaunchedEffect(userId) {
    viewModel.loadUser(userId)
}

// From callback
val scope = rememberCoroutineScope()
Button(onClick = { scope.launch { viewModel.submit() } })
```

**Anti-pattern — launching in composition:**

```kotlin
// BAD: launches on every recomposition
@Composable fun Bad() {
    CoroutineScope(Dispatchers.IO).launch { fetch() } // NEVER do this
}
```

## Testing Coroutines

```kotlin
@Test
fun `emits loading then success`() = runTest {
    val vm = MyViewModel(FakeRepository())
    vm.uiState.test { // Turbine
        assertEquals(UiState.Loading, awaitItem())
        assertEquals(UiState.Success(data), awaitItem())
        cancelAndConsumeRemainingEvents()
    }
}

// Advance virtual time
@Test
fun `debounce waits 300ms`() = runTest {
    val results = mutableListOf<String>()
    val flow = searchFlow.debounce(300)
    val job = launch { flow.collect { results.add(it) } }
    advanceTimeBy(299)
    assertTrue(results.isEmpty())
    advanceTimeBy(1)
    assertEquals(1, results.size)
    job.cancel()
}
```

### TestDispatcher Selection

| Dispatcher                 | Behavior                                               |
| -------------------------- | ------------------------------------------------------ |
| `StandardTestDispatcher`   | Requires manual `advanceUntilIdle()` — precise control |
| `UnconfinedTestDispatcher` | Eager execution — simpler but less control             |

```text
- [ ] Validate: `upskill lint skills/kotlin-expert/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git add skills/kotlin-expert && git commit -m "feat(skills): add kotlin-expert domain skill"`
```

---

## Task 3: Scaffold and write `typescript-expert`

- [ ] Run `upskill new skill typescript-expert`
- [ ] Write full skill content to `skills/typescript-expert/SKILL.md`:

````markdown
---
description: >
  Use when working with TypeScript strict mode, advanced type system features,
  async patterns, module design, or type narrowing strategies
activation: auto
---

# TypeScript Expert

## Strict Mode

Enable ALL strict flags. Non-negotiable for new projects:

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,                    // enables all below
    "noUncheckedIndexedAccess": true,  // arr[0] is T | undefined
    "exactOptionalProperties": true,   // undefined !== missing
    "noPropertyAccessFromIndexSignature": true
  }
}
```
````

| Flag                       | What it catches                                                  |
| -------------------------- | ---------------------------------------------------------------- |
| `strictNullChecks`         | Prevents `null`/`undefined` from being assignable to other types |
| `strictFunctionTypes`      | Enforces contravariant parameter types                           |
| `strictBindCallApply`      | Types `bind`, `call`, `apply` correctly                          |
| `noImplicitAny`            | Forces explicit types where inference fails                      |
| `noUncheckedIndexedAccess` | Array/object index returns `T \| undefined`                      |

## Type System

### Discriminated Unions

```typescript
// Always use a literal discriminant field
type Result<T> =
  | { status: "success"; data: T }
  | { status: "error"; error: Error }
  | { status: "loading" };

function handle<T>(result: Result<T>) {
  switch (result.status) {
    case "success": return result.data;   // narrowed
    case "error": throw result.error;     // narrowed
    case "loading": return null;
  }
  // exhaustiveness: result is `never` here
  const _exhaustive: never = result;
}
```

### Conditional Types

```typescript
// Extract return type of async functions
type AsyncReturnType<T extends (...args: any[]) => Promise<any>> =
  T extends (...args: any[]) => Promise<infer R> ? R : never;

// Distribute over unions
type NonNullable<T> = T extends null | undefined ? never : T;

// Practical: make specific keys required
type RequireKeys<T, K extends keyof T> = T & Required<Pick<T, K>>;
```

### Mapped Types

```typescript
// Make all properties readonly recursively
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K];
};

// Create a partial update type
type UpdatePayload<T> = {
  [K in keyof T]?: T[K] extends object ? UpdatePayload<T[K]> : T[K];
};
```

### Template Literal Types

```typescript
type EventName = `on${Capitalize<string>}`;
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";
type ApiRoute = `/${string}`;
type TypedRoute = `/${HttpMethod extends infer M ? Lowercase<M & string> : never}/${string}`;

// Practical: typed event emitter
type EventMap = {
  click: MouseEvent;
  keydown: KeyboardEvent;
};
type EventHandler<K extends keyof EventMap> = (event: EventMap[K]) => void;
```

### Branded Types

```typescript
// Prevent mixing semantically different values
type UserId = string & { readonly __brand: "UserId" };
type OrderId = string & { readonly __brand: "OrderId" };

function createUserId(raw: string): UserId {
  if (!raw.startsWith("usr_")) throw new Error("Invalid user ID");
  return raw as UserId;
}

// Now these are compile-time errors:
// getUser(orderId) — Type 'OrderId' is not assignable to type 'UserId'
```

## Async Patterns

### Promise.all vs Promise.allSettled

```typescript
// all: fail-fast. Use when ALL must succeed.
const [users, posts] = await Promise.all([fetchUsers(), fetchPosts()]);

// allSettled: partial failure OK. Use for independent operations.
const results = await Promise.allSettled([sendEmail(), sendSms(), sendPush()]);
const failures = results.filter(r => r.status === "rejected");
```

### AbortController

```typescript
async function fetchWithTimeout(url: string, ms: number): Promise<Response> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), ms);
  try {
    return await fetch(url, { signal: controller.signal });
  } finally {
    clearTimeout(timeout);
  }
}

// Cancellable operations
function createCancellable<T>(fn: (signal: AbortSignal) => Promise<T>) {
  const controller = new AbortController();
  return {
    promise: fn(controller.signal),
    cancel: () => controller.abort(),
  };
}
```

### Async Iterators

```typescript
// Paginated API consumption
async function* fetchPages<T>(url: string): AsyncGenerator<T[]> {
  let cursor: string | undefined;
  do {
    const res = await fetch(`${url}?cursor=${cursor ?? ""}`);
    const { data, nextCursor } = await res.json();
    cursor = nextCursor;
    yield data;
  } while (cursor);
}

// Usage
for await (const page of fetchPages<User>("/api/users")) {
  process(page);
}
```

## Module Design

### Barrel File Rules

```text
Should I use a barrel (index.ts)?
├── Public API boundary (package entry)? → YES, explicit exports
├── Internal module? → NO, import directly
└── Causes circular deps? → NO, break the cycle
```

**Anti-pattern — Re-exporting everything:**

```typescript
// BAD: barrel that re-exports internal details
export * from "./internals";
export * from "./helpers";

// GOOD: explicit public API
export { createUser, type User } from "./user";
export { createOrder, type Order } from "./order";
```

### Circular Dependency Resolution

1. Extract shared types to a `types.ts` with no imports from your modules
2. Use dependency injection instead of direct imports
3. Use the `import type` syntax for type-only imports (never causes runtime cycles)

### Tree-Shaking

```typescript
// BAD: side-effectful module initialization
const config = loadConfig(); // runs on import!
export function getConfig() { return config; }

// GOOD: lazy initialization
let config: Config | undefined;
export function getConfig() {
  config ??= loadConfig();
  return config;
}
```

## Type Narrowing

### Type Guards

```typescript
// User-defined type guard
function isError(value: unknown): value is Error {
  return value instanceof Error;
}

// Discriminated union guard
function isSuccess<T>(result: Result<T>): result is { status: "success"; data: T } {
  return result.status === "success";
}
```

### Assertion Functions

```typescript
function assertDefined<T>(value: T | undefined, msg?: string): asserts value is T {
  if (value === undefined) throw new Error(msg ?? "Expected defined value");
}

// After this call, TS knows `user` is defined
assertDefined(user, "User not found");
user.name; // no error
```

### `satisfies` Operator

```typescript
// Validates type without widening
const routes = {
  home: "/",
  about: "/about",
  user: "/user/:id",
} satisfies Record<string, string>;

// `routes.home` is still the literal "/" not `string`
type HomeRoute = typeof routes.home; // "/"
```

**Anti-pattern — `as` for validation:**

```typescript
// BAD: as doesn't validate, it lies
const config = { port: "oops" } as Config; // no error!

// GOOD: satisfies validates at compile time
const config = { port: "oops" } satisfies Config; // ERROR
```

```text
- [ ] Validate: `upskill lint skills/typescript-expert/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git add skills/typescript-expert && git commit -m "feat(skills): add typescript-expert domain skill"`
```

---

## Task 4: Scaffold and write `testing-taxonomy`

- [ ] Run `upskill new skill testing-taxonomy`
- [ ] Write full skill content to `skills/testing-taxonomy/SKILL.md`:

````markdown
---
description: >
  Use when deciding test strategy — which test types to use, how to structure
  fixtures, triage flaky tests, or evaluate test suite health
activation: auto
---

# Testing Taxonomy

## When to Use Each Test Type

### Decision Tree

```text
What are you testing?
├── Pure logic (no I/O, no deps)
│   → Unit test
├── Interaction between 2+ modules with real deps
│   → Integration test
├── Full user journey through deployed system
│   → E2E test (limit to critical paths only)
├── Invariant that should hold for ALL valid inputs
│   → Property-based test
├── API contract between services
│   → Contract test (Pact, OpenAPI validation)
└── "Are my tests actually catching bugs?"
    → Mutation testing
```
````

### Test Type Reference

| Type        | Speed    | Confidence          | Maintenance | Use for                                 |
| ----------- | -------- | ------------------- | ----------- | --------------------------------------- |
| Unit        | ~1ms     | Low (isolated)      | Low         | Pure functions, algorithms, parsing     |
| Integration | ~100ms   | Medium              | Medium      | DB queries, HTTP clients, module wiring |
| E2E         | ~10s     | High                | High        | Critical user flows (login, checkout)   |
| Property    | ~50ms    | High for invariants | Low         | Serialization roundtrips, parsers, math |
| Contract    | ~100ms   | High for APIs       | Medium      | Service boundaries, schema evolution    |
| Mutation    | ~minutes | Meta (test quality) | None        | CI gate for test suite quality          |

## Test Shape Models

### Pyramid vs Trophy vs Honeycomb

```text
PYRAMID (backend services)        TROPHY (frontend/fullstack)     HONEYCOMB (microservices)
    /\                              ___                              ___
   /E2E\                           |E2E|                           |E2E|
  /------\                         |---|                           |---|
 /Integr. \                        |Int|  ← MOST HERE             |Int| ← MOST HERE
/----------\                       |---|                           |---|
|   Unit    | ← MOST HERE          |Unt|                          |Unt| ← FEW
+----------+                       +---+                           +---+
```

**Choose your model:**

- **Pyramid**: Pure backend, many algorithms, stable APIs → lots of unit tests
- **Trophy**: Frontend or fullstack apps → integration tests give best ROI
- **Honeycomb**: Microservices → integration tests at boundaries, few units

## Fixture Strategies

### Builders (recommended default)

```typescript
// Builder pattern: explicit, composable, readable
const user = UserBuilder.create()
  .withName("Alice")
  .withRole("admin")
  .build();
```

### Factories (when you need many variations)

```typescript
// Factory: generates valid defaults, override what matters
const user = createUser({ role: "admin" }); // other fields auto-generated
```

### Test Doubles Decision

```text
What are you replacing?
├── Need to verify it was called? → Mock (verify interactions)
├── Need a simple return value? → Stub (canned response)
├── Need working behavior without real infra? → Fake (in-memory DB)
└── Need to observe but not change? → Spy (wraps real impl)
```

| Double | Coupling | Use when                                       |
| ------ | -------- | ---------------------------------------------- |
| Stub   | Low      | Simple return values, no behavior verification |
| Mock   | High     | Verifying interactions (use sparingly)         |
| Fake   | Medium   | Need realistic behavior without real infra     |
| Spy    | Low      | Observing calls on a real implementation       |

**Anti-pattern — Mocking everything:**

```typescript
// BAD: tests implementation details, breaks on refactor
jest.mock("./userService");
jest.mock("./emailService");
jest.mock("./database");
// This test asserts nothing about behavior, only about wiring

// GOOD: use a fake database, test real behavior
const db = createInMemoryDatabase();
const service = new UserService(db);
const user = await service.create({ name: "Alice" });
expect(await db.findById(user.id)).toEqual(user);
```

## Flaky Test Triage

### Identification

Symptoms of flaky tests:

- Passes locally, fails in CI (timing, resource contention)
- Fails intermittently on same commit
- Depends on test execution order
- Uses real time (`setTimeout`, `Date.now`)

### Triage Protocol

```text
1. QUARANTINE immediately (move to "flaky" suite, don't block CI)
2. CLASSIFY the root cause:
   ├── Timing dependency → Use fake timers or explicit waits
   ├── Shared state → Isolate setup/teardown per test
   ├── External dependency → Use fakes or containers
   ├── Race condition → Add proper synchronization
   └── Order dependency → Fix test isolation
3. FIX within 1 sprint (quarantine is not permanent)
4. VERIFY by running 100x: `for i in {1..100}; do npm test -- --testNamePattern="flaky"; done`
```

### Prevention Checklist

- [ ] No `sleep()` / `setTimeout()` for synchronization — use polling or events
- [ ] No shared mutable state between tests — fresh setup per test
- [ ] No reliance on test execution order — each test is independent
- [ ] No real network calls — use fakes, mocks, or containers
- [ ] No real filesystem without `tmp` dirs — isolated temp directories
- [ ] Deterministic time — inject or fake `Date.now()`
- [ ] Deterministic randomness — seed your RNG in tests

## Test Naming

### Convention: `should_[expected]_when_[condition]`

```text
// Unit tests: behavior-focused
should_return_empty_list_when_no_items_match
should_throw_validation_error_when_email_invalid
should_calculate_discount_when_quantity_above_threshold

// Integration tests: scenario-focused
should_persist_and_retrieve_user_through_repository
should_return_404_when_resource_not_found
should_retry_on_transient_failure
```

**Anti-pattern — Test names that describe implementation:**

```text
// BAD: coupled to implementation
test_calls_repository_findById
test_invokes_email_service

// GOOD: describes behavior
test_returns_user_when_exists
test_sends_welcome_email_on_registration
```

## Coverage Guidelines

- **Don't chase 100%** — diminishing returns past ~80% line coverage
- **Measure branch coverage** — more useful than line coverage
- **Track mutation score** for critical modules (aim for >70%)
- **Coverage floors, not ceilings** — prevent regression, don't mandate arbitrary targets
- **Exclude generated code** — don't inflate/deflate metrics with codegen

```text
- [ ] Validate: `upskill lint skills/testing-taxonomy/SKILL.md --strict`
- [ ] Format: `upskill fmt`
- [ ] Commit: `git add skills/testing-taxonomy && git commit -m "feat(skills): add testing-taxonomy domain skill"`
```

---

## Task 5: Update `metapowers.bundle.yaml`

- [ ] Add all four new skills to the `items:` section of `metapowers.bundle.yaml`
- [ ] Bump version from `0.2.0` to `0.3.0`
- [ ] Validate: `upskill lint metapowers.bundle.yaml --strict`
- [ ] Commit: `git add metapowers.bundle.yaml && git commit -m "feat(bundle): add phase 2 domain expertise skills, bump to v0.3.0"`

---

## Task 6: Final validation and PR

- [ ] Run `upskill lint --all --strict` — zero errors
- [ ] Run `upskill fmt` — no changes (already formatted)
- [ ] Run `dprint check` — passes
- [ ] Push branch and create PR:

  ```bash
  git push -u origin feat/phase-2-domain-expertise
  gh pr create \
    --title "feat: Phase 2 — domain expertise skills (rust, kotlin, typescript, testing)" \
    --body "Adds four domain-expertise skills for Phase 2 of the metapowers curated expansion.

  ## Skills added
  - \`rust-expert\` — Ownership, lifetimes, async/tokio, error handling, unsafe, FFI
  - \`kotlin-expert\` — Coroutines, Flow, Channels, Compose, testing
  - \`typescript-expert\` — Strict mode, type system, async, modules, narrowing
  - \`testing-taxonomy\` — Test types, pyramid models, fixtures, flaky triage

  ## Checklist
  - [x] All skills pass \`upskill lint --strict\`
  - [x] All skills formatted with \`upskill fmt\`
  - [x] Bundle updated to v0.3.0
  - [x] Each skill is 100-200 lines of actionable expert content"
  ```
