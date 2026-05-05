"""Install tl-expected."""

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tl-expected."""
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DEXPECTED_ENABLE_TESTS=OFF"],
    )
