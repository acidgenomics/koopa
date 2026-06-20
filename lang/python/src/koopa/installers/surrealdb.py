"""Install surrealdb."""

import os
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch2


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install surrealdb."""
    machine = arch2()
    if sys.platform == "darwin":
        platform_slug = f"darwin-{machine}"
    else:
        platform_slug = f"linux-{machine}"
    url = (
        f"https://github.com/surrealdb/surrealdb/releases/download/"
        f"v{version}/surreal-v{version}.{platform_slug}.tgz"
    )
    tarball = download(url)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    extract(tarball, bin_dir)
