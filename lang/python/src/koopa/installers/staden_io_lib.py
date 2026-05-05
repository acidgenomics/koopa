"""Install staden-io-lib."""

import sys

from koopa.build import activate_app, app_prefix, make_build
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install staden-io-lib."""
    deps = ["curl", "libdeflate", "xz", "zlib", "zstd"]
    if sys.platform != "darwin":
        deps.append("bzip2")
    env = activate_app(*deps, env=None)
    curl_prefix = app_prefix("curl")
    libdeflate_prefix = app_prefix("libdeflate")
    zlib_prefix = app_prefix("zlib")
    zstd_prefix = app_prefix("zstd")
    download_extract_cd()
    make_build(
        conf_args=[
            "--disable-dependency-tracking",
            "--disable-silent-rules",
            "--disable-static",
            "--enable-shared",
            f"--prefix={prefix}",
            f"--with-libcurl={curl_prefix}",
            f"--with-libdeflate={libdeflate_prefix}",
            f"--with-zlib={zlib_prefix}",
            f"--with-zstd={zstd_prefix}",
        ],
        env=env,
    )
