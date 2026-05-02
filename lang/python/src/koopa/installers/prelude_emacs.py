"""Install prelude-emacs."""

from __future__ import annotations

import subprocess

from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install prelude-emacs."""
    git_clone(
        "https://github.com/bbatsov/prelude.git",
        prefix,
        branch=version,
    )
    subprocess.run(
        ["emacs", "--no-window-system", "--batch", "--load", f"{prefix}/init.el"],
        check=True,
    )
