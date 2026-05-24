"""Install Homebrew."""

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.system import is_macos


def _update_homebrew() -> None:
    """Update Homebrew and upgrade all formulae and casks."""
    from koopa.alert import alert, alert_update_start, alert_update_success
    from koopa.brew import (
        brew_doctor_filtered,
        brew_prefix,
        brew_reset_permissions,
        brew_untap_deprecated,
        brew_upgrade_brews,
        brew_upgrade_casks,
    )

    prefix = brew_prefix()
    alert_update_start(f"Homebrew at '{prefix}'")
    brew_reset_permissions()
    alert("Updating Homebrew.")
    os.environ["PATH"] = os.path.join(prefix, "bin") + ":" + os.environ.get("PATH", "")
    subprocess.run(["brew", "analytics", "off"], check=True)
    subprocess.run(["brew", "update"], check=True)
    if is_macos():
        alert("Checking casks.")
        brew_upgrade_casks()
    alert("Checking brews.")
    brew_upgrade_brews()
    alert("Cleaning up.")
    brew_untap_deprecated()
    subprocess.run(["brew", "cleanup", "-s"], check=True)
    cache_dir = subprocess.run(
        ["brew", "--cache"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout.strip()
    if cache_dir and os.path.isdir(cache_dir):
        shutil.rmtree(cache_dir, ignore_errors=True)
    subprocess.run(["brew", "autoremove"], check=True)
    brew_doctor_filtered()
    alert_update_success(f"Homebrew at '{prefix}'")


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
