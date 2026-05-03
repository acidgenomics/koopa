"""Install mpdecimal."""

from __future__ import annotations

from koopa.build import make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install mpdecimal."""
    filename = f"mpdecimal-{version}.tar.gz"
    primary_url = f"https://www.bytereef.org/software/mpdecimal/releases/{filename}"
    tarball = download_with_mirror(primary_url, name, filename)
    extract_cd(tarball)
    make_build(
        conf_args=["--disable-static", f"--prefix={prefix}"],
    )
    remove_static_libs(prefix)
