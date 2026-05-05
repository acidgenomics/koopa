"""Install cli11."""

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install cli11."""
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DCLI11_BUILD_DOCS=OFF", "-DCLI11_BUILD_TESTS=OFF"],
    )
