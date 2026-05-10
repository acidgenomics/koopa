"""Install Spacemacs."""

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
    """Install Spacemacs."""
    env = activate_app_deps()
    env.apply()
    git_clone(
        "https://github.com/syl20bnr/spacemacs.git",
        prefix,
        commit=version,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    wrapper = os.path.join(bin_dir, "spacemacs")
    with open(wrapper, "w") as f:
        f.write('#!/bin/sh\nexec emacs --init-directory="$(dirname "$0")/.." "$@"\n')
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
