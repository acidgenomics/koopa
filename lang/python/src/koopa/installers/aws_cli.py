"""Install aws-cli."""

from __future__ import annotations

import os

from koopa.install import install_conda_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install aws-cli."""
    kwargs = parse_passthrough(passthrough_args)
    install_conda_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
    )
    _setup_completions(prefix)


def _setup_completions(prefix: str) -> None:
    """Symlink aws-cli completion files into standard locations within the prefix.

    aws-cli ships ``bin/aws_bash_completer`` (contains ``complete -C
    aws_completer aws``) and ``bin/aws_zsh_completer.sh`` (a sourceable zsh
    script).  Neither lives in a standard completion directory, so we create
    symlinks that the generic scanner and zsh activation can find.
    """
    prefix = os.path.abspath(prefix)
    # Bash: symlink into share/bash-completion/completions/ so the generic
    # scanner picks it up and bash-completion v2 can lazy-load it.
    bash_src = os.path.join(prefix, "bin", "aws_bash_completer")
    if os.path.isfile(bash_src):
        bash_dir = os.path.join(prefix, "share", "bash-completion", "completions")
        os.makedirs(bash_dir, exist_ok=True)
        bash_target = os.path.join(bash_dir, "aws")
        if os.path.islink(bash_target):
            os.unlink(bash_target)
        os.symlink(bash_src, bash_target)

    # Zsh: the completer script is meant to be sourced at shell startup (it
    # calls autoload + bashcompinit internally).  Symlink it into
    # share/zsh/site-functions/ under a stable name so the zsh activation
    # function can source it without hard-coding the bin/ path.
    zsh_src = os.path.join(prefix, "bin", "aws_zsh_completer.sh")
    if os.path.isfile(zsh_src):
        zsh_dir = os.path.join(prefix, "share", "zsh", "site-functions")
        os.makedirs(zsh_dir, exist_ok=True)
        zsh_target = os.path.join(zsh_dir, "aws_zsh_completer.sh")
        if os.path.islink(zsh_target):
            os.unlink(zsh_target)
        os.symlink(zsh_src, zsh_target)
