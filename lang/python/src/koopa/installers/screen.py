"""Install screen."""

from __future__ import annotations

import subprocess

from koopa.archive import is_valid_archive
from koopa.build import activate_app, make_build
from koopa.download import download
from koopa.installers._build_helper import extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install screen."""
    env = activate_app("autoconf", "automake", build_only=True)
    env = activate_app("libxcrypt", "ncurses", env=env)
    for url in [
        f"https://mirrors.kernel.org/gnu/screen/screen-{version}.tar.gz",
        f"https://ftpmirror.gnu.org/gnu/screen/screen-{version}.tar.gz",
        f"https://ftp.gnu.org/gnu/screen/screen-{version}.tar.gz",
    ]:
        tarball = download(url)
        if is_valid_archive(tarball):
            break
    extract_cd(tarball)
    subprocess.run(
        ["./autogen.sh"],
        env=env.to_env_dict(),
        check=True,
    )
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
