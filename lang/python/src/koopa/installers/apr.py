"""Install apr."""

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
    """Install apr."""
    env = activate_app("pkg-config", build_only=True)
    url = f"https://archive.apache.org/dist/apr/apr-{version}.tar.bz2"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
