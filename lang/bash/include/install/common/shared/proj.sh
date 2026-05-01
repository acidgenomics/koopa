#!/usr/bin/env bash

# NOTE Rework using a cmake dict.

main() {
    # """
    # Install PROJ.
    # @note Updated 2025-02-20.
    #
    # @seealso
    # - https://proj.org/install.html#cmake-configure-options
    # - https://github.com/OSGeo/PROJ/issues/2084
    # - https://github.com/tesseract-ocr/tesseract/issues/786
    # """
    local cmake_args deps dict
    local -A dict
    deps=(
        'zlib'
        'zstd' # curl
        'openssl'
        'libssh2' # curl
        'curl'
        'libjpeg-turbo'
        'libtiff'
        'python'
        'sqlite'
    )
    _koopa_activate_app --build-only 'pkg-config'
    _koopa_activate_app "${deps[@]}"
    dict['curl']="$(_koopa_app_prefix 'curl')"
    dict['libtiff']="$(_koopa_app_prefix 'libtiff')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['sqlite']="$(_koopa_app_prefix 'sqlite')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_APPS=ON'
        '-DBUILD_FRAMEWORKS_AND_BUNDLE=OFF'
        '-DBUILD_SHARED_LIBS=ON'
        '-DBUILD_TESTING=OFF'
        '-DENABLE_CURL=ON'
        '-DENABLE_TIFF=ON'
        # Dependency paths -----------------------------------------------------
        # Required dependency paths.
        "-DEXE_SQLITE3=${dict['sqlite']}/bin/sqlite3"
        "-DSQLITE3_INCLUDE_DIR=${dict['sqlite']}/include"
        "-DSQLITE3_LIBRARY=${dict['sqlite']}/lib/\
libsqlite3.${dict['shared_ext']}"
        # Optional dependency paths.
        "-DCURL_INCLUDE_DIR=${dict['curl']}/include"
        "-DCURL_LIBRARY=${dict['curl']}/lib/libcurl.${dict['shared_ext']}"
        "-DTIFF_INCLUDE_DIR=${dict['libtiff']}/include"
        "-DTIFF_LIBRARY_RELEASE=${dict['libtiff']}/lib/\
libtiff.${dict['shared_ext']}"
    )
    dict['url']="https://github.com/OSGeo/PROJ/releases/download/\
${dict['version']}/proj-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
