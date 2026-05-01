"""Install libvterm."""

from __future__ import annotations

import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def _major_minor_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}.{parts[1]}"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libvterm."""
    env = activate_app("libtool", "make", "pkg-config", build_only=True)
    make = locate("make")
    mm = _major_minor_version(version)
    url = (
        f"https://launchpad.net/libvterm/trunk/v{mm}/+download/"
        f"libvterm-{version}.tar.gz"
    )
    download_extract_cd(url)
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=env.to_env_dict(),
        check=True,
    )
