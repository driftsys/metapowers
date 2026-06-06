"""Retry a flaky call with exponential backoff and full jitter."""

from __future__ import annotations

import random
import time
from typing import Callable, TypeVar

T = TypeVar("T")

_TRANSIENT_STATUSES = {502, 503, 504}


class HTTPError(Exception):
    def __init__(self, status: int) -> None:
        super().__init__(f"HTTP {status}")
        self.status = status


def is_transient(exc: BaseException) -> bool:
    """True if the error is worth retrying."""
    if isinstance(exc, (ConnectionError, TimeoutError)):
        return True
    if isinstance(exc, HTTPError):
        return exc.status in _TRANSIENT_STATUSES
    return False


def retry_with_backoff(
    call: Callable[[], T],
    *,
    max_attempts: int = 3,
    base_delay: float = 0.1,
    is_transient: Callable[[BaseException], bool] = is_transient,
    sleep: Callable[[float], None] = time.sleep,
    jitter: Callable[[float], float] = random.uniform,
) -> T:
    """Call ``call()``; on a transient error, back off and retry.

    The delay before retry ``n`` is ``base_delay * 2**n`` with full jitter in
    ``[0, delay]``. A non-transient error propagates immediately. Once
    ``max_attempts`` is reached the last error is re-raised.
    """
    attempt = 0
    while True:
        try:
            return call()
        except BaseException as exc:  # noqa: BLE001 - re-raised below
            attempt += 1
            if not is_transient(exc) or attempt >= max_attempts:
                raise
            delay = base_delay * (2 ** (attempt - 1))
            sleep(jitter(0.0, delay))
