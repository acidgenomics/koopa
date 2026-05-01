"""Install haskell-ghcup."""

from __future__ import annotations

import os
import shutil
import stat
import subprocess

from koopa.build import activate_app
from koopa.download import download
from koopa.file_ops import ln


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install haskell-ghcup."""
    env = activate_app("curl", build_only=True)
    build_prefix = os.path.join(os.getcwd(), "ghcup-build")
    os.makedirs(build_prefix, exist_ok=True)
    subprocess_env = env.to_env_dict()
    subprocess_env["BOOTSTRAP_HASKELL_NONINTERACTIVE"] = "1"
    subprocess_env["BOOTSTRAP_HASKELL_MINIMAL"] = "1"
    subprocess_env["BOOTSTRAP_HASKELL_NO_UPGRADE"] = "1"
    subprocess_env["GHCUP_INSTALL_BASE_PREFIX"] = build_prefix
    download(
        f"https://github.com/haskell/ghcup-hs/archive/v{version}.tar.gz",
        output="ghcup.tar.gz",
    )
    bootstrap = download(
        "https://www.haskell.org/ghcup/sh/bootstrap-haskell",
        output="bootstrap-haskell",
    )
    os.chmod(bootstrap, os.stat(bootstrap).st_mode | stat.S_IEXEC)
    subprocess.run(
        ["bash", bootstrap],
        env=subprocess_env,
        check=True,
    )
    ghcup_dir = os.path.join(build_prefix, ".ghcup")
    libexec = os.path.join(prefix, "libexec")
    if os.path.isdir(ghcup_dir):
        shutil.copytree(ghcup_dir, libexec, dirs_exist_ok=True)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    ln(os.path.join(libexec, "bin"), os.path.join(prefix, "bin"))
