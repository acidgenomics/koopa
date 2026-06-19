"""Install antigravity-cli."""

import hashlib
import os
import shutil
import stat
import subprocess
import sys

from koopa.archive import extract
from koopa.download import download
from koopa.system import arch2

# GCS base URL for content-addressed release artifacts.
_GCS_BASE = "https://storage.googleapis.com/antigravity-public/antigravity-cli"

# Per-version manifest data.  When bumping the version in app.json, fetch the
# new platform manifests from:
#   https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests/<platform>.json
# and update _BUILD_ID and _SHA512 together.
_VERSION = "1.0.10"
_BUILD_ID = "6349723456634880"

# (dir, filename, sha512) keyed by (os, arch2()) output.
_ASSETS: dict[tuple[str, str], tuple[str, str, str]] = {
    ("darwin", "arm64"): (
        "darwin-arm",
        "cli_mac_arm64.tar.gz",
        "fef05612a2a8f2934301b7b8737b4356134d34acddf886046e0d4d7e4577c00717a8c11f8d84f958d9889b874fc3ee4756ee48ecba2295623185705fc3e90667",
    ),
    ("darwin", "amd64"): (
        "darwin-x64",
        "cli_mac_x64.tar.gz",
        "a54367c0978d1e1330eecf5486398cd4c6b90d7fcd382ddda5afcfc698c063d6e27487e61fd27f223974cfd7ce35abca489b2c145d0f88e7188d2b1889e24760",
    ),
    ("linux", "amd64"): (
        "linux-x64",
        "cli_linux_x64.tar.gz",
        "45782840f8ce14207ec9b8b962e76e64f0e74e7920000f176180f7204e0f89e61c0e475c9a2b4859cc90f08c214848b9d90ac1c344ef987f796e276820078df1",
    ),
    ("linux", "arm64"): (
        "linux-arm",
        "cli_linux_arm64.tar.gz",
        "95edc5fe6c3b45bbaba7683e748c7eaea5f1950f64eecf083cd53f3b41961fcf13fdab68c64d702d7e5b749c63dc6385c5b0159a85edc6ed12a9d1a323e61ee0",
    ),
}


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install antigravity-cli."""
    os_key = "darwin" if sys.platform == "darwin" else "linux"
    machine = arch2()
    asset = _ASSETS.get((os_key, machine))
    if asset is None:
        msg = f"antigravity-cli: unsupported platform ({os_key}, {machine})"
        raise RuntimeError(msg)
    asset_dir, asset_file, expected_sha512 = asset

    if version != _VERSION:
        print(
            f"Warning: app.json version '{version}' does not match the pinned "
            f"installer version '{_VERSION}'. Update antigravity_cli.py when "
            "bumping the version.",
            file=sys.stderr,
        )

    url = f"{_GCS_BASE}/{_VERSION}-{_BUILD_ID}/{asset_dir}/{asset_file}"
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
