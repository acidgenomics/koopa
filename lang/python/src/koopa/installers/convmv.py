"""Install convmv."""

import subprocess

from koopa.build import activate_app, locate
from koopa.download import download_with_mirror
from koopa.installers._build_helper import download_extract_cd, extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
    use_mirror: bool = False,
) -> None:
    """Install convmv."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    filename = f"convmv-{version}.tar.gz"
    url = f"https://www.j3e.de/linux/convmv/{filename}"
    if use_mirror:
        tarball = download_with_mirror(url, name, filename)
        extract_cd(tarball)
    else:
        download_extract_cd(url)
    subprocess.run(
        [make, "install", f"PREFIX={prefix}"],
        env=env.to_env_dict(),
        check=True,
    )
