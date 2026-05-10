"""Install xxhash."""

import subprocess

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install xxhash."""
    env = activate_app_deps()
    make = locate("make")
    download_extract_cd()
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=env.to_env_dict(),
        check=True,
    )
    remove_static_libs(prefix)
