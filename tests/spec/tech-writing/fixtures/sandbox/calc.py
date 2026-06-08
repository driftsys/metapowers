def add(a, b, *, round_to=None):
    """Return a + b, optionally rounded to round_to decimal places."""
    total = a + b
    return total if round_to is None else round(total, round_to)
