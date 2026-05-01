"""Generic Go package installer."""

from __future__ import annotations

from koopa.install import install_go_package
from koopa.installers._args import get_str, parse_passthrough


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a Go package."""
    kwargs = parse_passthrough(passthrough_args)
    url = get_str(kwargs, "url")
    if not url:
        msg = f"Go package '{name}' requires a --url passthrough arg."
        raise ValueError(msg)
    install_go_package(
        url=url,
        prefix=prefix,
    )
