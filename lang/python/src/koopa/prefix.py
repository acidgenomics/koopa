"""Koopa prefix and directory path functions.

Converted from POSIX shell and Bash prefix functions.
"""

import os
import sys
from pathlib import Path

from koopa.xdg import xdg_config_home


def koopa_prefix() -> str:
    """Return koopa installation prefix.

    Honors 'KOOPA_PREFIX' when set, matching what 'bin/koopa' and
    'activate.sh' already export. Falls back to the git-checkout layout
    ('lang/python/src/koopa/__file__' -> 4 levels up = koopa root) for
    unactivated shells. As a last resort (e.g. installed as a package with
    no koopa data tree alongside it), returns the package's own directory.
    """
    env_prefix = os.environ.get("KOOPA_PREFIX")
    if env_prefix and os.path.isdir(env_prefix):
        return env_prefix
    p = Path(__file__).resolve()
    checkout_root = p.parents[4]
    if (checkout_root / "lang" / "python" / "src").is_dir():
        return str(checkout_root)
    return str(p.parent)


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
    if "KOOPA_BOOTSTRAP_PREFIX" in os.environ:
        return os.environ["KOOPA_BOOTSTRAP_PREFIX"]
    return koopa_prefix().rstrip(os.sep) + "-bootstrap"


def data_prefix() -> str:
    """Return the prefix containing koopa's data files ('etc/', 'share/').

    Under a git checkout or an activated shell (``KOOPA_PREFIX`` set), this is
    'koopa_prefix()' itself. setuptools cannot package 'etc/koopa/app.json' or
    'share/' as package-data because they live outside the 'koopa' package
    directory ('lang/python/src/koopa/'), so an installed (e.g. conda) package
    instead relies on its build recipe having copied them under
    'sys.prefix' -- the same convention koopa's own recipes use for tools
    like 'git' that drop a bash-completion file under
    '$PREFIX/share/bash-completion/completions/'.
    """
    prefix = koopa_prefix()
    if os.path.isfile(os.path.join(prefix, "etc", "koopa", "app.json")):
        return prefix
    return sys.prefix


def config_prefix() -> str:
    """Return koopa config/etc prefix."""
    return os.path.join(data_prefix(), "etc", "koopa")


def man_prefix() -> str:
    """Return koopa man prefix."""
    return os.path.join(data_prefix(), "share", "man")


def man1_prefix() -> str:
    """Return koopa man1 prefix."""
    return os.path.join(man_prefix(), "man1")


def bash_completions_prefix() -> str:
    """Return koopa central bash-completion completions directory."""
    return os.path.join(data_prefix(), "share", "bash-completion", "completions")


def fish_completions_prefix() -> str:
    """Return koopa central fish completions directory."""
    return os.path.join(data_prefix(), "share", "fish", "vendor_completions.d")


def zsh_completions_prefix() -> str:
    """Return koopa central zsh completions directory."""
    return os.path.join(data_prefix(), "share", "zsh", "site-functions")


def powershell_completions_prefix() -> str:
    """Return koopa central PowerShell completions directory."""
    return os.path.join(data_prefix(), "share", "powershell", "completions")


def scripts_private_prefix() -> str:
    """Return private scripts prefix."""
    return os.environ.get(
        "KOOPA_SCRIPTS_PRIVATE_PREFIX",
        os.path.join(xdg_config_home(), "koopa", "scripts-private"),
    )


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


def go_prefix() -> str:
    """Return Go prefix."""
    return os.environ.get("GOPATH", os.path.expanduser("~/go"))


def emacs_prefix() -> str:
    """Return Emacs config prefix."""
    return os.path.expanduser("~/.emacs.d")
