"""Install sqlite."""

from __future__ import annotations

import re

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _version_to_year(version: str) -> str:
    if version.startswith("3.47."):
        return "2024"
    if re.match(r"3\.4[1-4]\.", version):
        return "2023"
    if re.match(r"3\.3[7-9]\.", version) or version.startswith("3.40."):
        return "2022"
    if re.match(r"3\.3[4-7]\.", version):
        return "2021"
    if re.match(r"3\.3[2-4]\.", version):
        return "2020"
    msg = f"Unsupported sqlite version: {version!r}"
    raise ValueError(msg)


def _file_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}{int(parts[1]):02d}{int(parts[2]):02d}00"


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
    year = _version_to_year(version)
    fv = _file_version(version)
    url = f"https://www.sqlite.org/{year}/sqlite-autoconf-{fv}.tar.gz"
    download_extract_cd(url)
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-editline",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-readline",
            "--enable-shared=yes",
            "--enable-threadsafe",
            f"--prefix={prefix}",
        ],
        env=env,
    )
