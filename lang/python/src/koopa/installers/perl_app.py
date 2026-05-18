"""Install perl."""

import os
import subprocess
import sys

from koopa.build import locate
from koopa.installers._build_helper import activate_app_deps, download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install perl."""
    env = activate_app_deps()
    make = locate("make")
    jobs = os.cpu_count() or 1
    if sys.platform != "darwin":
        jobs = 1
    man1dir = os.path.join(prefix, "share", "man", "man1")
    man3dir = os.path.join(prefix, "share", "man", "man3")
    sysman = os.path.join(prefix, "share", "man", "man1")
    os.makedirs(man1dir, exist_ok=True)
    os.makedirs(man3dir, exist_ok=True)
    download_extract_cd()
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
        [
            make,
            *(["VERBOSE=1"] if os.environ.get("KOOPA_VERBOSE") == "1" else []),
            f"--jobs={jobs}",
        ],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [make, "install"],
        env=subprocess_env,
        check=True,
    )
