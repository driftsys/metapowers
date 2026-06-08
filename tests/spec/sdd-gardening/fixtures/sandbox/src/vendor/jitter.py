# Vendored from full-jitter v1.2.0 — https://github.com/example/full-jitter
# License: MIT. Do not edit locally; re-sync from upstream.
"""Third-party full-jitter helper, vendored by the retry-backoff feature."""

import random


def full_jitter(delay: float) -> float:
    """Return a jittered delay uniformly in [0, delay]."""
    return random.uniform(0.0, delay)
