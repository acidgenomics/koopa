"""Install dotfiles."""

from __future__ import annotations

from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dotfiles."""
    url = "https://github.com/acidgenomics/dotfiles.git"
    git_clone(url, prefix, commit=version)
