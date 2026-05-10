"""Install dotfiles."""

from koopa.build import activate_app
from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dotfiles."""
    env = activate_app("git", build_only=True)
    env.apply()
    url = "https://github.com/acidgenomics/dotfiles.git"
    git_clone(url, prefix, commit=version)
