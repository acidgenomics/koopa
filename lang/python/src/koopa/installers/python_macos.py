"""Install Python framework on macOS."""

from __future__ import annotations

import os
import subprocess
import sys

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
    print(f"Target: {framework_prefix}", file=sys.stderr)
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
    versions_prefix = os.path.join(framework_prefix, "Versions")
    if os.path.isdir(versions_prefix):
        for entry in os.listdir(versions_prefix):
            entry_path = os.path.join(versions_prefix, entry)
            if entry_path == python_prefix:
                continue
            if os.path.islink(entry_path):
                continue
            if not os.path.isdir(entry_path):
                continue
            print(f"Removing old version: {entry_path}", file=sys.stderr)
            subprocess.run(
                ["sudo", "rm", "-rf", entry_path],
                check=True,
            )
    ln(
        f"python{maj_ver}",
        os.path.join(python_prefix, "bin", "python"),
    )
    os.makedirs("/usr/local/bin", exist_ok=True)
    ln(
        python_bin,
        "/usr/local/bin/python",
    )
