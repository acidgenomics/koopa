"""Install libyaml."""

import subprocess

from koopa.build import app_prefix, make_build
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install libyaml."""
    env = activate_app_deps()
    libtool_prefix = app_prefix("libtool")
    download_extract_cd()
    subprocess_env = env.to_env_dict()
    subprocess_env["ACLOCAL_PATH"] = f"{libtool_prefix}/share/aclocal"
    subprocess.run(["autoupdate"], env=subprocess_env, check=True)
    subprocess.run(
        ["autoreconf", "--force", "--install", "--verbose"],
        env=subprocess_env,
        check=True,
    )
    make_build(conf_args=[f"--prefix={prefix}"], env=env)
