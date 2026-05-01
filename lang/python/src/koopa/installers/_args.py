"""Parse passthrough CLI args into keyword arguments."""

from __future__ import annotations


def parse_passthrough(
    args: list[str] | None,
) -> dict[str, str | list[str]]:
    """Parse ``--key=value`` passthrough args into a dict.

    Handles repeated keys by collecting values into a list.
    """
    if not args:
        return {}
    result: dict[str, str | list[str]] = {}
    for arg in args:
        if not arg.startswith("--") or "=" not in arg:
            continue
        key, _, value = arg.partition("=")
        key = key.lstrip("-").replace("-", "_")
        if key in result:
            existing = result[key]
            if isinstance(existing, list):
                existing.append(value)
            else:
                result[key] = [existing, value]
        else:
            result[key] = value
    return result


def get_str(kwargs: dict[str, str | list[str]], key: str, default: str = "") -> str:
    """Get a string value from parsed passthrough args."""
    value = kwargs.get(key, default)
    if isinstance(value, list):
        return value[0]
    return value


def get_list(kwargs: dict[str, str | list[str]], key: str) -> list[str]:
    """Get a list value from parsed passthrough args."""
    value = kwargs.get(key, [])
    if isinstance(value, str):
        return [value]
    return value
