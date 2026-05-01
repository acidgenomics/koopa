"""Install fontconfig."""

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
    """Install fontconfig."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("gperf", "freetype", "icu4c", "libxml2", env=env)
    url = (
        f"https://www.freedesktop.org/software/fontconfig/release/"
        f"fontconfig-{version}.tar.xz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--enable-libxml2",
            f"--prefix={prefix}",
        ],
        env=env,
    )
