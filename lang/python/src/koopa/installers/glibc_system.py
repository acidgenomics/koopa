"""Install glibc."""

import subprocess

from koopa.download import download
from koopa.file_ops import cp


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install glibc.

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
    gh_url = f"https://github.com/sgerrand/alpine-pkg-glibc/releases/download/{version}"
    key_url = "https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"
    key_file = download(key_url)
    cp(key_file, "/etc/apk/keys/sgerrand.rsa.pub", sudo=True)
    packages = [
        f"glibc-{version}.apk",
        f"glibc-bin-{version}.apk",
        f"glibc-i18n-{version}.apk",
    ]
    for pkg_name in packages:
        url = f"{gh_url}/{pkg_name}"
        apk_file = download(url)
        subprocess.run(
            ["sudo", "apk", "add", "--allow-untrusted", apk_file],
            check=True,
        )
    subprocess.run(
        [
            "sudo",
            "/usr/glibc-compat/bin/localedef",
            "-i",
            "en_US",
            "-f",
            "UTF-8",
            "en_US.UTF-8",
        ],
        check=False,
    )
