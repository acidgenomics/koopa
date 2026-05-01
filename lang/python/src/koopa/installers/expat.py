"""Install expat."""

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
    """Install expat."""
    env = activate_app("pkg-config", build_only=True)
    version_tag = version.replace(".", "_")
    url = (
        f"https://github.com/libexpat/libexpat/releases/"
        f"download/R_{version_tag}/expat-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=["--disable-static", f"--prefix={prefix}"],
        env=env,
    )
