"""Install Doom Emacs."""

import os
import stat

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps

_DOOM_WRAPPER = """\
#!/bin/sh
set -eu
_self="$0"
if [ -L "$_self" ]; then
    _self="$(readlink "$_self")"
fi
prefix="$(cd "$(dirname "$_self")/.." && pwd)"
export EMACSDIR="${prefix}/libexec"
export DOOMLOCALDIR="${XDG_DATA_HOME:-${HOME}/.local/share}/doom"
exec "${prefix}/libexec/bin/doom" "$@"
"""


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
    libexec = os.path.join(prefix, "libexec")
    git_clone(
        "https://github.com/hlissner/doom-emacs.git",
        libexec,
        commit=version,
    )
    doom_cli = os.path.join(libexec, "bin", "doom")
    if not os.path.isfile(doom_cli):
        msg = f"doom executable not found: {doom_cli}"
        raise FileNotFoundError(msg)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    path = os.path.join(bin_dir, "doom")
    with open(path, "w") as f:
        f.write(_DOOM_WRAPPER)
    os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
