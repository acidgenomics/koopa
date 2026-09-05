"""Install Doom Emacs."""

import os
import stat

from koopa.git import git_clone, git_submodule_init
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

_DOOM_EMACS_WRAPPER = """\
#!/bin/sh
set -eu
_self="$0"
if [ -L "$_self" ]; then
    _self="$(readlink "$_self")"
fi
prefix="$(cd "$(dirname "$_self")/.." && pwd)"
export EMACSDIR="${prefix}/libexec"
export DOOMLOCALDIR="${XDG_DATA_HOME:-${HOME}/.local/share}/doom"
if [ ! -d "${DOOMLOCALDIR}/straight" ]; then
    printf 'First run: configuring Doom Emacs...\\n' >&2
    koopa configure user doom-emacs
fi
exec emacs --init-directory="$EMACSDIR" "$@"
"""


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Doom Emacs.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    env = activate_app_deps()
    if env is not None:
        env.apply()
    libexec = os.path.join(prefix, "libexec")
    git_clone(
        "https://github.com/hlissner/doom-emacs.git",
        libexec,
        commit=version,
    )
    # NOTE: All real Doom modules (evil, magit, doom-themes, etc.) live in the
    # 'sources/doom+' submodule, not the main repo. Without this, only the
    # built-in ':doom compat' pseudo-module is available and every other
    # enabled module silently resolves to no package path.
    git_submodule_init(libexec)
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
    emacs_path = os.path.join(bin_dir, "doom-emacs")
    with open(emacs_path, "w") as f:
        f.write(_DOOM_EMACS_WRAPPER)
    os.chmod(emacs_path, os.stat(emacs_path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
