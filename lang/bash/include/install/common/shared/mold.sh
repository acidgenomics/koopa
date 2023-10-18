#!/usr/bin/env bash

# FIXME This is now failing on Linux:
#
# CMake Error at CMakeLists.txt:178 (find_package):
#   By not providing "Findmimalloc.cmake" in CMAKE_MODULE_PATH this project has
#   asked CMake to find a package configuration file provided by "mimalloc",
#   but CMake did not find one.
#
#   Could not find a package configuration file provided by "mimalloc" with any
#   of the following names:
#
#     mimallocConfig.cmake
#     mimalloc-config.cmake
#
#   Add the installation prefix of "mimalloc" to CMAKE_PREFIX_PATH or set
#   "mimalloc_DIR" to a directory containing one of the above files.  If
#   "mimalloc" provides a separate development package or SDK, be sure it has
#   been installed.

main() {
    # """
    # Install mold.
    # @note Updated 2023-06-07.
    #
    # @seealso
    # - https://github.com/rui314/mold
    # """
    local -A dict
    local -a cmake_args deps
    deps=('tbb' 'zlib' 'zstd')
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/rui314/mold/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake_args=(
        '-DCMAKE_SKIP_INSTALL_RULES=OFF'
        '-DMOLD_LTO=ON'
        '-DMOLD_USE_MIMALLOC=ON'
        '-DMOLD_USE_SYSTEM_MIMALLOC=ON'
        '-DMOLD_USE_SYSTEM_TBB=ON'
    )
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
