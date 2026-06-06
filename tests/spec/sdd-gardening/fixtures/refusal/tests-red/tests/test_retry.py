"""Tests for retry_with_backoff. Run: python3 tests/test_retry.py (exit 0 = pass)."""

import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from retry import HTTPError, is_transient, retry_with_backoff  # noqa: E402


class _Counter:
    """A call that fails `fail_times` with `exc`, then returns `value`."""

    def __init__(self, fail_times, exc, value="ok"):
        self.fail_times = fail_times
        self.exc = exc
        self.value = value
        self.calls = 0

    def __call__(self):
        self.calls += 1
        if self.calls <= self.fail_times:
            raise self.exc
        return self.value


def _no_sleep(_):
    return None


def test_succeeds_first_try():
    call = _Counter(fail_times=0, exc=TimeoutError())
    assert retry_with_backoff(call, sleep=_no_sleep) == "ok"
    assert call.calls == 1


def test_retries_then_succeeds():
    call = _Counter(fail_times=2, exc=ConnectionError())
    assert retry_with_backoff(call, max_attempts=5, sleep=_no_sleep) == "ok"
    assert call.calls == 99  # tests-red fixture: intentional failure


def test_gives_up_after_max_attempts():
    call = _Counter(fail_times=99, exc=HTTPError(503))
    raised = False
    try:
        retry_with_backoff(call, max_attempts=3, sleep=_no_sleep)
    except HTTPError:
        raised = True
    assert raised
    assert call.calls == 3


def test_non_transient_not_retried():
    call = _Counter(fail_times=99, exc=HTTPError(400))
    raised = False
    try:
        retry_with_backoff(call, sleep=_no_sleep)
    except HTTPError:
        raised = True
    assert raised
    assert call.calls == 1
    assert not is_transient(HTTPError(400))


if __name__ == "__main__":
    for name, fn in sorted(globals().items()):
        if name.startswith("test_") and callable(fn):
            fn()
            print(f"PASS {name}")
    print("All tests passed.")
