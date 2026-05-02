"""Install Spacemacs."""

from __future__ import annotations

from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    git_clone(
        "https://github.com/syl20bnr/spacemacs.git",
        prefix,
        branch=version,
    )
