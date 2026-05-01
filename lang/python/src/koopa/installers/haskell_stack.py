"""Install haskell-stack."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install haskell-stack."""
    machine = arch()
    if sys.platform == "darwin":
        os_id = "osx"
        if machine in ("aarch64", "arm64"):
            arch_id = "aarch64"
        else:
            arch_id = "x86_64"
    else:
        os_id = "linux"
        if machine in ("aarch64", "arm64"):
            arch_id = "aarch64"
        else:
            arch_id = "x86_64"
    url = (
        f"https://github.com/commercialhaskell/stack/releases/download/"
        f"v{version}/stack-{version}-{os_id}-{arch_id}.tar.gz"
    )
    tarball = download(url)
    extract(tarball, "src")
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    stack_bin = os.path.join("src", "stack")
    if not os.path.isfile(stack_bin):
        for entry in os.listdir("src"):
            candidate = os.path.join("src", entry, "stack")
            if os.path.isfile(candidate):
                stack_bin = candidate
                break
    shutil.copy2(stack_bin, os.path.join(bin_dir, "stack"))
    os.chmod(os.path.join(bin_dir, "stack"), 0o755)
    jobs = os.cpu_count() or 1
    stack = os.path.join(bin_dir, "stack")
    env = os.environ.copy()
    env["STACK_ROOT"] = os.path.join(os.getcwd(), "stack-root")
    subprocess.run(
        [stack, "setup", f"-j{jobs}", "--verbose"],
        env=env,
        check=True,
    )
