"""Install dash."""

from __future__ import annotations

import os
import platform
import subprocess

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dash."""
    env = activate_app("autoconf", "automake", build_only=True)
    env = activate_app("libedit", env=env)
    url = f"https://git.kernel.org/pub/scm/utils/dash/dash.git/snapshot/dash-{version}.tar.gz"
    download_extract_cd(url)
    conf_args = [
        "--disable-dependency-tracking",
        f"--prefix={prefix}",
        "--with-libedit",
    ]
    if platform.machine() in ("aarch64", "arm64"):
        os.environ["ac_cv_func_stat64"] = "no"
    subprocess_env = env.to_env_dict()
    subprocess.run(["./autogen.sh"], env=subprocess_env, check=True)
    make_build(conf_args=conf_args, env=env)
