"""Install isl."""

from __future__ import annotations

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install isl."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gmp", env=env)
    gmp_prefix = app_prefix("gmp")
    url = f"https://libisl.sourceforge.io/isl-{version}.tar.xz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            f"--prefix={prefix}",
            "--with-gmp=system",
            f"--with-gmp-prefix={gmp_prefix}",
        ],
        env=env,
    )
