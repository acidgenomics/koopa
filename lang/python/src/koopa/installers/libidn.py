"""Install libidn."""

from __future__ import annotations

from koopa.install import install_gnu_app


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libidn."""
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        conf_args=["--disable-static"],
    )
