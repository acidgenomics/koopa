"""Build Lig with koopa's live theme reload patch."""

import hashlib
import os
import shutil
import subprocess
import tarfile
import tempfile
from pathlib import Path

from koopa.download import download_with_mirror
from koopa.prefix import koopa_prefix
from koopa.system import safe_build_env
from koopa.vendor import vendor_config, vendor_pull_priority

_VERSION = "1.3.0"
_SOURCE_SHA256 = "8ec48d80af8d0a80a8ee2ec0c0e502252833b8aff85b1fe716e6a9d059b0d2b9"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Build the pinned Lig release with live theme reloading.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Unused installer arguments.
    """
    if version != _VERSION:
        msg = f"lig: the live theme patch requires version {_VERSION}, not {version}"
        raise ValueError(msg)
    if vendor_config() is not None and vendor_pull_priority() == "vendor_only":
        msg = "lig: source builds require Cargo registry access; use a koopa binary package"
        raise RuntimeError(msg)
    cargo = shutil.which("cargo")
    if cargo is None:
        msg = "cargo not found"
        raise FileNotFoundError(msg)
    patch = Path(koopa_prefix()) / "etc" / "koopa" / "lig" / f"{version}-theme-reload.patch"
    filename = f"lig-{version}.tar.gz"
    url = f"https://github.com/KevenGoncalves/lig/archive/refs/tags/v{version}.tar.gz"
    with tempfile.TemporaryDirectory(prefix="koopa-lig-") as tmp:
        archive = download_with_mirror(url, name, filename, output=os.path.join(tmp, filename))
        with open(archive, "rb") as fh:
            digest = hashlib.file_digest(fh, "sha256").hexdigest()
        if digest != _SOURCE_SHA256:
            msg = "lig: source archive SHA-256 mismatch"
            raise ValueError(msg)
        with tarfile.open(archive, "r:gz") as tf:
            tf.extractall(tmp, filter="data")
        source = Path(tmp) / f"lig-{version}"
        subprocess.run(["patch", "-p1", "-F", "0", "-i", str(patch)], cwd=source, check=True)
        env = safe_build_env()
        env["CARGO_HOME"] = os.path.join(tmp, "cargo")
        env["CARGO_NET_GIT_FETCH_WITH_CLI"] = "true"
        env["RUST_BACKTRACE"] = "full"
        subprocess.run(
            [cargo, "install", "--locked", "--path", str(source), "--root", prefix],
            env=env,
            check=True,
        )
