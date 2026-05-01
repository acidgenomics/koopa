"""Install mpdecimal."""

from __future__ import annotations

from koopa.build import make_build
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install mpdecimal."""
    url = f"https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-{version}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=["--disable-static", f"--prefix={prefix}"],
    )
    remove_static_libs(prefix)
