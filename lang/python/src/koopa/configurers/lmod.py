"""Configure lmod."""

from __future__ import annotations

import os

from koopa.file_ops import ln, mkdir
from koopa.prefix import app_prefix


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Link lmod configuration files in '/etc/profile.d/'.

    Creates symlinks:
      {prefix}/apps/lmod/lmod/init/profile -> /etc/profile.d/z00_lmod.sh
      {prefix}/apps/lmod/lmod/init/cshrc -> /etc/profile.d/z00_lmod.csh
      {prefix}/apps/lmod/lmod/init/profile.fish -> /etc/fish/conf.d/z00_lmod.fish

    Uses sudo for /etc/ paths. Creates dirs if missing.
    """
    prefix = app_prefix("lmod")
    if not os.path.isdir(prefix):
        msg = f"lmod prefix not found: {prefix}"
        raise FileNotFoundError(msg)
    init_dir = os.path.join(prefix, "apps", "lmod", "lmod", "init")
    if not os.path.isdir(init_dir):
        msg = f"lmod init directory not found: {init_dir}"
        raise FileNotFoundError(msg)
    etc_dir = "/etc/profile.d"
    if not os.path.isdir(etc_dir):
        mkdir(etc_dir, sudo=True)
    # bash, zsh.
    ln(
        os.path.join(init_dir, "profile"),
        os.path.join(etc_dir, "z00_lmod.sh"),
        sudo=True,
    )
    # csh, tcsh.
    ln(
        os.path.join(init_dir, "cshrc"),
        os.path.join(etc_dir, "z00_lmod.csh"),
        sudo=True,
    )
    # fish.
    fish_etc_dir = "/etc/fish/conf.d"
    if not os.path.isdir(fish_etc_dir):
        mkdir(fish_etc_dir, sudo=True)
    ln(
        os.path.join(init_dir, "profile.fish"),
        os.path.join(fish_etc_dir, "z00_lmod.fish"),
        sudo=True,
    )
