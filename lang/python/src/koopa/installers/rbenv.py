"""Install rbenv."""

import os

from koopa.archive import extract
from koopa.download import download, download_with_mirror
from koopa.installers._build_helper import _resolve_src_url


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install rbenv."""
    url = _resolve_src_url(name, version)
    filename = os.path.basename(url)
    tarball = download_with_mirror(url, name, filename)
    extract(tarball, prefix)
    plugins_dir = os.path.join(prefix, "plugins")
    os.makedirs(plugins_dir, exist_ok=True)
    rb_url = "https://github.com/rbenv/ruby-build/archive/v20220713.tar.gz"
    rb_tarball = download(rb_url)
    extract(rb_tarball, os.path.join(plugins_dir, "ruby-build"))
