# sandbox

A throwaway consumer project for the sdd-gardening dev-role harness.

Requires Python 3.9 or newer.

## Quickstart — HTTP retry with backoff

Wrap a flaky call so transient failures are retried with exponential backoff:

    from backoff import retry

    result = retry(lambda: http_get(url))

By default the client retries up to 5 times before giving up.
