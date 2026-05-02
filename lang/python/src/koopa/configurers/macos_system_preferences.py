"""Configure macOS system preferences."""

from __future__ import annotations

import subprocess
import sys


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure macOS system preferences.

    Configures startup, locale, power management, Finder, Spotlight, and
    Time Machine settings using system-level commands with sudo.
    """
    if sys.platform != "darwin":
        msg = "macOS only."
        raise RuntimeError(msg)
    defaults = "/usr/bin/defaults"
    nvram = "/usr/sbin/nvram"
    pmset = "/usr/bin/pmset"
    chflags = "/usr/bin/chflags"
    mdutil = "/usr/bin/mdutil"
    tmutil = "/usr/bin/tmutil"

    def _sudo(*args: str) -> None:
        subprocess.run(["sudo", *args], check=True)

    # Startup and Lock Screen.
    # Disable startup chime on boot.
    _sudo(nvram, "SystemAudioVolume= ")
    # Locale.
    # Enable language input in menu bar.
    _sudo(
        defaults,
        "write",
        "/Library/Preferences/com.apple.loginwindow",
        "showInputMenu",
        "-bool",
        "true",
    )
    # Power management.
    # Sleep the display after 15 minutes when connected to power.
    _sudo(pmset, "-c", "displaysleep", "15")
    # Check current settings.
    subprocess.run([pmset, "-g"], check=True)
    # Finder.
    # Enable visibility of '/Volumes' in Finder.
    _sudo(chflags, "nohidden", "/Volumes")
    # Spotlight.
    # Enable Spotlight indexing for main volume.
    _sudo(mdutil, "-i", "on", "/")
    subprocess.run([mdutil, "-s", "/"], check=True)
    # Time Machine.
    # Disable Time Machine backups.
    _sudo(tmutil, "disable")
    subprocess.run([tmutil, "listlocalsnapshotdates", "/"], check=True)
    print(
        "Some of these changes may require restart to take effect.",
        file=sys.stderr,
    )
