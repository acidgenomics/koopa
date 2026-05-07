"""Install sqlite."""

import os

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
