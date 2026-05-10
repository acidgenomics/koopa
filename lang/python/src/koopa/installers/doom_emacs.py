"""Install Doom Emacs."""

import os
import subprocess
import sys

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Doom Emacs."""
    env = activate_app_deps()
    if env is not None:
        env.apply()
    git_clone(
        "https://github.com/hlissner/doom-emacs.git",
        prefix,
        commit=version,
    )
    doom = os.path.join(prefix, "bin", "doom")
    if not os.path.isfile(doom):
        msg = f"doom executable not found: {doom}"
        raise FileNotFoundError(msg)
    print("Running doom install.", file=sys.stderr)
    subprocess.run(
        [doom, "install", "--debug", "--force", "--no-env", "--no-fonts", "--verbose"],
        check=True,
    )
    subprocess.run([doom, "sync"], check=True)
