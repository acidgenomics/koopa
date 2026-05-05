"""Install termcolor."""

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install termcolor."""
    download_extract_cd()
    cmake_build(prefix=prefix)
