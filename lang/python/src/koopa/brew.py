"""Homebrew management functions.

Converted from Bash functions: brew-prefix, brew-version, brew-doctor,
brew-outdated, brew-upgrade-brews, brew-dump-brewfile, brew-reset-core-repo,
brew-reset-permissions, brew-uninstall-all-brews, brew-install-brewfile,
brew-list-formulae, brew-list-casks, brew-info, etc.
"""

import os
import subprocess
import sys


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


def brew_upgrade() -> None:
    """Upgrade all Homebrew formulae and casks."""
    from koopa.system import is_macos

    _brew("update", capture=False)
    if is_macos():
        brew_upgrade_casks()
    brew_upgrade_brews()
    _brew("cleanup", capture=False)


def brew_upgrade_casks() -> None:
    """Upgrade outdated casks detected via --greedy on macOS."""
    result = subprocess.run(
        ["brew", "outdated", "--cask", "--greedy"],
        capture_output=True,
        text=True,
        check=False,
    )
    casks = []
    for line in result.stdout.strip().splitlines():
        if not line or "(latest)" in line:
            continue
        casks.append(line.split()[0])
    if not casks:
        return
    print(f"{len(casks)} outdated cask(s): {', '.join(casks)}", file=sys.stderr)
    subprocess.run(
        ["brew", "reinstall", "--cask", "--force", *casks],
        check=True,
    )
    for cask in casks:
        if cask == "r":
            try:
                from koopa.r import configure_r_environ, configure_r_makevars

                configure_r_environ()
                configure_r_makevars()
            except Exception:
                pass
        elif cask.startswith("gpg-suite"):
            plist = os.path.expanduser(
                "~/Library/LaunchAgents/org.gpgtools.updater.plist",
            )
            if os.path.isfile(plist):
                subprocess.run(["launchctl", "unload", "-w", plist], check=False)


def brew_upgrade_brews() -> None:
    """Upgrade outdated Homebrew formulae."""
    result = subprocess.run(
        ["brew", "outdated", "--formula"],
        capture_output=True,
        text=True,
        check=True,
    )
    brews = [x for x in result.stdout.strip().splitlines() if x]
    if not brews:
        return
    print(f"{len(brews)} outdated brew(s): {', '.join(brews)}", file=sys.stderr)
    subprocess.run(["brew", "reinstall", "--force", *brews], check=True)


def brew_untap_deprecated() -> None:
    """Remove deprecated Homebrew taps."""
    deprecated_taps = [
        "homebrew/bundle",
        "homebrew/cask",
        "homebrew/cask-drivers",
        "homebrew/cask-fonts",
        "homebrew/cask-versions",
        "homebrew/core",
    ]
    for tap in deprecated_taps:
        result = subprocess.run(
            ["brew", "--repo", tap],
            capture_output=True,
            text=True,
            check=False,
        )
        tap_prefix = result.stdout.strip()
        if tap_prefix and os.path.isdir(tap_prefix):
            subprocess.run(["brew", "untap", tap], check=False)


def brew_doctor_filtered() -> None:
    """Run brew doctor with stray-lib and path checks disabled."""
    disabled_checks = {
        "check_for_stray_dylibs",
        "check_for_stray_headers",
        "check_for_stray_las",
        "check_for_stray_pcs",
        "check_for_stray_static_libs",
        "check_user_path_1",
        "check_user_path_2",
        "check_user_path_3",
    }
    result = subprocess.run(
        ["brew", "doctor", "--list-checks"],
        capture_output=True,
        text=True,
        check=False,
    )
    all_checks = [x for x in result.stdout.strip().splitlines() if x]
    enabled_checks = [c for c in all_checks if c not in disabled_checks]
    if not enabled_checks:
        return
    subprocess.run(["brew", "config"], check=False)
    subprocess.run(["brew", "doctor", *enabled_checks], check=False)


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
