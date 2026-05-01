"""Install rust."""

from __future__ import annotations

import os
import shutil
import stat
import subprocess

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install rust via rustup."""
    tmp_prefix = "rustup"
    cargo_home = tmp_prefix
    rustup_home = tmp_prefix
    os.makedirs(rustup_home, exist_ok=True)
    env = os.environ.copy()
    env["CARGO_HOME"] = cargo_home
    env["RUSTUP_HOME"] = rustup_home
    env["RUSTUP_INIT_SKIP_PATH_CHECK"] = "yes"
    script = download("https://sh.rustup.rs", output="rustup.sh")
    os.chmod(script, os.stat(script).st_mode | stat.S_IEXEC)
    subprocess.run(
        [f"./{script}", "-v", "-y", "--default-toolchain", "none", "--no-modify-path"],
        env=env,
        check=True,
    )
    rustup = os.path.join(tmp_prefix, "bin", "rustup")
    env["PATH"] = os.path.realpath(os.path.join(tmp_prefix, "bin")) + ":" + env.get("PATH", "")
    subprocess.run(
        [rustup, "--verbose", "install", version],
        env=env,
        check=True,
    )
    subprocess.run(
        [rustup, "--verbose", "default", version],
        env=env,
        check=True,
    )
    result = subprocess.run(
        [rustup, "toolchain", "list"],
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )
    toolchain = result.stdout.strip().split("\n")[0].split()[0]
    toolchain_prefix = os.path.join(tmp_prefix, "toolchains", toolchain)
    shutil.copytree(toolchain_prefix, prefix, dirs_exist_ok=True)
