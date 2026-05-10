"""Install dotfiles."""

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dotfiles."""
    env = activate_app_deps()
    env.apply()
    url = "https://github.com/acidgenomics/dotfiles.git"
    git_clone(url, prefix, commit=version)
