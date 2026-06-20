"""Install brotli."""

from koopa.build import cmake_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install brotli."""
    env = activate_app_deps()
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_STATIC_LIBS=OFF"],
        env=env,
    )
