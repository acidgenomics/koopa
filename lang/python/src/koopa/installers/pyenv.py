"""Install pyenv."""

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
    """Install pyenv."""
    url = _resolve_src_url(name, version)
    filename = os.path.basename(url)
    tarball = download_with_mirror(url, name, filename)
    extract(tarball, prefix)
    plugins_dir = os.path.join(prefix, "plugins")
    os.makedirs(plugins_dir, exist_ok=True)
    for plugin_name, plugin_ver, plugin_repo, *url_override in [
        ("pyenv-multiuser", "1.0.7", "macdub/pyenv-multiuser", "https://github.com/macdub/pyenv-multiuser/archive/refs/tags/1.0.7.tar.gz"),
        ("pyenv-virtualenv", "1.4.0", "pyenv/pyenv-virtualenv"),
    ]:
        purl = url_override[0] if url_override else f"https://github.com/{plugin_repo}/archive/v{plugin_ver}.tar.gz"
        ptarball = download(purl)
        extract(ptarball, os.path.join(plugins_dir, plugin_name))
    for d in ("shims", "versions"):
        os.makedirs(os.path.join(prefix, d), mode=0o777, exist_ok=True)
