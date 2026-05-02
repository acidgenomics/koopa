"""Install r-xcode-openmp."""

from __future__ import annotations

import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-xcode-openmp."""
    major = version.split(".", maxsplit=1)[0]
    darwin_versions = {
        "18": "22",
        "17": "22",
        "16": "22",
        "15": "21",
        "14": "21",
        "13": "20",
        "12": "20",
    }
    darwin_ver = darwin_versions.get(major, "22")
    url = f"https://mac.r-project.org/openmp/openmp-{version}-darwin{darwin_ver}-Release.tar.gz"
    tar_file = download(url)
    subprocess.run(
        ["sudo", "tar", "xzf", tar_file, "-C", "/usr/local"],
        check=True,
    )
