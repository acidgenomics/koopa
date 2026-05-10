"""Install neofetch."""

import subprocess

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install neofetch."""
    env = activate_app_deps()
    make = locate("make")
    download_extract_cd()
    subprocess.run(
        [make, f"PREFIX={prefix}", "install"],
        env=env.to_env_dict(),
        check=True,
    )
