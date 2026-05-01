"""Generic conda package installer."""

from __future__ import annotations

from koopa.install import install_conda_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a conda package."""
    kwargs = parse_passthrough(passthrough_args)
    install_conda_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        yaml_file=get_str(kwargs, "yaml_file"),
    )
