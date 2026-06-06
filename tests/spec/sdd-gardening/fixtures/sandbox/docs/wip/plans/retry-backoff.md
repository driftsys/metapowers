# Plan: HTTP client retry with backoff

## Approach

Add a small `retry_with_backoff` wrapper in `src/retry.py`. It takes a
zero-argument callable and a classifier that decides whether an exception is
transient. The wrapper owns the loop, the delay schedule, and the give-up
condition; the HTTP layer stays unaware of retry policy.

## Building blocks

- `is_transient(exc) -> bool` — classifies an exception as retryable. Transient:
  `ConnectionError`, `TimeoutError`, and `HTTPError` with status in {502, 503,
  504}. Everything else is non-transient.
- `retry_with_backoff(call, *, max_attempts, base_delay, is_transient, sleep)` —
  runs `call()`; on a transient error sleeps `base_delay * 2**attempt` with full
  jitter, then retries; re-raises the last error once attempts are exhausted; a
  non-transient error propagates immediately. `sleep` is injected so tests can
  pass a fake clock instead of really sleeping.

## Interfaces

```text
retry_with_backoff(
    call: Callable[[], T],
    *,
    max_attempts: int = 3,
    base_delay: float = 0.1,
    is_transient: Callable[[BaseException], bool] = is_transient,
    sleep: Callable[[float], None] = time.sleep,
) -> T
```

## Tasks (TDD)

1. RED: write `test_succeeds_first_try` — call returning a value is returned
   without sleeping. Run, watch it fail (no module yet).
2. GREEN: implement the happy path.
3. RED: `test_retries_then_succeeds` — fails N-1 times then succeeds; assert the
   value and the number of sleeps.
4. GREEN: add the retry loop with exponential delay.
5. RED: `test_gives_up_after_max_attempts` — always-transient call re-raises the
   last error after the budget.
6. GREEN: add the give-up branch.
7. RED: `test_non_transient_not_retried` — non-transient raises immediately, zero
   sleeps.
8. GREEN: add the classifier short-circuit.
9. REFACTOR: extract the delay schedule; inject `sleep` and jitter source.

## Verification

`python3 tests/test_retry.py` runs the four cases with a fake clock (no real
delay) and exits non-zero on any failure.
