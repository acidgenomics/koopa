"""Install emacs-prelude."""

import os
import stat

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps

_EMACS_PRELUDE_WRAPPER = """\
#!/bin/sh
set -eu
prefix="$(cd "$(dirname "$0")/.." && pwd)"
init_dir="${prefix}/libexec"
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


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install emacs-prelude."""
    env = activate_app_deps()
    env.apply()
    libexec = os.path.join(prefix, "libexec")
    git_clone(
        "https://github.com/bbatsov/prelude.git",
        libexec,
        commit=version,
    )
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    wrapper = os.path.join(bin_dir, "emacs-prelude")
    with open(wrapper, "w") as f:
        f.write(_EMACS_PRELUDE_WRAPPER)
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
