"""Install Doom Emacs."""

import os
import stat

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
    wrapper = os.path.join(prefix, "bin", "doom-emacs")
    with open(wrapper, "w") as f:
        f.write('#!/bin/sh\nexec emacs --init-directory="$(dirname "$0")/.." "$@"\n')
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
