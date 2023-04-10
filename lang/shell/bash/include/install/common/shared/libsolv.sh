#!/usr/bin/env bash

main() {
    # """
    # Install libsolv.
    # @note Updated 2023-04-04.
    #
    # @seealso
    # - https://github.com/openSUSE/libsolv
    # """
    local -A cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    koopa_assert_is_dir "${dict['zlib']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir "${cmake['zlib_include_dir']}"
    koopa_assert_is_file "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        # > '-DENABLE_PYTHON=yes'
        # > '-DWITH_LIBXML2=yes'
        '-DENABLE_CONDA=yes'
        # Dependency paths -----------------------------------------------------
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    dict['url']="https://github.com/openSUSE/libsolv/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
