"""Install Apptainer."""

from __future__ import annotations

import os
import subprocess

from koopa.archive import extract
from koopa.build import activate_app
from koopa.download import download
from koopa.file_ops import chmod


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Apptainer."""
    env = activate_app("go", "make", "pkg-config", build_only=True)
    subprocess_env = env.to_env_dict()
    gocache = os.path.join(os.getcwd(), "gocache")
    gopath = os.path.join(os.getcwd(), "go")
    os.makedirs(gocache, exist_ok=True)
    os.makedirs(gopath, exist_ok=True)
    subprocess_env["GOCACHE"] = gocache
    subprocess_env["GOPATH"] = gopath
    url = f"https://github.com/apptainer/apptainer/archive/refs/tags/v{version}.tar.gz"
    tarball = download(url)
    extract(tarball, "src")
    os.chdir("src")
    if not os.path.isfile("VERSION"):
        with open("VERSION", "w") as f:
            f.write(version + "\n")
    conf_args = [
        f"--prefix={prefix}",
        "--without-suid",
        "-P",
        "release-stripped",
        "-v",
    ]
    subprocess.run(
        ["./mconfig", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", "-C", "builddir"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        ["make", "-C", "builddir", "install"],
        env=subprocess_env,
        check=True,
    )
    chmod(gopath, "u+rw", recursive=True)
