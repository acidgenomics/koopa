#!/usr/bin/env bash

main() {
    # """
    # Install Oxford Nanopore Technologies VBZ compression.
    # @note Updated 2023-03-29.
    #
    # @seealso
    # - https://github.com/nanoporetech/vbz_compression
    # - https://github.com/nanoporetech/vbz_compression/blob/master/
    #     cmake/Findzstd.cmake
    # """
    local app cmake_args cmake_dict dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    koopa_activate_app 'zstd' 'hdf5'
    declare -A app
    app['cmake']="$(koopa_locate_cmake)"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['hdf5']="$(koopa_app_prefix 'hdf5')"
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['streamvbyte_version']='0.5.2'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zstd']="$(koopa_app_prefix 'zstd')"
    )
    koopa_assert_is_dir "${dict['hdf5']}" "${dict['zstd']}"
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
    declare -A cmake_dict=(
        ['zstd_include_dir']="${dict['zstd']}/include"
        ['zstd_library']="${dict['zstd']}/lib/libzstd.${dict['shared_ext']}"
    )
    koopa_assert_is_dir "${cmake_dict['zstd_include_dir']}"
    koopa_assert_is_file "${cmake_dict['zstd_library']}"
    cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_BUILD_TYPE=Release'
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Build options --------------------------------------------------------
        '-DENABLE_CONAN=OFF'
        '-DENABLE_PERF_TESTING=OFF'
        '-DENABLE_PYTHON=OFF'
        # Dependency paths -----------------------------------------------------
        "-DZSTD_INCLUDE_DIR=${cmake_dict['zstd_include_dir']}"
        "-DZSTD_LIBRARY_RELEASE=${cmake_dict['zstd_library']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        '-S' '.' \
        '-B' 'builddir' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'builddir' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'builddir'
    return 0
}
