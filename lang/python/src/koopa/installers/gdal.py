"""Install gdal."""

from __future__ import annotations

from koopa.build import (
    activate_app,
    app_prefix,
    cmake_build,
    shared_ext,
)
from koopa.installers._build_helper import download_extract_cd


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install gdal."""
    env = activate_app("pkg-config", "python", build_only=True)
    env = activate_app(
        "zlib",
        "zstd",
        "bison",
        "expat",
        "geos",
        "hdf5",
        "libdeflate",
        "libjpeg-turbo",
        "libpng",
        "libtiff",
        "libxml2",
        "lz4",
        "openjpeg",
        "openssl",
        "pcre2",
        "sqlite",
        "xz",
        "libssh2",
        "curl",
        "proj",
        env=env,
    )
    curl_prefix = app_prefix("curl")
    geos_prefix = app_prefix("geos")
    hdf5_prefix = app_prefix("hdf5")
    libjpeg_prefix = app_prefix("libjpeg-turbo")
    libpng_prefix = app_prefix("libpng")
    libtiff_prefix = app_prefix("libtiff")
    libxml2_prefix = app_prefix("libxml2")
    openjpeg_prefix = app_prefix("openjpeg")
    openssl_prefix = app_prefix("openssl")
    pcre2_prefix = app_prefix("pcre2")
    proj_prefix = app_prefix("proj")
    sqlite_prefix = app_prefix("sqlite")
    zlib_prefix = app_prefix("zlib")
    ext = shared_ext()
    url = f"https://github.com/OSGeo/gdal/releases/download/v{version}/gdal-{version}.tar.gz"
    download_extract_cd(url)
    cmake_build(
        prefix=prefix,
        args=[
            "-DBUILD_APPS=ON",
            "-DBUILD_PYTHON_BINDINGS=OFF",
            "-DBUILD_TESTING=OFF",
            f"-DCURL_INCLUDE_DIR={curl_prefix}/include",
            f"-DCURL_LIBRARY={curl_prefix}/lib/libcurl.{ext}",
            "-DGDAL_BUILD_OPTIONAL_DRIVERS=OFF",
            "-DGDAL_USE_CURL=ON",
            "-DGDAL_USE_DEFLATE=ON",
            "-DGDAL_USE_GEOS=ON",
            "-DGDAL_USE_GEOTIFF=ON",
            "-DGDAL_USE_GIF=OFF",
            "-DGDAL_USE_HDF5=ON",
            "-DGDAL_USE_JPEG=ON",
            "-DGDAL_USE_JSONC_INTERNAL=ON",
            "-DGDAL_USE_LIBXML2=ON",
            "-DGDAL_USE_LZ4=ON",
            "-DGDAL_USE_LZMA=ON",
            "-DGDAL_USE_OPENJPEG=ON",
            "-DGDAL_USE_OPENSSL=ON",
            "-DGDAL_USE_PNG=ON",
            "-DGDAL_USE_SQLITE3=ON",
            "-DGDAL_USE_TIFF=ON",
            "-DGDAL_USE_WEBP=OFF",
            "-DGDAL_USE_ZLIB=ON",
            "-DGDAL_USE_ZSTD=ON",
            "-DOGR_BUILD_OPTIONAL_DRIVERS=OFF",
            f"-DGEOS_INCLUDE_DIR={geos_prefix}/include",
            f"-DGEOS_LIBRARY={geos_prefix}/lib/libgeos.{ext}",
            f"-DHDF5_C_LIBRARY_hdf5={hdf5_prefix}/lib/libhdf5.{ext}",
            f"-DHDF5_C_LIBRARY_hdf5_hl={hdf5_prefix}/lib/libhdf5_hl.{ext}",
            f"-DHDF5_INCLUDE_DIRS={hdf5_prefix}/include",
            f"-DJPEG_INCLUDE_DIR={libjpeg_prefix}/include",
            f"-DJPEG_LIBRARY={libjpeg_prefix}/lib/libjpeg.{ext}",
            f"-DLIBXML2_INCLUDE_DIR={libxml2_prefix}/include/libxml2",
            f"-DLIBXML2_LIBRARY={libxml2_prefix}/lib/libxml2.{ext}",
            f"-DOPENJPEG_INCLUDE_DIR={openjpeg_prefix}/include",
            f"-DOPENSSL_CRYPTO_LIBRARY={openssl_prefix}/lib/libcrypto.{ext}",
            f"-DOPENSSL_INCLUDE_DIR={openssl_prefix}/include",
            f"-DOPENSSL_SSL_LIBRARY={openssl_prefix}/lib/libssl.{ext}",
            f"-DPCRE2_INCLUDE_DIR={pcre2_prefix}/include",
            f"-DPCRE2_LIBRARY={pcre2_prefix}/lib/libpcre2-8.{ext}",
            f"-DPNG_INCLUDE_DIR={libpng_prefix}/include",
            f"-DPNG_LIBRARY={libpng_prefix}/lib/libpng.{ext}",
            f"-DPROJ_INCLUDE_DIR={proj_prefix}/include",
            f"-DPROJ_LIBRARY={proj_prefix}/lib/libproj.{ext}",
            f"-DSQLite3_INCLUDE_DIR={sqlite_prefix}/include",
            f"-DSQLite3_LIBRARY={sqlite_prefix}/lib/libsqlite3.{ext}",
            f"-DTIFF_INCLUDE_DIR={libtiff_prefix}/include",
            f"-DTIFF_LIBRARY={libtiff_prefix}/lib/libtiff.{ext}",
            f"-DZLIB_INCLUDE_DIR={zlib_prefix}/include",
            f"-DZLIB_LIBRARY={zlib_prefix}/lib/libz.{ext}",
        ],
        env=env,
    )
