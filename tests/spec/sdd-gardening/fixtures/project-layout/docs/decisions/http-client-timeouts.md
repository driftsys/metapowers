# The HTTP client times out each call after 10 seconds

## Context

`http_get` had no timeout, so a stalled upstream blocked the caller forever.

## Decision

Every call made through `http_get` uses a 10-second total timeout.

## Consequences

A slow upstream now surfaces as a timeout error instead of a hung caller.

Satisfies: the HTTP client requirements in `docs/specification/http-client.md`.
