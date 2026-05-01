"""Install gmp."""

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
    """Install gmp."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("m4", env=env)
    download_extract_cd(f"https://gmplib.org/download/gmp/gmp-{version}.tar.xz")
    make_build(
        conf_args=[
            "--disable-static",
            "--enable-cxx",
            f"--prefix={prefix}",
            "--with-pic",
        ],
        env=env,
    )
