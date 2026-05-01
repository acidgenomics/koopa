"""Install gseapy."""

from __future__ import annotations

from koopa.build import activate_app
from koopa.install import install_python_package


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gseapy."""
    activate_app("rust", build_only=True)
    install_python_package(name=name, version=version, prefix=prefix)
