"""Install CloudBioLinux."""

from koopa.git import git_clone
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install CloudBioLinux."""
    env = activate_app_deps()
    env.apply()
    git_clone(
        "https://github.com/chapmanb/cloudbiolinux.git",
        prefix,
        commit=version,
    )
