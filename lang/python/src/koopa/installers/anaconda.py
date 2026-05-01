"""Install anaconda."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.download import download
from koopa.prefix import koopa_prefix
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install anaconda."""
    machine = arch()
    arch2 = machine
    if sys.platform == "darwin":
        os_type2 = "MacOSX"
        if machine == "aarch64":
            arch2 = "arm64"
    else:
        os_type2 = "Linux"
    script = f"Anaconda3-{version}-{os_type2}-{arch2}.sh"
    url = f"https://repo.anaconda.com/archive/{script}"
    download(url, output=script)
    subprocess.run(
        ["bash", script, "-bf", "-p", prefix],
        check=True,
    )
    condarc_src = os.path.join(koopa_prefix(), "etc", "conda", "condarc")
    condarc_dst = os.path.join(prefix, ".condarc")
    if os.path.isfile(condarc_src):
        shutil.copy2(condarc_src, condarc_dst)
