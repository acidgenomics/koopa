"""Install emacs-prelude."""

import os
import stat

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps

_EMACS_PRELUDE_WRAPPER = """\
#!/bin/sh
set -eu
_self="$0"
if [ -L "$_self" ]; then
    _self="$(readlink "$_self")"
fi
prefix="$(cd "$(dirname "$_self")/.." && pwd)"
init_dir="${prefix}/libexec"
export PRELUDE_LOCAL_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/prelude"
exec emacs --init-directory="$init_dir" "$@"
"""

_PRELUDE_EARLY_INIT = """\
;; -*- mode: emacs-lisp; lexical-binding: t; -*-
;; Store packages outside the managed install tree.
(when-let ((local-dir (getenv "PRELUDE_LOCAL_DIR")))
  (setq package-user-dir (expand-file-name "elpa" local-dir)))
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
    early_init = os.path.join(libexec, "early-init.el")
    with open(early_init, "w") as f:
        f.write(_PRELUDE_EARLY_INIT)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    wrapper = os.path.join(bin_dir, "prelude")
    with open(wrapper, "w") as f:
        f.write(_EMACS_PRELUDE_WRAPPER)
    os.chmod(wrapper, os.stat(wrapper).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
