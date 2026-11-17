"""Build the pinned Lig release."""

import hashlib
import os
import shutil
import subprocess
import tarfile
import tempfile
from pathlib import Path

from koopa.download import download_with_mirror
from koopa.system import safe_build_env
from koopa.vendor import vendor_config, vendor_pull_priority

_VERSION = "1.4.0"
_SOURCE_SHA256 = "a6d28a0035985160fd0bb23be95dfbccfc2e1b441d94d436ce4e13f5e9812040"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Build the pinned Lig release.

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
        msg = f"lig: installer supports version {_VERSION}, not {version}"
        raise ValueError(msg)
    if vendor_config() is not None and vendor_pull_priority() == "vendor_only":
        msg = "lig: source builds require Cargo registry access; use a koopa binary package"
        raise RuntimeError(msg)
    cargo = shutil.which("cargo")
    if cargo is None:
        msg = "cargo not found"
        raise FileNotFoundError(msg)
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
        env = safe_build_env()
        env["CARGO_HOME"] = os.path.join(tmp, "cargo")
        env["CARGO_NET_GIT_FETCH_WITH_CLI"] = "true"
        env["RUST_BACKTRACE"] = "full"
        subprocess.run(
            [cargo, "install", "--locked", "--path", str(source), "--root", prefix],
            env=env,
            check=True,
        )
