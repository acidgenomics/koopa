"""Install dash."""

import os
import platform
import subprocess

from koopa.build import make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install dash."""
    env = activate_app_deps()
    download_extract_cd()
    conf_args = [
        "--disable-dependency-tracking",
        f"--prefix={prefix}",
        "--with-libedit",
    ]
    if platform.machine() in ("aarch64", "arm64"):
        os.environ["ac_cv_func_stat64"] = "no"  # noqa: SIM112
    subprocess_env = env.to_env_dict()
    subprocess.run(["./autogen.sh"], env=subprocess_env, check=True)
    make_build(conf_args=conf_args, env=env)
