"""Parse passthrough CLI args into keyword arguments."""


def parse_passthrough(
    args: list[str] | None,
) -> dict[str, str | list[str]]:
    """Parse ``--key=value`` passthrough args into a dict.

    Handles repeated keys by collecting values into a list.

    Parameters
    ----------
    args : list[str] | None
        Passthrough arguments, e.g. ``["--extra-packages=foo"]``.

    Returns
    -------
    dict[str, str | list[str]]
        Parsed keys mapped to their string or list value.
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
    """Get a string value from parsed passthrough args.

    Parameters
    ----------
    kwargs : dict[str, str | list[str]]
        Parsed passthrough args from :func:`parse_passthrough`.
    key : str
        Key to look up.
    default : str, optional
        Value to return if ``key`` is absent.

    Returns
    -------
    str
        The value for ``key``, or ``default`` if absent.
    """
    value = kwargs.get(key, default)
    if isinstance(value, list):
        return value[0]
    return value


def get_list(kwargs: dict[str, str | list[str]], key: str) -> list[str]:
    """Get a list value from parsed passthrough args.

    Parameters
    ----------
    kwargs : dict[str, str | list[str]]
        Parsed passthrough args from :func:`parse_passthrough`.
    key : str
        Key to look up.

    Returns
    -------
    list[str]
        The value for ``key``, or an empty list if absent.
    """
    value = kwargs.get(key, [])
    if isinstance(value, str):
        return [value]
    return value


def get_dict(kwargs: dict[str, str | list[str]], key: str) -> dict[str, str]:
    """Get a dict value from parsed passthrough args (JSON-encoded).

    Parameters
    ----------
    kwargs : dict[str, str | list[str]]
        Parsed passthrough args from :func:`parse_passthrough`.
    key : str
        Key to look up.

    Returns
    -------
    dict[str, str]
        The decoded value for ``key``, or an empty dict if absent.
    """
    import json

    value = kwargs.get(key, "")
    if not value:
        return {}
    if isinstance(value, list):
        value = value[0]
    return json.loads(value)
