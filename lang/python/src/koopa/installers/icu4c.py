"""Install icu4c."""

from __future__ import annotations

import os
from pathlib import Path

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install icu4c."""
    env = activate_app("pkg-config", build_only=True)
    url = (
        f"https://github.com/unicode-org/icu/releases/download/"
        f"release-{version}/icu4c-{version}-sources.tgz"
    )
    download_extract_cd(url)
    if os.path.islink("LICENSE") and not os.path.exists("LICENSE"):
        os.unlink("LICENSE")
        Path("LICENSE").touch()
    os.chdir("source")
    env.ldflags.insert(0, f"-Wl,-rpath,{prefix}/lib")
    make_build(
        conf_args=[
            "--disable-samples",
            "--disable-static",
            "--disable-tests",
            "--enable-rpath",
            "--enable-shared",
            "--with-library-bits=64",
            f"--prefix={prefix}",
        ],
        env=env,
    )
