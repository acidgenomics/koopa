#!/usr/bin/env bash

main() {
    # """
    # Install libzip.
    # @note Updated 2023-10-10.
    #
    # @seealso
    # - https://libzip.org/download/
    # - https://noknow.info/it/os/install_libzip_from_source?lang=en
    # """
    local -A cmake dict
    local -a cmake_args deps
    koopa_activate_app --build-only 'pkg-config'
    ! koopa_is_macos && deps+=('bzip2')
    deps+=(
        'zlib'
        'zstd'
        'nettle'
        'openssl3'
        'perl'
    )
    koopa_activate_app "${deps[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['zlib']}" \
        "${dict['zstd']}"
    cmake['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake['bzip2_library']="${dict['bzip2']}/lib/\
libbz2.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/\
libz.${dict['shared_ext']}"
    cmake['zstd_include_dir']="${dict['zstd']}/include"
    cmake['zstd_library']="${dict['zstd']}/lib/\
libzstd.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['bzip2_include_dir']}" \
        "${cmake['zlib_include_dir']}" \
        "${cmake['zstd_include_dir']}"
    koopa_assert_is_file \
        "${cmake['bzip2_library']}" \
        "${cmake['zlib_library']}" \
        "${cmake['zstd_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DENABLE_BZIP2=ON'
        '-DENABLE_COMMONCRYPTO=OFF'
        '-DENABLE_GNUTLS=OFF'
        '-DENABLE_LZMA=OFF'
        '-DENABLE_MBEDTLS=OFF'
        '-DENABLE_OPENSSL=OFF'
        '-DENABLE_WINDOWS_CRYPTO=OFF'
        '-DENABLE_ZSTD=ON'
        # Dependency paths -----------------------------------------------------
        "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
        "-DBZIP2_LIBRARY=${cmake['bzip2_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
        "-DZstd_INCLUDE_DIR=${cmake['zstd_include_dir']}"
        "-DZstd_LIBRARY=${cmake['zstd_library']}"
    )
    dict['url']="https://libzip.org/download/libzip-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
