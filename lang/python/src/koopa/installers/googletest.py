"""Install googletest."""

from koopa.build import cmake_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install googletest."""
    env = activate_app_deps()
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_GMOCK=ON", "-DBUILD_SHARED_LIBS=ON"],
        env=env,
    )
