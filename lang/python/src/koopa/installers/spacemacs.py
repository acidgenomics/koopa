"""Install Spacemacs."""

from koopa.build import activate_app
from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Spacemacs."""
    env = activate_app("git", build_only=True)
    env.apply()
    git_clone(
        "https://github.com/syl20bnr/spacemacs.git",
        prefix,
        commit=version,
    )
