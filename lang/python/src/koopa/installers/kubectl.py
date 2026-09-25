"""Install kubectl."""

import hashlib
import os
import stat
import subprocess
import sys

from koopa.download import download
from koopa.system import arch2

# kubectl has no conda-forge feedstock (confirmed live 2026-09-25 against
# api.anaconda.org -- conda-forge ships 'kubectl-krew', a plugin manager, but
# not kubectl itself), so this app cannot use the 'conda-package' installer
# every sibling Kubernetes CLI in app.json (e.g. k9s) uses. Download the
# official pre-built static binary directly from Kubernetes' own release CDN
# instead, verified against the '.sha256' file Kubernetes publishes alongside
# every binary -- no per-version checksum needs to be hardcoded in app.json.
_BASE_URL = "https://dl.k8s.io/release"


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install kubectl.

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
    bin_url = f"{_BASE_URL}/v{version}/bin/{os_key}/{machine}/kubectl"
    sha_url = f"{bin_url}.sha256"

    binary = download(bin_url)
    checksum_file = download(sha_url)
    with open(checksum_file) as fh:
        expected = fh.read().strip()

    digest = hashlib.sha256()
    with open(binary, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            digest.update(chunk)
    actual = digest.hexdigest()
    if actual != expected:
        msg = f"kubectl: SHA256 mismatch\n  expected: {expected}\n  actual:   {actual}"
        raise RuntimeError(msg)

    bin_dir = os.path.join(prefix, "bin")
    os.makedirs(bin_dir, exist_ok=True)
    dest = os.path.join(bin_dir, "kubectl")
    os.replace(binary, dest)
    os.chmod(dest, os.stat(dest).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    # Clear macOS Gatekeeper quarantine; tolerate absence.
    if sys.platform == "darwin":
        subprocess.run(
            ["xattr", "-d", "com.apple.quarantine", dest],
            check=False,
            capture_output=True,
        )
