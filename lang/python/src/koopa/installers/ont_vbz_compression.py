"""Install ont-vbz-compression."""

from __future__ import annotations

from koopa.archive import extract
from koopa.build import activate_app, app_prefix, cmake_build, shared_ext
from koopa.download import download
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install ont-vbz-compression."""
    env = activate_app("pkg-config", build_only=True)
    env = activate_app("zlib", "zstd", "hdf5", env=env)
    zstd_prefix = app_prefix("zstd")
    ext = shared_ext()
    url = f"https://github.com/nanoporetech/vbz_compression/archive/v{version}.tar.gz"
    download_extract_cd(url)
    svb_url = "https://github.com/lemire/streamvbyte/archive/v0.5.2.tar.gz"
    svb_tarball = download(svb_url)
    extract(svb_tarball, "third_party/streamvbyte")
    cmake_build(
        prefix=prefix,
        args=[
            "-DENABLE_CONAN=OFF",
            "-DENABLE_PERF_TESTING=OFF",
            "-DENABLE_PYTHON=OFF",
            f"-DZSTD_INCLUDE_DIR={zstd_prefix}/include",
            f"-DZSTD_LIBRARY={zstd_prefix}/lib/libzstd.{ext}",
        ],
        env=env,
    )
