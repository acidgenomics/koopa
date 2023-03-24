#!/usr/bin/env bash

main() {
    # """
    # Install libzip.
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://libzip.org/download/
    # - https://noknow.info/it/os/install_libzip_from_source?lang=en
    # """
    local app cmake_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake' 'pkg-config'
    deps=(
        'zlib'
        'bzip2'
        'zstd'
        'nettle'
        'openssl3'
        'perl'
    )
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['bzip2']="$(koopa_app_prefix 'bzip2')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libzip'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
        ['zstd']="$(koopa_app_prefix 'zstd')"
    )
    koopa_assert_is_dir \
        "${dict['bzip2']}" \
        "${dict['zlib']}" \
        "${dict['zstd']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://libzip.org/download/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
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
        "-DBZIP2_INCLUDE_DIR=${dict['bzip2']}/include"
        "-DBZIP2_LIBRARY=${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
        "-DZstd_INCLUDE_DIR=${dict['zstd']}/include"
        "-DZstd_LIBRARY=${dict['zstd']}/lib/libzstd.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH -S .. "${cmake_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}
