"""Install tbb."""

from koopa.build import cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install tbb."""
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_SHARED_LIBS=ON",
            "-DTBB4PY_BUILD=OFF",
            "-DTBB_TEST=OFF",
        ],
        jobs=1,
    )
