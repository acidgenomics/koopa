"""Version handling functions.

Converted from POSIX shell functions: koopa-version, extract-version,
sanitize-version, major-version, etc.
"""

import re
from pathlib import Path

from koopa.prefix import koopa_prefix

# Shared with koopa.version_check._PRERELEASE_RE so both modules agree on what
# counts as a pre-release marker.
PRERELEASE_MARKERS = "alpha|beta|preview|pre|rc|dev|snapshot|nightly|canary"

_SANITIZE_VERSION_RE = re.compile(
    rf"(\d+(?:\.\d+)*(?:[._-]?(?:{PRERELEASE_MARKERS})[0-9.]*|[a-zA-Z])?)",
    re.IGNORECASE,
)


def koopa_version() -> str:
    """Return koopa version.

    Prefers installed package metadata (the case for a pip/conda install,
    where no 'pyproject.toml' ships alongside the package). Falls back to
    reading 'pyproject.toml' directly for a git checkout, where the installed
    package metadata may be stale relative to the working tree.
    """
    import tomllib
    from importlib.metadata import PackageNotFoundError, version

    pyproject = Path(koopa_prefix()) / "pyproject.toml"
    if pyproject.is_file():
        with open(pyproject, "rb") as fh:
            data = tomllib.load(fh)
        return data.get("project", {}).get("version", "unknown")
    try:
        return version("koopa")
    except PackageNotFoundError:
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

    Strips leading 'v', trailing non-numeric suffixes, etc. Preserves an
    explicit pre-release marker (e.g. 'beta2' in '3.15.0beta2') so that
    downstream pre-release detection still works after sanitization. A bare
    trailing letter with no marker word (e.g. '1.1.1w') is preserved as-is.

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
    match = _SANITIZE_VERSION_RE.match(v)
    return match.group(1) if match else v
