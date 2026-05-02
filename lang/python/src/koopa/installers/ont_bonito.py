"""Install ONT Bonito."""

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
    """Install ONT Bonito."""
    activate_app("zlib")
    install_python_package(
        name=name,
        version=version,
        prefix=prefix,
        egg_name="ont_bonito",
        python_version="3.13",
    )
