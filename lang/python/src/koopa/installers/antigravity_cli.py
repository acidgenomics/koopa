"""Install antigravity-cli."""

import hashlib
import os
import shutil
import stat
import subprocess
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.io import import_app_json
from koopa.system import arch2

# GCS base URL for content-addressed release artifacts.
_GCS_BASE = "https://storage.googleapis.com/antigravity-public/antigravity-cli"

# (dir, filename) keyed by "<os>_<arch2>" platform string.
_PLATFORM_ASSET: dict[str, tuple[str, str]] = {
    "darwin_arm64": ("darwin-arm", "cli_mac_arm64.tar.gz"),
    "darwin_amd64": ("darwin-x64", "cli_mac_x64.tar.gz"),
    "linux_amd64": ("linux-x64", "cli_linux_x64.tar.gz"),
    "linux_arm64": ("linux-arm", "cli_linux_arm64.tar.gz"),
}


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install antigravity-cli.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Extra ``--flag=value`` arguments derived from the app's
        ``installer_args`` entry in app.json.
    """
    os_key = "darwin" if sys.platform == "darwin" else "linux"
    machine = arch2()
    platform = f"{os_key}_{machine}"

    asset = _PLATFORM_ASSET.get(platform)
    if asset is None:
        msg = f"antigravity-cli: unsupported platform ({platform})"
        raise RuntimeError(msg)
    asset_dir, asset_file = asset

    entry = import_app_json().get(name, {})
    build_id: str = entry.get("build_id", "")
    sha512_map: dict[str, str] = entry.get("sha512", {})
    expected_sha512 = sha512_map.get(platform, "")
    if not build_id or not expected_sha512:
        msg = f"antigravity-cli: missing build_id or sha512 for {platform} in app.json"
        raise RuntimeError(msg)

    url = f"{_GCS_BASE}/{version}-{build_id}/{asset_dir}/{asset_file}"
    tarball = download(url)

    # Verify SHA512 checksum before touching the prefix.
    digest = hashlib.sha512()
    with open(tarball, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            digest.update(chunk)
    actual = digest.hexdigest()
    if actual != expected_sha512:
        msg = (
            f"antigravity-cli: SHA512 mismatch for {asset_file}\n"
            f"  expected: {expected_sha512}\n"
            f"  actual:   {actual}"
        )
        raise RuntimeError(msg)

    # Extract into a staging dir; the tarball contains a bare binary named
    # 'antigravity'.  Rename it to 'agy' in the final bin dir.
    staging = f"{prefix}_staging"
    os.makedirs(staging, exist_ok=True)
    extract(tarball, staging)

    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    extracted = os.path.join(staging, "antigravity")
    dest = os.path.join(bin_dir, "agy")
    shutil.move(extracted, dest)
    os.chmod(dest, os.stat(dest).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    # Clear macOS Gatekeeper quarantine; tolerate absence.
    if sys.platform == "darwin":
        subprocess.run(
            ["xattr", "-d", "com.apple.quarantine", dest],
            check=False,
            capture_output=True,
        )

    # Clean up staging dir.
    shutil.rmtree(staging, ignore_errors=True)
