# Spec: HTTP client retry with backoff

## Problem & goal

The `http_get` helper fails permanently on the first transient error (connection
reset, 503, timeout). Callers that hit a flaky upstream get spurious failures.
We want transient failures to be retried automatically with an increasing delay,
so a brief upstream blip is absorbed rather than surfaced.

## Requirements

- R1. When a wrapped call raises a transient error, the client retries the call
  rather than propagating the error on the first failure.
- R2. The delay between retries grows exponentially with the attempt number
  (delay = base · 2^attempt).
- R3. Each delay has random jitter applied so that many clients retrying after a
  shared outage do not synchronise into a thundering herd.
- R4. After the retry budget is exhausted, the client raises the last error to
  the caller. The default retry budget is 5 attempts.
- R5. A non-transient error (e.g. a 400) is raised immediately and is never
  retried.

## Out of scope

- Per-host retry budgets and circuit breaking.
- Respecting a server `Retry-After` header (future work).
