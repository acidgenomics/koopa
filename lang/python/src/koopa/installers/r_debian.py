"""Install R on Debian/Ubuntu from CRAN."""

from __future__ import annotations

import re
import subprocess


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install R on Debian/Ubuntu from CRAN."""
    dep_pkgs = [
        "autoconf",
        "bash",
        "bash-completion",
        "bc",
        "bison",
        "build-essential",
        "bzip2",
        "ca-certificates",
        "coreutils",
        "curl",
        "debhelper",
        "default-jdk",
        "findutils",
        "gdb",
        "gettext",
        "gfortran",
        "git",
        "gnupg",
        "groff-base",
        "less",
        "libblas-dev",
        "libbz2-dev",
        "libcairo2-dev",
        "libcurl4-openssl-dev",
        "libglpk-dev",
        "libjpeg-dev",
        "liblapack-dev",
        "liblzma-dev",
        "libncurses-dev",
        "libncurses5-dev",
        "libpango1.0-dev",
        "libpcre3-dev",
        "libpng-dev",
        "libreadline-dev",
        "libssl-dev",
        "libtiff5-dev",
        "libx11-dev",
        "libxml2-dev",
        "libxt-dev",
        "locales",
        "lsb-release",
        "man-db",
        "mpack",
        "pandoc",
        "python3",
        "python3-venv",
        "subversion",
        "sudo",
        "tcl8.6-dev",
        "texinfo",
        "texlive-base",
        "texlive-extra-utils",
        "texlive-fonts-extra",
        "texlive-fonts-recommended",
        "texlive-latex-base",
        "texlive-latex-extra",
        "texlive-latex-recommended",
        "tk8.6-dev",
        "tzdata",
        "unzip",
        "wget",
        "x11proto-core-dev",
        "xauth",
        "xdg-utils",
        "xfonts-base",
        "xvfb",
        "xz-utils",
        "zlib1g-dev",
    ]
    subprocess.run(
        ["sudo", "apt-get", "install", "-y", *dep_pkgs],
        check=True,
    )
    subprocess.run(
        ["koopa", "debian", "apt-add-r-repo", version],
        check=True,
    )
    pkgs = ["r-base", "r-base-dev"]
    subprocess.run(
        ["sudo", "apt-get", "install", "-y", *pkgs],
        check=True,
    )
    r_bin = "/usr/bin/R"
    result = subprocess.run(
        [r_bin, "--version"],
        capture_output=True,
        text=True,
        check=True,
    )
    match = re.search(r"R version (\d+\.\d+\.\d+)", result.stdout)
    if match:
        actual_version = match.group(1)
        if actual_version != version:
            msg = f"Incorrect R version installed. Expected: {version}. Actual: {actual_version}."
            raise RuntimeError(msg)
    subprocess.run(
        ["koopa", "configure", "r", r_bin],
        check=True,
    )
