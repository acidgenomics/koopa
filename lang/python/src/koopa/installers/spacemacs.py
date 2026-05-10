"""Install Spacemacs."""

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Spacemacs."""
    env = activate_app_deps()
    env.apply()
    git_clone(
        "https://github.com/syl20bnr/spacemacs.git",
        prefix,
        commit=version,
    )
