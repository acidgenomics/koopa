"""Koopa prefix and directory path functions.

Converted from POSIX shell and Bash prefix functions.
"""

import os
from pathlib import Path


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
    if "KOOPA_BOOTSTRAP_PREFIX" in os.environ:
        return os.environ["KOOPA_BOOTSTRAP_PREFIX"]
    return koopa_prefix().rstrip(os.sep) + "-bootstrap"


def config_prefix() -> str:
    """Return koopa config/etc prefix."""
    return os.path.join(koopa_prefix(), "etc", "koopa")


def man_prefix() -> str:
    """Return koopa man prefix."""
    return os.path.join(koopa_prefix(), "share", "man")


def man1_prefix() -> str:
    """Return koopa man1 prefix."""
    return os.path.join(man_prefix(), "man1")


def bash_completions_prefix() -> str:
    """Return koopa central bash-completion completions directory."""
    return os.path.join(koopa_prefix(), "share", "bash-completion", "completions")


def fish_completions_prefix() -> str:
    """Return koopa central fish completions directory."""
    return os.path.join(koopa_prefix(), "share", "fish", "vendor_completions.d")


def zsh_completions_prefix() -> str:
    """Return koopa central zsh completions directory."""
    return os.path.join(koopa_prefix(), "share", "zsh", "site-functions")


def scripts_private_prefix() -> str:
    """Return private scripts prefix."""
    return os.environ.get(
        "KOOPA_SCRIPTS_PRIVATE_PREFIX",
        os.path.join(
            os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config")),
            "koopa",
            "scripts-private",
        ),
    )


def website_prefix() -> str:
    """Return koopa website prefix."""
    return os.environ.get(
        "KOOPA_WEBSITE_PREFIX",
        os.path.expanduser("~/git/koopa-acidgenomics-com"),
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
