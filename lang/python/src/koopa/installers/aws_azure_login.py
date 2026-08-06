"""Install aws-azure-login.

puppeteer's own postinstall downloader (``node install.js``) has no socket
timeout, so a silently-dropped connection through a corporate proxy (Zscaler)
hangs the install forever. Skip that downloader entirely and pre-seed the
Chromium build ourselves using koopa's ``download()``, which has stall
detection and retries.
"""

import os
import re
import subprocess

from koopa.download import download
from koopa.install import install_node_package
from koopa.installers._args import get_list, get_str, parse_passthrough
from koopa.system import is_macos

_CHROMIUM_HOST = "https://storage.googleapis.com/chromium-browser-snapshots"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install aws-azure-login, then pre-seed puppeteer's bundled Chromium."""
    if not is_macos():
        msg = "aws-azure-login: only macOS is currently supported by this installer."
        raise RuntimeError(msg)
    kwargs = parse_passthrough(passthrough_args)
    extra = get_list(kwargs, "extra_packages")
    install_node_package(
        name=get_str(kwargs, "name", name),
        version=version,
        prefix=prefix,
        extra_packages=extra or None,
        build_env={"PUPPETEER_SKIP_DOWNLOAD": "1"},
    )
    _install_chromium(prefix)


def _install_chromium(prefix: str) -> None:
    """Download and extract puppeteer's pinned Chromium build."""
    puppeteer_dir = os.path.join(
        prefix, "lib", "node_modules", "aws-azure-login", "node_modules", "puppeteer"
    )
    revisions_path = os.path.join(puppeteer_dir, "lib", "cjs", "puppeteer", "revisions.js")
    with open(revisions_path, encoding="utf-8") as fh:
        revisions_src = fh.read()
    match = re.search(r"chromium:\s*'(\d+)'", revisions_src)
    if match is None:
        msg = f"aws-azure-login: could not parse chromium revision from {revisions_path}"
        raise RuntimeError(msg)
    revision = match.group(1)

    url = f"{_CHROMIUM_HOST}/Mac/{revision}/chrome-mac.zip"
    zip_path = download(url, speed_limit=10240, speed_time=30, retry=True)

    dest = os.path.join(puppeteer_dir, ".local-chromium", f"mac-{revision}")
    os.makedirs(dest, exist_ok=True)
    # `ditto` preserves the symlinks and exec bits inside the .app bundle that
    # zipfile.extractall() (koopa.archive.extract) would silently drop.
    subprocess.run(["/usr/bin/ditto", "-x", "-k", zip_path, dest], check=True)
    os.remove(zip_path)

    binary = os.path.join(dest, "chrome-mac", "Chromium.app", "Contents", "MacOS", "Chromium")
    os.chmod(binary, 0o755)
