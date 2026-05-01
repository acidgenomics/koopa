"""Install serf."""

from __future__ import annotations

import os
import subprocess

from koopa.build import activate_app, app_prefix, locate
from koopa.installers._build_helper import download_extract_cd, remove_static_libs


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install serf."""
    env = activate_app("pkg-config", "scons", build_only=True)
    env = activate_app("zlib", "apr", "apr-util", "openssl", env=env)
    scons = locate("scons")
    zlib_prefix = app_prefix("zlib")
    apr_prefix = app_prefix("apr")
    apr_util_prefix = app_prefix("apr-util")
    openssl_prefix = app_prefix("openssl")
    url = f"https://archive.apache.org/dist/serf/serf-{version}.tar.bz2"
    download_extract_cd(url)
    with open("SConstruct") as fh:
        text = fh.read()
    text = text.replace(
        "LIBS=[",
        f"CPPPATH=['{zlib_prefix}/include'],\n"
        f"    LIBPATH=['{zlib_prefix}/lib'],\n"
        f"    LIBS=[",
        1,
    )
    with open("SConstruct", "w") as fh:
        fh.write(text)
    subprocess_env = env.to_env_dict()
    jobs = os.cpu_count() or 1
    subprocess.run(
        [
            scons,
            f"PREFIX={prefix}",
            f"APR={apr_prefix}",
            f"APU={apr_util_prefix}",
            f"OPENSSL={openssl_prefix}",
            f"-j{jobs}",
        ],
        env=subprocess_env,
        check=True,
    )
    subprocess.run(
        [
            scons,
            f"PREFIX={prefix}",
            f"APR={apr_prefix}",
            f"APU={apr_util_prefix}",
            f"OPENSSL={openssl_prefix}",
            "install",
        ],
        env=subprocess_env,
        check=True,
    )
    remove_static_libs(prefix)
