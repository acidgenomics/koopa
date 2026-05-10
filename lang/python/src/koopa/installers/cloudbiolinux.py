"""Install CloudBioLinux."""

from koopa.build import activate_app
from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install CloudBioLinux."""
    env = activate_app("git", build_only=True)
    env.apply()
    git_clone(
        "https://github.com/chapmanb/cloudbiolinux.git",
        prefix,
        commit=version,
    )
