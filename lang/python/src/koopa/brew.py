"""Homebrew management functions.

Converted from Bash functions: brew-prefix, brew-version, brew-doctor,
brew-outdated, brew-upgrade-brews, brew-dump-brewfile, brew-reset-core-repo,
brew-reset-permissions, brew-uninstall-all-brews, brew-install-brewfile,
brew-list-formulae, brew-list-casks, brew-info, etc.
"""

from __future__ import annotations

import os
import subprocess


def _brew(*args: str, capture: bool = True) -> subprocess.CompletedProcess:
    """Run a brew command."""
    cmd = ["brew", *args]
    return subprocess.run(cmd, capture_output=capture, text=True, check=True)


def brew_prefix() -> str:
    """Get Homebrew prefix."""
    result = _brew("--prefix")
    return result.stdout.strip()


def brew_version() -> str:
    """Get Homebrew version."""
    result = _brew("--version")
    return result.stdout.strip().splitlines()[0]


def brew_doctor() -> str:
    """Run brew doctor."""
    result = subprocess.run(
        ["brew", "doctor"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def brew_outdated() -> list[str]:
    """List outdated formulae."""
    result = _brew("outdated")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_upgrade_brews() -> None:
    """Upgrade all Homebrew formulae."""
    _brew("update", capture=False)
    _brew("upgrade", capture=False)
    _brew("cleanup", capture=False)


def brew_dump_brewfile(path: str = "Brewfile") -> None:
    """Dump installed formulae to a Brewfile."""
    _brew("bundle", "dump", "--file", path, "--force", capture=False)


def brew_reset_core_repo() -> None:
    """Reset Homebrew core repository."""
    prefix = brew_prefix()
    core = os.path.join(prefix, "Library", "Taps", "homebrew", "homebrew-core")
    if os.path.isdir(core):
        subprocess.run(
            ["git", "-C", core, "fetch", "--unshallow"],
            capture_output=True,
            check=True,
        )
        subprocess.run(
            ["git", "-C", core, "checkout", "master"],
            capture_output=True,
            check=True,
        )


def brew_reset_permissions() -> None:
    """Reset Homebrew directory permissions."""
    prefix = brew_prefix()
    user = os.environ.get("USER", "")
    if user:
        subprocess.run(
            ["sudo", "chown", "-R", f"{user}:admin", prefix],
            check=True,
        )


def brew_uninstall_all_brews() -> None:
    """Uninstall all Homebrew formulae."""
    result = _brew("list", "--formula", "-1")
    formulae = [x for x in result.stdout.strip().splitlines() if x]
    if formulae:
        _brew("uninstall", "--force", *formulae, capture=False)


def brew_install_brewfile(path: str = "Brewfile") -> None:
    """Install from a Brewfile."""
    _brew("bundle", "install", "--file", path, capture=False)


def brew_list_formulae() -> list[str]:
    """List installed formulae."""
    result = _brew("list", "--formula", "-1")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_list_casks() -> list[str]:
    """List installed casks."""
    result = _brew("list", "--cask", "-1")
    return [x for x in result.stdout.strip().splitlines() if x]


def brew_info(formula: str) -> str:
    """Get info about a formula."""
    result = _brew("info", formula)
    return result.stdout.strip()
