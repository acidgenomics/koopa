#!/usr/bin/env python3

"""
Build all Docker tags.
Updated 2023-12-11.

Example:
./docker-build-all-tags.py \
    --local="${HOME}/monorepo/docker/acidgenomics/koopa" \
    --remote='public.ecr.aws/acidgenomics/koopa'
"""

from argparse import ArgumentParser
from os.path import abspath, dirname, expanduser, join, isdir
from subprocess import run
from sys import path, version_info

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import list_subdirs

parser = ArgumentParser()
parser.add_argument("--local", required=True)
parser.add_argument("--remote", required=True)
args = parser.parse_args()


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


def main(local: str, remote: str) -> bool:
    """
    Build all Docker images.
    Updated 2023-12-11.

    Example:
    local = "~/monorepo/docker/acidgenomics/koopa"
    remote = "public.ecr.aws/acidgenomics/koopa"
    main(local=local, remote=remote)
    """
    local = expanduser(local)
    local = abspath(local)
    assert isdir(local)
    subdirs = list_subdirs(local)
    for subdir in subdirs:
        local2 = join(local, subdir)
        assert isdir(local2)
        remote2 = remote + ":" + subdir
        build_tag(local=local2, remote=remote2)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(local=args.local, remote=args.remote)
