"""Install libconfig."""

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
    """Install libconfig."""
    url = (
        f"https://github.com/hyperrealm/libconfig/releases/download/"
        f"v{version}/libconfig-{version}.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            f"--prefix={prefix}",
        ],
    )
