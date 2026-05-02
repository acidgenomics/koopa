"""Install libpng."""

from __future__ import annotations

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libpng."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", env=env)
    url = f"https://sourceforge.net/projects/libpng/files/libpng16/{version}/libpng-{version}.tar.xz/download"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-shared=yes",
            f"--prefix={prefix}",
        ],
        env=env,
    )
