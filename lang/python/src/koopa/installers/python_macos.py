"""Install Python framework on macOS."""

from __future__ import annotations

import os
import subprocess

from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Python framework on macOS."""
    framework_prefix = "/Library/Frameworks/Python.framework"
    maj_ver = version.split(".", maxsplit=1)[0]
    maj_min_ver = ".".join(version.split(".")[:2])
    python_prefix = os.path.join(framework_prefix, "Versions", maj_min_ver)
    result = subprocess.run(
        ["sw_vers", "-productVersion"],
        capture_output=True,
        text=True,
        check=True,
    )
    macos_version = result.stdout.strip()
    macos_string = "macosx10.9" if macos_version.startswith("10") else "macos11"
    url = f"https://www.python.org/ftp/python/{version}/python-{version}-{macos_string}.pkg"
    pkg_file = download(url)
    subprocess.run(
        ["sudo", "installer", "-pkg", pkg_file, "-target", "/"],
        check=True,
    )
    python_bin = os.path.join(python_prefix, "bin", f"python{maj_ver}")
    if not os.path.isfile(python_bin):
        msg = f"Python binary not found: {python_bin}"
        raise RuntimeError(msg)
    ln(
        f"python{maj_ver}",
        os.path.join(python_prefix, "bin", "python"),
    )
    os.makedirs("/usr/local/bin", exist_ok=True)
    ln(
        python_bin,
        "/usr/local/bin/python",
    )
