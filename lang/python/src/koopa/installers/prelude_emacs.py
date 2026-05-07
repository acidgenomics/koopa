"""Install prelude-emacs."""

import subprocess

from koopa.build import activate_app
from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install prelude-emacs."""
    env = activate_app("git", build_only=True)
    env.apply()
    git_clone(
        "https://github.com/bbatsov/prelude.git",
        prefix,
        commit=version,
    )
    subprocess.run(
        ["emacs", "--no-window-system", "--batch", "--load", f"{prefix}/init.el"],
        check=True,
    )
