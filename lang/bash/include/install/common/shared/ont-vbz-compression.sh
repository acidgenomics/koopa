#!/usr/bin/env bash

main() {
    # """
    # Install Oxford Nanopore Technologies VBZ compression.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://github.com/nanoporetech/vbz_compression
    # - https://github.com/nanoporetech/vbz_compression/blob/master/
    #     cmake/Findzstd.cmake
    # """
    local -A cmake dict
    local -a cmake_args
    koopa_activate_app 'zlib' 'zstd' 'hdf5'
    dict['hdf5']="$(koopa_app_prefix 'hdf5')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['streamvbyte_version']='0.5.2'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zstd']="$(koopa_app_prefix 'zstd')"
    koopa_assert_is_dir "${dict['hdf5']}" "${dict['zstd']}"
    cmake['zstd_include_dir']="${dict['zstd']}/include"
    cmake['zstd_library']="${dict['zstd']}/lib/libzstd.${dict['shared_ext']}"
    koopa_assert_is_dir "${cmake['zstd_include_dir']}"
    koopa_assert_is_file "${cmake['zstd_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DENABLE_CONAN=OFF'
        '-DENABLE_PERF_TESTING=OFF'
        '-DENABLE_PYTHON=OFF'
        # Dependency paths -----------------------------------------------------
        "-DZSTD_INCLUDE_DIR=${cmake['zstd_include_dir']}"
        "-DZSTD_LIBRARY_RELEASE=${cmake['zstd_library']}"
    )
    dict['url']="https://github.com/nanoporetech/vbz_compression/archive/\
refs/tags/${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    dict['streamvbyte_url']="https://github.com/lemire/streamvbyte/archive/\
refs/tags/v${dict['streamvbyte_version']}.tar.gz"
    koopa_download "${dict['streamvbyte_url']}"
    koopa_extract \
        "$(koopa_basename "${dict['streamvbyte_url']}")" \
        'src/third_party/streamvbyte'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
