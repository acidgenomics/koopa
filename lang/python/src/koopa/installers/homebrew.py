"""Install Homebrew."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.system import is_macos


def _update_homebrew() -> None:
    """Update Homebrew and upgrade all formulae and casks."""
    brew = shutil.which("brew")
    if brew is None:
        msg = "Homebrew is not installed."
        raise FileNotFoundError(msg)
    prefix = subprocess.run(
        [brew, "--prefix"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    from koopa.alert import alert, alert_update_start, alert_update_success
    from koopa.brew import brew_reset_permissions

    alert_update_start(f"Homebrew at '{prefix}'")
    brew_reset_permissions()
    alert("Updating Homebrew.")
    os.environ["PATH"] = os.path.join(prefix, "bin") + ":" + os.environ.get("PATH", "")
    subprocess.run([brew, "analytics", "off"], check=True)
    subprocess.run([brew, "update"], check=True)
    if is_macos():
        _upgrade_casks(brew)
    _upgrade_brews(brew)
    alert("Cleaning up.")
    _untap_deprecated(brew)
    subprocess.run([brew, "cleanup", "-s"], check=True)
    cache_dir = subprocess.run(
        [brew, "--cache"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    if cache_dir and os.path.isdir(cache_dir):
        shutil.rmtree(cache_dir, ignore_errors=True)
    subprocess.run([brew, "autoremove"], check=True)
    _brew_doctor(brew)
    alert_update_success(f"Homebrew at '{prefix}'")


def _upgrade_brews(brew: str) -> None:
    """Upgrade outdated Homebrew formulae."""
    from koopa.alert import alert

    alert("Checking brews.")
    result = subprocess.run(
        [brew, "outdated", "--formula"],
        capture_output=True,
        text=True,
        check=True,
    )
    brews = [x for x in result.stdout.strip().splitlines() if x]
    if not brews:
        return
    print(f"{len(brews)} outdated brew(s): {', '.join(brews)}", file=sys.stderr)
    subprocess.run([brew, "reinstall", "--force", *brews], check=True)


def _upgrade_casks(brew: str) -> None:
    """Upgrade outdated Homebrew casks on macOS."""
    from koopa.alert import alert

    alert("Checking casks.")
    result = subprocess.run(
        [brew, "outdated", "--cask", "--greedy"],
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
        [brew, "reinstall", "--cask", "--force", *casks],
        check=True,
    )
    for cask in casks:
        if cask == "r":
            _configure_r_after_cask_upgrade()
        elif cask.startswith("gpg-suite"):
            _disable_gpg_updater()


def _configure_r_after_cask_upgrade() -> None:
    """Run R configuration after cask upgrade."""
    try:
        from koopa.r import configure_r_environ, configure_r_makevars

        configure_r_environ()
        configure_r_makevars()
    except Exception:
        pass


def _disable_gpg_updater() -> None:
    """Disable GPG Suite updater on macOS."""
    plist = os.path.expanduser(
        "~/Library/LaunchAgents/org.gpgtools.updater.plist",
    )
    if os.path.isfile(plist):
        subprocess.run(
            ["launchctl", "unload", "-w", plist],
            check=False,
        )


def _untap_deprecated(brew: str) -> None:
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
            [brew, "--repo", tap],
            capture_output=True,
            text=True,
            check=False,
        )
        tap_prefix = result.stdout.strip()
        if tap_prefix and os.path.isdir(tap_prefix):
            from koopa.alert import alert

            alert(f"Untapping '{tap}'.")
            subprocess.run([brew, "untap", tap], check=False)


def _brew_doctor(brew: str) -> None:
    """Run a subset of brew doctor checks."""
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
        [brew, "doctor", "--list-checks"],
        capture_output=True,
        text=True,
        check=False,
    )
    all_checks = [x for x in result.stdout.strip().splitlines() if x]
    enabled_checks = [c for c in all_checks if c not in disabled_checks]
    if not enabled_checks:
        return
    subprocess.run([brew, "config"], check=False)
    subprocess.run([brew, "doctor", *enabled_checks], check=False)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Homebrew."""
    brew = shutil.which("brew")
    if brew is not None:
        _update_homebrew()
        return
    if is_macos():
        clt_dir = "/Library/Developer/CommandLineTools"
        if not os.path.isdir(clt_dir):
            msg = "Xcode Command Line Tools required. Run 'koopa install xcode-clt'."
            raise RuntimeError(msg)
    url = "https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
    script = download(url)
    os.chmod(script, 0o755)
    print("Installing Homebrew.", file=sys.stderr)
    env = os.environ.copy()
    env["NONINTERACTIVE"] = "1"
    subprocess.run(["bash", script], env=env, check=True)
