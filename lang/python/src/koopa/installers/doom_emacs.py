"""Install Doom Emacs."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app
from koopa.git import git_clone
from koopa.system import is_linux, is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Doom Emacs."""
    git_clone(
        "https://github.com/hlissner/doom-emacs.git",
        prefix,
        branch=version,
    )
    doom = os.path.join(prefix, "bin", "doom")
    if not os.path.isfile(doom):
        msg = f"doom executable not found: {doom}"
        raise FileNotFoundError(msg)
    if is_linux():
        activate_app("emacs", build_only=True)
    elif is_macos():
        brew_prefix = "/opt/homebrew" if os.path.isdir("/opt/homebrew") else "/usr/local"
        os.environ["PATH"] = os.path.join(brew_prefix, "bin") + ":" + os.environ.get("PATH", "")
    print("Running doom install.", file=sys.stderr)
    subprocess.run(
        [doom, "install", "--debug", "--force", "--no-env", "--no-fonts", "--verbose"],
        check=True,
    )
    subprocess.run([doom, "sync"], check=True)
