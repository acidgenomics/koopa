"""Install ca-certificates."""

import os
import shutil

from koopa.download import download


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ca-certificates.

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
    filename = f"cacert-{version}.pem"
    url = f"https://curl.se/ca/{filename}"
    tarball = download(url)
    dest_dir = os.path.join(prefix, "share", "ca-certificates")
    os.makedirs(dest_dir, exist_ok=True)
    shutil.copy2(tarball, os.path.join(dest_dir, "cacert.pem"))
