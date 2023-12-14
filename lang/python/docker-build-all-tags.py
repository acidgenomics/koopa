#!/usr/bin/env python3

"""
Build all Docker tags.
Updated 2023-12-14.

Example:
./docker-build-all-tags.py \
    --local="${HOME}/monorepo/docker/acidgenomics/koopa" \
    --remote='public.ecr.aws/acidgenomics/koopa'
"""

from argparse import ArgumentParser
from os.path import dirname, join
from sys import path, version_info

path.insert(0, join(dirname(__file__), "koopa"))

from koopa import docker_build_all_tags

parser = ArgumentParser()
parser.add_argument("--local", required=True)
parser.add_argument("--remote", required=True)
args = parser.parse_args()


def main(local: str, remote: str) -> None:
    """
    Main function.
    Updated 2023-12-14.
    """
    docker_build_all_tags(local=local, remote=remote)
    return None


if __name__ == "__main__":
    if not version_info >= (3, 8):
        raise RuntimeError("Unsupported Python version.")
    main(local=args.local, remote=args.remote)
