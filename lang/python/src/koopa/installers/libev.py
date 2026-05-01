"""Install libev."""

from __future__ import annotations

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libev."""
    url = f"https://fossies.org/linux/misc/libev-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-static",
            f"--prefix={prefix}",
        ],
    )
