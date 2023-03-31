#!/usr/bin/env bash

main() {
    # """
    # Install libzip.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://libzip.org/download/
    # - https://noknow.info/it/os/install_libzip_from_source?lang=en
    # """
    local cmake_args cmake_dict deps dict
    declare -A cmake_dict dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    deps=(
        'zlib'
        'bzip2'
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
    cmake_dict['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake_dict['bzip2_library']="${dict['bzip2']}/lib/\
libbz2.${dict['shared_ext']}"
    cmake_dict['zlib_include_dir']="${dict['zlib']}/include"
    cmake_dict['zlib_library']="${dict['zlib']}/lib/\
libz.${dict['shared_ext']}"
    cmake_dict['zstd_include_dir']="${dict['zstd']}/include"
    cmake_dict['zstd_library']="${dict['zstd']}/lib/\
libzstd.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake_dict['bzip2_include_dir']}" \
        "${cmake_dict['zlib_include_dir']}" \
        "${cmake_dict['zstd_include_dir']}"
    koopa_assert_is_file \
        "${cmake_dict['bzip2_library']}" \
        "${cmake_dict['zlib_library']}" \
        "${cmake_dict['zstd_library']}"
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
        "-DBZIP2_INCLUDE_DIR=${cmake_dict['bzip2_include_dir']}"
        "-DBZIP2_LIBRARY=${cmake_dict['bzip2_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake_dict['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake_dict['zlib_library']}"
        "-DZstd_INCLUDE_DIR=${cmake_dict['zstd_include_dir']}"
        "-DZstd_LIBRARY=${cmake_dict['zstd_library']}"
    )
    dict['url']="https://libzip.org/download/libzip-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
