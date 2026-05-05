"""Install screen."""

import os
import subprocess

from koopa.build import activate_app, make_build
from koopa.download import download_with_mirror
from koopa.installers._build_helper import _resolve_src_url, extract_cd


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
    url = _resolve_src_url(name, version)
    filename = os.path.basename(url)
    tarball = download_with_mirror(url, name, filename)
    extract_cd(tarball)
    subprocess.run(
        ["./autogen.sh"],
        env=env.to_env_dict(),
        check=True,
    )
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
