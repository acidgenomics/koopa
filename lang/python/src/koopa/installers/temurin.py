"""Install temurin."""

from __future__ import annotations

import os
import shutil
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.file_ops import ln
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install temurin."""
    machine = arch()
    if sys.platform == "darwin":
        os_id = "mac"
    else:
        os_id = "linux"
    if machine in ("aarch64", "arm64"):
        arch_id = "aarch64"
    else:
        arch_id = "x64"
    ver_url = version.replace("+", "%2B")
    ver_file = version.replace("+", "_")
    url = (
        f"https://github.com/adoptium/temurin21-binaries/releases/download/"
        f"jdk-{ver_url}/OpenJDK21U-jdk_{arch_id}_{os_id}_hotspot_{ver_file}.tar.gz"
    )
    tarball = download(url)
    libexec = os.path.join(prefix, "libexec")
    extract(tarball, libexec)
    if sys.platform == "darwin":
        contents_home = None
        for entry in os.listdir(libexec):
            candidate = os.path.join(libexec, entry, "Contents", "Home")
            if os.path.isdir(candidate):
                contents_home = candidate
                break
        if contents_home:
            for d in ("bin", "include", "lib"):
                src = os.path.join(contents_home, d)
                dst = os.path.join(prefix, d)
                if os.path.isdir(src):
                    ln(src, dst)
    else:
        for d in ("bin", "include", "lib"):
            for entry in os.listdir(libexec):
                src = os.path.join(libexec, entry, d)
                if os.path.isdir(src):
                    ln(src, os.path.join(prefix, d))
                    break
