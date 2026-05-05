"""Install libfido2."""

from koopa.build import activate_app, cmake_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libfido2."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("libcbor", "openssl", "zlib", env=env)
    download_extract_cd()
    cmake_build(
        prefix=prefix,
        args=["-DBUILD_STATIC_LIBS=OFF"],
        env=env,
    )
