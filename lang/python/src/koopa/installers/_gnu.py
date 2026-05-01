"""Generic GNU app installer."""

from __future__ import annotations

from koopa.install import install_gnu_app
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a GNU app from source."""
    kwargs = parse_passthrough(passthrough_args)
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        compress_ext=get_str(kwargs, "compress_ext", "gz"),
        package_name=get_str(kwargs, "package_name"),
        parent_name=get_str(kwargs, "parent_name"),
        non_gnu_mirror=get_str(kwargs, "non_gnu_mirror") == "true",
    )
