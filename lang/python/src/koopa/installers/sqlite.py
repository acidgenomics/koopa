"""Install sqlite."""

from __future__ import annotations

import datetime
import urllib.request

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def _file_version(version: str) -> str:
    parts = version.split(".")
    return f"{parts[0]}{int(parts[1]):02d}{int(parts[2]):02d}00"


def _resolve_url(file_version: str) -> str:
    current_year = datetime.datetime.now(tz=datetime.timezone.utc).year
    for year in (current_year, current_year - 1, current_year - 2):
        url = f"https://www.sqlite.org/{year}/sqlite-autoconf-{file_version}.tar.gz"
        try:
            req = urllib.request.Request(url, method="HEAD")
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status == 200:
                    return url
        except Exception:
            continue
    msg = f"Cannot find sqlite download for file version {file_version}"
    raise RuntimeError(msg)


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
    url = _resolve_url(_file_version(version))
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
