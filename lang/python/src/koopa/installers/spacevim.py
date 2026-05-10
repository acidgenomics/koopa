"""Install SpaceVim."""

import os
import stat
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
    """Install SpaceVim."""
    env = activate_app_deps()
    if env is not None:
        env.apply()
    git_clone(
        "https://gitlab.com/SpaceVim/SpaceVim.git",
        prefix,
        commit=version,
    )
    vimproc_prefix = os.path.join(prefix, "bundle", "vimproc.vim")
    if os.path.isdir(vimproc_prefix):
        print(f"Fixing vimproc at '{vimproc_prefix}'.", file=sys.stderr)
        subprocess.run(["make"], cwd=vimproc_prefix, check=True)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    wrapper = os.path.join(bin_dir, "spacevim")
    with open(wrapper, "w") as f:
        f.write('#!/bin/sh\nexec vim -u "$(dirname "$0")/../vimrc" "$@"\n')
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
