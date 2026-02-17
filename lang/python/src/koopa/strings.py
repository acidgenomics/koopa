"""String manipulation functions.

Converted from POSIX shell functions: str-detect-fixed, str-detect-regex,
sub, gsub, trim-ws, to-string, paste, lowercase, uppercase, etc.
"""

from __future__ import annotations

import re


def str_detect_fixed(string: str, pattern: str) -> bool:
    """Detect fixed pattern in string."""
    return pattern in string


def str_detect_regex(string: str, pattern: str) -> bool:
    """Detect regex pattern in string."""
    return bool(re.search(pattern, string))


def sub(pattern: str, replacement: str, string: str, *, fixed: bool = False) -> str:
    """Replace first occurrence of pattern."""
    if fixed:
        return string.replace(pattern, replacement, 1)
    return re.sub(pattern, replacement, string, count=1)


def gsub(pattern: str, replacement: str, string: str, *, fixed: bool = False) -> str:
    """Replace all occurrences of pattern."""
    if fixed:
        return string.replace(pattern, replacement)
    return re.sub(pattern, replacement, string)


def trim_ws(string: str) -> str:
    """Trim leading and trailing whitespace."""
    return string.strip()


def to_string(items: list[str], sep: str = ", ") -> str:
    """Join list items into a string."""
    return sep.join(items)


def paste(*args: str, sep: str = " ") -> str:
    """Concatenate strings with separator."""
    return sep.join(args)


def paste0(*args: str) -> str:
    """Concatenate strings without separator."""
    return "".join(args)


def lowercase(string: str) -> str:
    """Convert to lowercase."""
    return string.lower()


def uppercase(string: str) -> str:
    """Convert to uppercase."""
    return string.upper()


def capitalize(string: str) -> str:
    """Capitalize first letter."""
    return string.capitalize()


def append_string(string: str, suffix: str) -> str:
    """Append suffix to string."""
    return string + suffix


def ngettext(n: int, singular: str, plural: str) -> str:
    """Return singular or plural form based on count."""
    if n == 1:
        return f"{n} {singular}"
    return f"{n} {plural}"
