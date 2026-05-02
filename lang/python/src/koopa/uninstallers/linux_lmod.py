"""Uninstall Lmod configuration."""

from __future__ import annotations

import os

from koopa.file_ops import rm


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    prefix: str = "",
    verbose: bool = False,
) -> None:
    """Uninstall Lmod configuration."""
    lmod_sh = "/etc/profile.d/z00_lmod.sh"
    if not os.path.exists(lmod_sh):
        return
    for path in (
        "/etc/profile.d/z00_lmod.csh",
        "/etc/profile.d/z00_lmod.sh",
    ):
        if os.path.exists(path):
            rm(path, sudo=True)
