"""Koopa prefix and directory path functions.

Converted from POSIX shell and Bash prefix functions.
"""

from __future__ import annotations

import os
from pathlib import Path

from koopa.system import arch, is_macos
from koopa.xdg import xdg_local_home


def koopa_prefix() -> str:
    """Return koopa installation prefix."""
    p = Path(__file__).resolve()
    # lang/python/src/koopa/__file__ -> 4 levels up = koopa root
    return str(p.parents[4])


def app_prefix(name: str | None = None, version: str | None = None) -> str:
    """Return application prefix directory."""
    base = os.path.join(koopa_prefix(), "app")
    if name is None:
        return base
    if version is None:
        return os.path.join(base, name)
    return os.path.join(base, name, version)


def bin_prefix() -> str:
    """Return koopa bin prefix."""
    return os.path.join(koopa_prefix(), "bin")


def opt_prefix() -> str:
    """Return koopa opt prefix."""
    return os.path.join(koopa_prefix(), "opt")


def bootstrap_prefix() -> str:
    """Return bootstrap prefix."""
    return os.environ.get("KOOPA_BOOTSTRAP_PREFIX", os.path.join(koopa_prefix(), "bootstrap"))


def config_prefix() -> str:
    """Return koopa config/etc prefix."""
    return os.path.join(koopa_prefix(), "etc", "koopa")


def man_prefix() -> str:
    """Return koopa man prefix."""
    return os.path.join(koopa_prefix(), "share", "man")


def man1_prefix() -> str:
    """Return koopa man1 prefix."""
    return os.path.join(man_prefix(), "man1")


def etc_prefix() -> str:
    """Return koopa etc prefix."""
    return os.path.join(koopa_prefix(), "etc")


def local_data_prefix() -> str:
    """Return local data prefix."""
    return xdg_local_home()


def monorepo_prefix() -> str:
    """Return monorepo prefix."""
    return os.environ.get("KOOPA_MONOREPO_PREFIX", os.path.expanduser("~/monorepo"))


def scripts_private_prefix() -> str:
    """Return private scripts prefix."""
    return os.environ.get("KOOPA_SCRIPTS_PRIVATE_PREFIX", os.path.expanduser("~/scripts-private"))


def tests_prefix() -> str:
    """Return koopa tests prefix."""
    return os.path.join(config_prefix(), "tests")


def patch_prefix() -> str:
    """Return patch prefix."""
    return os.path.join(etc_prefix(), "koopa", "patch")


def bash_prefix() -> str:
    """Return bash language prefix."""
    return os.path.join(koopa_prefix(), "lang", "bash")


def sh_prefix() -> str:
    """Return sh language prefix."""
    return os.path.join(koopa_prefix(), "lang", "sh")


def zsh_prefix() -> str:
    """Return zsh language prefix."""
    return os.path.join(koopa_prefix(), "lang", "zsh")


def python_prefix() -> str:
    """Return python language prefix."""
    return os.path.join(koopa_prefix(), "lang", "python")


def r_prefix() -> str:
    """Return R language prefix."""
    return os.path.join(koopa_prefix(), "lang", "r")


def conda_prefix() -> str:
    """Return conda prefix."""
    return os.environ.get("CONDA_PREFIX", os.path.join(app_prefix(), "conda"))


def homebrew_prefix() -> str:
    """Return Homebrew prefix."""
    if is_macos():
        if arch() == "arm64":
            return "/opt/homebrew"
        return "/usr/local"
    return os.path.join(koopa_prefix(), "app", "homebrew")


def go_prefix() -> str:
    """Return Go prefix."""
    return os.environ.get("GOPATH", os.path.expanduser("~/go"))


def pipx_prefix() -> str:
    """Return pipx prefix."""
    return os.environ.get("PIPX_HOME", os.path.expanduser("~/.local/pipx"))


def pyenv_prefix() -> str:
    """Return pyenv prefix."""
    return os.environ.get("PYENV_ROOT", os.path.expanduser("~/.pyenv"))


def rbenv_prefix() -> str:
    """Return rbenv prefix."""
    return os.environ.get("RBENV_ROOT", os.path.expanduser("~/.rbenv"))


def asdf_prefix() -> str:
    """Return asdf prefix."""
    return os.environ.get("ASDF_DIR", os.path.expanduser("~/.asdf"))


def julia_packages_prefix() -> str:
    """Return Julia packages prefix."""
    return os.environ.get("JULIA_DEPOT_PATH", os.path.expanduser("~/.julia"))


def emacs_prefix() -> str:
    """Return Emacs config prefix."""
    return os.path.expanduser("~/.emacs.d")


def doom_emacs_prefix() -> str:
    """Return Doom Emacs prefix."""
    return os.path.expanduser("~/.doom.d")


def prelude_emacs_prefix() -> str:
    """Return Prelude Emacs prefix."""
    return os.path.expanduser("~/.emacs.d")


def spacemacs_prefix() -> str:
    """Return Spacemacs prefix."""
    return os.path.expanduser("~/.spacemacs.d")


def spacevim_prefix() -> str:
    """Return SpaceVim prefix."""
    return os.path.expanduser("~/.SpaceVim.d")


def aspera_connect_prefix() -> str:
    """Return Aspera Connect prefix."""
    return os.path.expanduser("~/.aspera/connect")


def docker_private_prefix() -> str:
    """Return Docker private prefix."""
    return os.environ.get("KOOPA_DOCKER_PRIVATE_PREFIX", os.path.expanduser("~/docker-private"))
