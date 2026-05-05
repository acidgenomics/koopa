"""Install asdf."""

import os

from koopa.archive import extract
from koopa.download import download_with_mirror
from koopa.file_ops import ln
from koopa.installers._build_helper import _resolve_src_url


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install asdf."""
    url = _resolve_src_url(name, version)
    filename = os.path.basename(url)
    tarball = download_with_mirror(url, name, filename)
    libexec = os.path.join(prefix, "libexec")
    extract(tarball, libexec)
    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    ln(
        os.path.join(libexec, "bin", "asdf"),
        os.path.join(bin_dir, "asdf"),
    )
