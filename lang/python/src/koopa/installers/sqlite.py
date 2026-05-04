"""Install sqlite."""

from __future__ import annotations

import datetime

from koopa.build import activate_app, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import extract_cd


def _file_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}{int(parts[1]):02d}{int(parts[2]):02d}00"


def _primary_url(file_version: str) -> str:
    year = datetime.datetime.now(tz=datetime.UTC).year
    return f"https://www.sqlite.org/{year}/sqlite-autoconf-{file_version}.tar.gz"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install sqlite."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "readline", env=env)
    file_version = _file_version(version)
    url = _primary_url(file_version)
    filename = f"sqlite-autoconf-{file_version}.tar.gz"
    tarball = download_with_mirror(url, "sqlite", filename)
    extract_cd(tarball)
    make_build(
        conf_args=[
            "--disable-static",
            f"--prefix={prefix}",
        ],
        env=env,
    )
