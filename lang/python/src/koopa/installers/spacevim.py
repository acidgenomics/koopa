"""Install SpaceVim."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.file_ops import ln
from koopa.git import git_clone
from koopa.system import is_macos


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install SpaceVim."""
    xdg_data_home = os.environ.get(
        "XDG_DATA_HOME",
        os.path.join(os.path.expanduser("~"), ".local", "share"),
    )
    if is_macos():
        fonts_link = os.path.join(xdg_data_home, "fonts")
        if not os.path.exists(fonts_link):
            ln(
                os.path.join(os.path.expanduser("~"), "Library", "Fonts"),
                fonts_link,
            )
    git_clone(
        "https://gitlab.com/SpaceVim/SpaceVim.git",
        prefix,
        commit=version,
    )
    vimproc_prefix = os.path.join(prefix, "bundle", "vimproc.vim")
    if os.path.isdir(vimproc_prefix):
        print(f"Fixing vimproc at '{vimproc_prefix}'.", file=sys.stderr)
        subprocess.run(["make"], cwd=vimproc_prefix, check=True)
