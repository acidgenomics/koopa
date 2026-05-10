"""Install Doom Emacs."""

import os
import stat

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps

_DOOM_EMACS_WRAPPER = """\
#!/bin/sh
set -eu
prefix="$(cd "$(dirname "$0")/.." && pwd)"
init_dir="${prefix}/libexec"
if [ ! -f "${HOME}/.config/doom/init.el" ]; then
    printf 'First run: configuring doom-emacs...\\n' >&2
    koopa configure user doom-emacs
fi
emacs="emacs"
if [ "$(uname -s)" = "Darwin" ]; then
    _homebrew_prefix="${HOMEBREW_PREFIX:-/opt/homebrew}"
    if [ -x "${_homebrew_prefix}/bin/emacs" ]; then
        emacs="${_homebrew_prefix}/bin/emacs"
    fi
fi
if [ "$(uname -s)" = "Darwin" ] && [ -e "${HOME}/.terminfo/78/xterm-24bit" ]; then
    export TERM='xterm-24bit'
fi
exec "$emacs" --init-directory="$init_dir" "$@" >/dev/null 2>&1
"""

_DOOM_WRAPPER = """\
#!/bin/sh
set -eu
prefix="$(cd "$(dirname "$0")/.." && pwd)"
export EMACSDIR="${prefix}/libexec"
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
    for script_name, content in (
        ("doom-emacs", _DOOM_EMACS_WRAPPER),
        ("doom", _DOOM_WRAPPER),
    ):
        path = os.path.join(bin_dir, script_name)
        with open(path, "w") as f:
            f.write(content)
        os.chmod(path, os.stat(path).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
