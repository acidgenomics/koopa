"""Install readline."""

from __future__ import annotations

import os
import re
import subprocess

from koopa.build import activate_app, locate
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install readline."""
    env = activate_app("make", "pkg-config", build_only=True)
    env = activate_app("ncurses", env=env)
    make = locate("make")
    pkg_config = locate("pkg-config")
    gnu_mirror = "https://mirrors.kernel.org/gnu"
    url = f"{gnu_mirror}/readline/readline-{version}.tar.gz"
    download_extract_cd(url)
    with open("readline.pc.in") as fh:
        text = fh.read()
    text = re.sub(r"^(Requires\.private: .*)$", r"# \1", text, flags=re.MULTILINE)
    with open("readline.pc.in", "w") as fh:
        fh.write(text)
    subprocess_env = env.to_env_dict()
    ncurses_libs = subprocess.run(
        [pkg_config, "--libs", "ncurses"],
        capture_output=True,
        text=True,
        check=True,
        env=subprocess_env,
    ).stdout.strip()
    conf_args = [
        "--disable-static",
        "--enable-shared",
        f"--prefix={prefix}",
        "--with-curses",
    ]
    jobs = os.cpu_count() or 1
    subprocess.run(
        ["./configure", *conf_args],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            f"SHLIB_LIBS={ncurses_libs}",
            "VERBOSE=1",
            f"--jobs={jobs}",
        ],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            make,
            f"SHLIB_LIBS={ncurses_libs}",
            "VERBOSE=1",
            "install",
        ],
        env=subprocess_env,
        check=True,
    )
