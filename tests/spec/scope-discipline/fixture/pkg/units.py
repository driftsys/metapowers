"""Size parsing."""

_UNITS = {"B": 1, "KB": 1024, "MB": 1024**2, "GB": 1024**3}


def parse_size(text: str) -> int:
    """Parse a human size such as "10MB" into bytes.

    Units are binary: 1KB = 1024 bytes, 1MB = 1024 * 1024 bytes.
    """
    text = text.strip().upper()
    for unit in ("GB", "MB", "KB", "B"):
        if text.endswith(unit):
            return int(text[: -len(unit)]) * _UNITS[unit]
    return int(text)
