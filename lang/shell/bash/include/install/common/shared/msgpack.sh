#!/usr/bin/env bash

# NOTE Consider adding support for GTest here.

main() {
    # """
    # Install msgpack.
    # @note Updated 2022-11-08.
    #
    # - @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/msgpack.rb
    # """
    local app cmake_args dict
    koopa_activate_app --build-only 'cmake'
    koopa_activate_app 'zlib' 'boost'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['boost']="$(koopa_app_prefix 'boost')"
        ['name']='msgpack-cxx'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    koopa_assert_is_dir "${dict['zlib']}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/msgpack/msgpack-c/releases/download/\
cpp-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # > "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "-DBoost_INCLUDE_DIR=${dict['boost']}/include"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH -S . -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" --build 'build'
    "${app['cmake']}" --install 'build'
    return 0
}
