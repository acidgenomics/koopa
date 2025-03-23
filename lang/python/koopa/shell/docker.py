"""
Docker image management functions.
Updated 2024-06-23.
"""

from os.path import abspath, expanduser, isdir, join
from subprocess import run

from koopa.fs import list_subdirs


def build_all_tags(local: str, remote: str) -> bool:
    """
    Build all Docker tags.
    Updated 2024-05-05.

    Example:
    >>> local = "~/monorepo/docker/acidgenomics/koopa"
    >>> remote = "public.ecr.aws/acidgenomics/koopa"
    >>> main(local=local, remote=remote)
    """
    local = abspath(expanduser(local))
    assert isdir(local)
    tags = list_subdirs(
        path=local, recursive=False, sort=True, basename_only=True
    )
    for tag in tags:
        local2 = join(local, tag)
        assert isdir(tag)
        remote2 = remote + ":" + tag
        build_tag(local=local2, remote=remote2)
    return True


def build_tag(local: str, remote: str) -> bool:
    """
    Build a Docker tag.
    Updated 2023-12-11.

    Examples:
    local = "~/monorepo/docker/acidgenomics/koopa/ubuntu"
    remote = "public.ecr.aws/acidgenomics/koopa:ubuntu"
    build_tag(local=local, remote=remote)
    """
    run(
        args=[
            "koopa",
            "app",
            "docker",
            "build",
            "--local",
            local,
            "--remote",
            remote,
        ],
        check=True,
    )
    return True
