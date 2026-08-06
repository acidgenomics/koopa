"""Install Homebrew."""

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.system import is_macos


def _update_homebrew() -> None:
    """Update Homebrew and upgrade all formulae and casks."""
    from koopa.alert import alert_update_start, alert_update_success
    from koopa.brew import (
        _brew,
        brew_doctor_filtered,
        brew_prefix,
        brew_reset_permissions,
        brew_untap_deprecated,
        brew_upgrade_brews,
        brew_upgrade_casks,
    )
    from koopa.progress import set_status

    prefix = brew_prefix()
    alert_update_start(f"Homebrew at '{prefix}'")
    brew_reset_permissions()
    set_status("updating brew")
    os.environ["PATH"] = os.path.join(prefix, "bin") + ":" + os.environ.get("PATH", "")
    _brew("analytics", "off", capture=False)
    _brew("update", capture=False)
    if is_macos():
        set_status("checking casks")
        brew_upgrade_casks()
    set_status("checking brews")
    brew_upgrade_brews()
    set_status("cleaning up")
    brew_untap_deprecated()
    _brew("cleanup", "-s", capture=False)
    cache_dir = _brew("--cache").stdout.strip()
    if cache_dir and os.path.isdir(cache_dir):
        shutil.rmtree(cache_dir, ignore_errors=True)
    _brew("autoremove", capture=False)
    set_status("running doctor")
    brew_doctor_filtered()
    set_status("")
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
