"""Install ldc."""

from __future__ import annotations

import os
import stat
import subprocess

from koopa.build import activate_app
from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ldc."""
    env = activate_app("gnupg", "libarchive", "xz", build_only=True)
    script = download(
        "https://dlang.org/install.sh",
        output="dlang-install.sh",
    )
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    subprocess_env = env.to_env_dict()
    subprocess_env["DLANG_INSTALL_PATH"] = prefix
    subprocess.run(
        [f"./{script}", f"ldc-{version}", "--path", prefix],
        env=subprocess_env,
        check=True,
    )
