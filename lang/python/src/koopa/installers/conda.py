"""Install conda."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.prefix import koopa_prefix
from koopa.system import arch, has_firewall
from koopa.version import major_minor_version, major_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install conda (miniconda)."""
    py_version = "3.13"
    if has_firewall():
        py_version = "3.12"
    if passthrough_args:
        for arg in passthrough_args:
            if arg.startswith("--py-version="):
                py_version = arg.split("=", 1)[1]
    py_version = major_minor_version(py_version)
    py_major = major_version(py_version)
    py_version2 = py_version.replace(".", "")
    machine = arch()
    arch2 = machine
    if sys.platform == "darwin":
        os_type2 = "MacOSX"
        if machine == "aarch64":
            arch2 = "arm64"
    else:
        os_type2 = "Linux"
    script = f"Miniconda{py_major}-py{py_version2}_{version}-{os_type2}-{arch2}.sh"
    url = f"https://repo.anaconda.com/miniconda/{script}"
    download(url, output=script)
    subprocess.run(
        ["bash", script, "-bf", "-p", prefix],
        check=True,
    )
    condarc_src = os.path.join(koopa_prefix(), "etc", "conda", "condarc")
    condarc_dst = os.path.join(prefix, ".condarc")
    if os.path.isfile(condarc_src):
        shutil.copy2(condarc_src, condarc_dst)
    conda = os.path.join(prefix, "bin", "conda")
    subprocess.run([conda, "list"], check=True)
    subprocess.run([conda, "info", "--all"], check=True)
