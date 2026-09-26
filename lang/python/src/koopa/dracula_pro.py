"""Dracula Pro theme bundle: install a purchased zip and check for updates.

Dracula Pro is a paid theme bundle sold only through the buyer's own Gumroad
library, so koopa cannot download it directly. This module installs a zip
the user already downloaded from there, records its version, and checks the
public changelog feed for a newer release.
"""

import os
import re
import shutil
from datetime import UTC, datetime
from xml.etree import ElementTree

from koopa.alert import alert_info, alert_success, warn
from koopa.archive import extract
from koopa.xdg import xdg_data_home

CHANGELOG_RSS_URL = "https://draculatheme.com/changelog-rss.xml"

# Dracula Pro 2.2.3 renamed its bundle files to lowercase-hyphen names (e.g.
# "dracula-pro-alucard.tmTheme"). koopa's theme generators read only that
# layout, so an older bundle's files are not found -- not read wrong, just
# silently skipped. This floor lets `koopa system check` catch that instead.
MIN_SUPPORTED_VERSION = "2.2.3"

_VERSION_MARKER_NAME = ".koopa-version"
_ZIP_VERSION_RE = re.compile(r"dracula-pro-v(\d+\.\d+(?:\.\d+)?)", re.IGNORECASE)
_VERSION_MENTION_RE = re.compile(
    r"\bpackage\s+v\.?(\d+\.\d+(?:\.\d+)?)\b|\bversion\s+(\d+\.\d+(?:\.\d+)?)\b",
    re.IGNORECASE,
)


def dracula_pro_dir() -> str:
    """Return the install directory for the Dracula Pro bundle.

    Returns
    -------
    str
        Path to ``<XDG_DATA_HOME>/dracula-pro``.
    """
    return os.path.join(xdg_data_home(), "dracula-pro")


def installed_version() -> str | None:
    """Return the installed Dracula Pro version, if known.

    Returns
    -------
    str | None
        The version recorded at install time, or None if Dracula Pro is not
        installed, or was installed without going through `install` (e.g. a
        pre-existing manual unzip), so no marker file exists.
    """
    marker = os.path.join(dracula_pro_dir(), _VERSION_MARKER_NAME)
    try:
        with open(marker) as fh:
            version = fh.read().strip()
    except FileNotFoundError:
        return None
    return version or None


def _version_tuple(version: str) -> tuple[int, ...]:
    """Parse a dotted version string into a tuple of integers for comparison.

    Parameters
    ----------
    version : str
        Dot-separated version string, e.g. ``"2.2.3"``.

    Returns
    -------
    tuple[int, ...]
        The dot-separated components of `version`, parsed as integers.
    """
    return tuple(int(part) for part in version.split("."))


def is_outdated_layout() -> bool:
    """Check whether the installed Dracula Pro bundle predates the supported layout.

    Returns
    -------
    bool
        True if an installed version is on record and it precedes
        `MIN_SUPPORTED_VERSION`. False if nothing is installed, or the
        installed version already meets the minimum.
    """
    current = installed_version()
    if current is None:
        return False
    return _version_tuple(current) < _version_tuple(MIN_SUPPORTED_VERSION)


def version_from_zip_filename(path: str) -> str | None:
    """Parse a Dracula Pro version out of a downloaded zip's filename.

    Parameters
    ----------
    path : str
        Path to a ``dracula-pro-vX.Y.Z.zip`` download.

    Returns
    -------
    str | None
        The version string (e.g. ``"2.2.3"``), or None if the filename does
        not match the expected pattern.
    """
    match = _ZIP_VERSION_RE.search(os.path.basename(path))
    return match.group(1) if match else None


