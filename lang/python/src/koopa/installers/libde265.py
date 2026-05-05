"""Install libde265."""

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libde265."""
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DENABLE_DECODER=OFF", "-DENABLE_TOOLS=ON"],
    )
