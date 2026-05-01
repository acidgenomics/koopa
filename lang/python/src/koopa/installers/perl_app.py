"""Install perl."""

from __future__ import annotations

import os
import subprocess
import sys

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd
from koopa.version import major_version


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install perl."""
    env = activate_app("make", build_only=True)
    make = locate("make")
    jobs = os.cpu_count() or 1
    if sys.platform != "darwin":
        jobs = 1
    man1dir = os.path.join(prefix, "share", "man", "man1")
    man3dir = os.path.join(prefix, "share", "man", "man3")
    sysman = os.path.join(prefix, "share", "man", "man1")
    os.makedirs(man1dir, exist_ok=True)
    os.makedirs(man3dir, exist_ok=True)
    src_maj_min_ver = f"{major_version(version)}.0"
    url = f"https://www.cpan.org/src/{src_maj_min_ver}/perl-{version}.tar.gz"
    download_extract_cd(url)
    subprocess_env = env.to_env_dict()
    conf_args = [
        "-d",
        "-e",
        "-s",
        "-Dcf_by=koopa",
        "-Dcf_email=koopa",
        "-Dinc_version_list=none",
        f"-Dman1dir={man1dir}",
        f"-Dman3dir={man3dir}",
        "-Dmydomain=.koopa",
        "-Dmyhostname=koopa",
        "-Dperladmin=koopa",
        f"-Dprefix={prefix}",
        f"-Dsysman={sysman}",
        "-Duselargefiles",
        "-Duseshrplib",
        "-Dusethreads",
    ]
    subprocess.run(
        ["./Configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "VERBOSE=1", f"--jobs={jobs}"],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
