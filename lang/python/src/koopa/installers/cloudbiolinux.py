"""Install CloudBioLinux."""

from __future__ import annotations

from koopa.git import git_clone


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install CloudBioLinux."""
    git_clone(
        "https://github.com/chapmanb/cloudbiolinux.git",
        prefix,
        commit=version,
    )
