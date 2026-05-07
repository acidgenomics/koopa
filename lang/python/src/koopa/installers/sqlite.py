"""Install sqlite."""

import os
import subprocess

from koopa.build import activate_app, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install sqlite."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "readline", env=env)
    download_extract_cd()
    # SQLite >= 3.53 uses autosetup with proj.tcl which requires Tcl 8.6
    # (tailcall). macOS ships Tcl 8.5 at /usr/bin/tclsh which passes the
    # autosetup version check but fails at runtime. Pre-build the bundled
    # jimsh0 interpreter so autosetup-find-tclsh picks it up first.
    jimsh0_src = os.path.join("autosetup", "jimsh0.c")
    if os.path.isfile(jimsh0_src) and not os.path.isfile("jimsh0"):
        subprocess.run(["cc", "-o", "jimsh0", jimsh0_src], check=True)
    cppflags = " ".join(
        [
            "-DSQLITE_ENABLE_API_ARMOR=1",
            "-DSQLITE_ENABLE_COLUMN_METADATA=1",
            "-DSQLITE_ENABLE_DBSTAT_VTAB=1",
            "-DSQLITE_ENABLE_FTS3=1",
            "-DSQLITE_ENABLE_FTS3_PARENTHESIS=1",
            "-DSQLITE_ENABLE_FTS5=1",
            "-DSQLITE_ENABLE_GEOPOLY=1",
            "-DSQLITE_ENABLE_JSON1=1",
            "-DSQLITE_ENABLE_MEMORY_MANAGEMENT=1",
            "-DSQLITE_ENABLE_RTREE=1",
            "-DSQLITE_ENABLE_SESSION=1",
            "-DSQLITE_ENABLE_STAT4=1",
            "-DSQLITE_ENABLE_UNLOCK_NOTIFY=1",
            "-DSQLITE_MAX_VARIABLE_NUMBER=250000",
            "-DSQLITE_USE_URI=1",
        ]
    )
    existing = os.environ.get("CPPFLAGS", "")
    os.environ["CPPFLAGS"] = f"{cppflags} {existing}".strip()
    make_build(
        conf_args=[
            "--disable-editline",
            "--disable-static",
            "--enable-readline",
            "--enable-session",
            f"--prefix={prefix}",
        ],
        env=env,
    )