def install(zip_path: str, *, configure: bool = True) -> str | None:
    """Install a purchased Dracula Pro zip, replacing any existing copy.

    The existing install directory, if any, is renamed to a timestamped
    backup rather than merged into, so a release that drops a file leaves
    nothing stale behind.

    Parameters
    ----------
    zip_path : str
        Path to a Dracula Pro zip downloaded from the buyer's Gumroad
        library.
    configure : bool, optional
        Re-run ``koopa configure user dotfiles`` after installing, so every
        theme file koopa generates from the bundle picks up the change.

    Returns
    -------
    str | None
        The installed version, if it could be parsed from the filename.

    Raises
    ------
    FileNotFoundError
        If `zip_path` does not exist.
    """
    if not os.path.isfile(zip_path):
        msg = f"Zip file not found: {zip_path}"
        raise FileNotFoundError(msg)
    version = version_from_zip_filename(zip_path)
    dest = dracula_pro_dir()
    if os.path.isdir(dest):
        backup = f"{dest}.bak-{datetime.now(UTC):%Y%m%dT%H%M%SZ}"
        alert_info(f"Backing up existing install to '{backup}'.")
        shutil.move(dest, backup)
    alert_info(f"Extracting '{zip_path}' to '{dest}'.")
    extract(zip_path, dest)
    macosx_dir = os.path.join(dest, "__MACOSX")
    if os.path.isdir(macosx_dir):
        shutil.rmtree(macosx_dir)
    if version:
        with open(os.path.join(dest, _VERSION_MARKER_NAME), "w") as fh:
            fh.write(version + "\n")
    else:
        warn(
            f"Could not parse a version from '{os.path.basename(zip_path)}'; "
            "no version marker written. 'koopa app dracula-pro check' will "
            "not be able to compare it against the latest release."
        )
    if configure:
        alert_info("Running 'koopa configure user dotfiles' to apply the new theme files.")
        from koopa.configure import ConfigureConfig, configure_app

        configure_app(ConfigureConfig(name="dotfiles", mode="user"))
    alert_success(f"Installed Dracula Pro {version}." if version else "Installed Dracula Pro.")
    return version


def _mentioned_version(text: str) -> str | None:
    """Return the first version number mentioned in free-form text.

    Parameters
    ----------
    text : str
        Free-form text, e.g. an RSS item's title and description.

    Returns
    -------
    str | None
        The first ``package vX.Y[.Z]`` or ``version X.Y[.Z]`` match, or None.
        A bare ``vX.Y[.Z]`` with no leading ``package`` does not count -- the
        vendor also uses that form for a single app's own version (e.g.
        "Visual Studio Code v2.2.2"), not the package version.
    """
    match = _VERSION_MENTION_RE.search(text)
    if not match:
        return None
    return match.group(1) or match.group(2)


def latest_version() -> str:
    """Return the latest published Dracula Pro version.

    Reads the public changelog feed and returns the version named in the
    newest entry that mentions one -- not every changelog entry bumps the
    package version (e.g. a single-theme fix ships inside the current one).

    Returns
    -------
    str
        The latest version string (e.g. ``"2.2.3"``).

    Raises
    ------
    ValueError
        If no entry in the feed mentions a version number.
    """
    from koopa.version_check import _http_get_text

    text = _http_get_text(CHANGELOG_RSS_URL)
    root = ElementTree.fromstring(text)
    for item in root.iter("item"):
        title = item.findtext("title") or ""
        description = item.findtext("description") or ""
        version = _mentioned_version(f"{title} {description}")
        if version:
            return version
    msg = "No version number found in the Dracula Pro changelog feed."
    raise ValueError(msg)


def check() -> None:
    """Compare the installed Dracula Pro version against the changelog feed.

    Prints an up-to-date confirmation, a warning naming the newer release,
    or a warning that no version is on record, to alert output.
    """
    current = installed_version()
    latest = latest_version()
    if current is None:
        warn(
            f"No installed Dracula Pro version on record at '{dracula_pro_dir()}'. "
            f"Latest available: {latest}."
        )
        return
    if current == latest:
        alert_success(f"Dracula Pro {current} is up to date.")
        return
    warn(
        f"Dracula Pro {current} is installed; {latest} is available. Download "
        "it from your Gumroad library, then run "
        "'koopa app dracula-pro install --zip <path>'."
    )
