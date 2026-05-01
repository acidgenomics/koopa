"""Install udunits."""

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
    """Install udunits."""
    env = activate_app("expat", env=None)
    url = (
        f"https://downloads.unidata.ucar.edu/udunits/"
        f"{version}/udunits-{version}.tar.gz"
    )
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
