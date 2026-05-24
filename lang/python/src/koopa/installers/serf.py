"""Install serf."""

import os
import subprocess

from koopa.build import app_prefix, locate
from koopa.installers._build_helper import (
    activate_app_deps,
    download_extract_cd,
    remove_static_libs,
)


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install serf."""
    env = activate_app_deps()
    scons = locate("scons")
    zlib_prefix = app_prefix("zlib")
    apr_prefix = app_prefix("apr")
    apr_util_prefix = app_prefix("apr-util")
    openssl_prefix = app_prefix("openssl")
    download_extract_cd()
    with open("SConstruct") as fh:
        text = fh.read()
    text = text.replace(
        "LIBS=[",
        f"CPPPATH=['{zlib_prefix}/include'],\n    LIBPATH=['{zlib_prefix}/lib'],\n    LIBS=[",
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
