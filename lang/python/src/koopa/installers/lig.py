"""Install Lig from its verified release archive, with a Cargo fallback."""

import hashlib
import os
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

from koopa.download import download_with_mirror
from koopa.installers import _rust_pkg
from koopa.system import arch2
from koopa.vendor import vendor_config, vendor_pull_priority

_REPO = "https://github.com/KevenGoncalves/lig"
_TRIPLES = {
    ("darwin", "arm64"): "aarch64-apple-darwin",
    ("linux", "amd64"): "x86_64-unknown-linux-musl",
    ("linux", "arm64"): "aarch64-unknown-linux-musl",
}


def _platform_triple() -> str:
    """Resolve a supported release target.

    Returns
    -------
    str
        Release target triple for the current platform.
    """
    platform = (sys.platform, arch2())
    triple = _TRIPLES.get(platform)
    if triple is None:
        msg = f"lig: unsupported platform {platform[0]}/{platform[1]}"
        raise RuntimeError(msg)
    return triple


def _verify_archive(archive: str, checksum: str, filename: str) -> None:
    """Check the sidecar format and the archive digest.

    Parameters
    ----------
    archive : str
        Path to the downloaded archive.
    checksum : str
        Path to the SHA-256 sidecar.
    filename : str
        Expected archive filename in the sidecar.
    """
    fields = Path(checksum).read_text(encoding="utf-8").split()
    if (
        len(fields) != 2
        or not re.fullmatch(r"[a-fA-F0-9]{64}", fields[0])
        or fields[1].removeprefix("*") != filename
    ):
        msg = f"lig: malformed SHA-256 sidecar for {filename}"
        raise ValueError(msg)
    with open(archive, "rb") as fh:
        actual = hashlib.file_digest(fh, "sha256").hexdigest()
    if actual != fields[0].lower():
        msg = f"lig: SHA-256 mismatch for {filename}"
        raise ValueError(msg)


def _install_archive(archive: str, directory: str, prefix: str) -> None:
    """Copy only the expected regular binary out of the verified archive.

    Parameters
    ----------
    archive : str
        Path to the verified archive.
    directory : str
        Expected directory containing the binary in the archive.
    prefix : str
        Installation prefix directory.
    """
    binary_name = f"{directory}/lig"
    with tarfile.open(archive, "r:gz") as tf:
        matches = [member for member in tf.getmembers() if member.name == binary_name]
        if len(matches) != 1 or not matches[0].isfile() or matches[0].size == 0:
            msg = f"lig: expected a regular binary at {binary_name}"
            raise ValueError(msg)
        source = tf.extractfile(matches[0])
        if source is None:
            msg = f"lig: cannot read {binary_name}"
            raise ValueError(msg)
        dest = Path(prefix) / "bin" / "lig"
        dest.parent.mkdir(parents=True, exist_ok=True)
        with source, dest.open("wb") as out:
            shutil.copyfileobj(source, out)
        dest.chmod(0o755)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install Lig from an upstream archive or build it from Git.

    Parameters
    ----------
    name : str
        Application name.
    version : str
        Application version.
    prefix : str
        Installation prefix directory.
    passthrough_args : list[str] | None, optional
        Cargo fallback arguments from the app registry.
    """
    directory = f"lig-{version}-{_platform_triple()}"
    filename = f"{directory}.tar.gz"
    url = f"{_REPO}/releases/download/v{version}/{filename}"
    with tempfile.TemporaryDirectory(prefix="koopa-lig-") as tmp:
        try:
            archive = download_with_mirror(
                url, name, filename, output=os.path.join(tmp, filename), validate_archive=False
            )
            checksum = download_with_mirror(
                f"{url}.sha256",
                name,
                f"{filename}.sha256",
                output=os.path.join(tmp, f"{filename}.sha256"),
            )
        except (OSError, subprocess.CalledProcessError) as exc:
            if vendor_config() is not None and vendor_pull_priority() == "vendor_only":
                raise
            print(f"lig: release download failed ({exc}); building from source.", file=sys.stderr)
            _rust_pkg.main(
                name=name, version=version, prefix=prefix, passthrough_args=passthrough_args
            )
            return
        _verify_archive(archive, checksum, filename)
        _install_archive(archive, directory, prefix)
