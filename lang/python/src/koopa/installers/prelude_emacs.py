"""Install prelude-emacs."""

import subprocess

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install prelude-emacs."""
    env = activate_app_deps()
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
