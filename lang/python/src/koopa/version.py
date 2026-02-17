"""Version handling functions.

Converted from POSIX shell functions: koopa-version, extract-version,
sanitize-version, major-version, etc.
"""

from __future__ import annotations

import re
from pathlib import Path

from koopa.prefix import koopa_prefix


def koopa_version() -> str:
    """Return koopa version from VERSION file."""
    version_file = Path(koopa_prefix()) / "VERSION"
    if version_file.is_file():
        return version_file.read_text().strip()
    return "unknown"


def version_pattern() -> str:
    """Return a regex pattern for matching version strings."""
    return r"(\d+\.\d+(?:\.\d+)*(?:[-+]\S*)?)"


def extract_version(string: str) -> str:
    """Extract version string from text.

    Parameters
    ----------
    string : str
        String containing a version number.

    Returns
    -------
    str
        Extracted version or empty string.
    """
    match = re.search(version_pattern(), string)
    return match.group(1) if match else ""


def major_version(version: str) -> str:
    """Extract major version number."""
    parts = version.split(".")
    return parts[0] if parts else version


def major_minor_version(version: str) -> str:
    """Extract major.minor version."""
    parts = version.split(".")
    return ".".join(parts[:2]) if len(parts) >= 2 else version


def major_minor_patch_version(version: str) -> str:
    """Extract major.minor.patch version."""
    parts = version.split(".")
    return ".".join(parts[:3]) if len(parts) >= 3 else version


def sanitize_version(version: str) -> str:
    """Sanitize a version string to numeric format.

    Strips leading 'v', trailing non-numeric suffixes, etc.

    Parameters
    ----------
    version : str
        Version string to sanitize.

    Returns
    -------
    str
        Sanitized version.
    """
    v = version.strip()
    if v.startswith("v") or v.startswith("V"):
        v = v[1:]
    match = re.match(r"(\d+(?:\.\d+)*)", v)
    return match.group(1) if match else v
