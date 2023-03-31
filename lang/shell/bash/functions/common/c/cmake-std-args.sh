#!/usr/bin/env bash

koopa_cmake_std_args() {
    # """
    # Standard CMake arguments.
    # @note Updated 2023-03-31.
    #
    # Potentially useful:
    # - CMAKE_STATIC_LINKER_FLAGS
    # """
    local dict prefix
    koopa_assert_has_args_eq "$#" 1
    declare -A dict
    dict['prefix']="${1:?}"
    args=(
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CXXFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_INCLUDEDIR=${dict['prefix']}/include"
        "-DCMAKE_INSTALL_LIBDIR=${dict['prefix']}/lib"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
    )
    koopa_print "${args[@]}"
    return 0
}
