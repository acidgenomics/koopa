#!/usr/bin/env bash

# FIXME Need to address this:
# MACOSX_RPATH is not specified for the following targets

main() {
    # """
    # Install Brotli.
    # @note Updated 2023-05-15.
    #
    # @seealso
    # - https://github.com/conda-forge/brotli-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/brotli.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # CMake options --------------------------------------------------------
        # > '-DCMAKE_MACOSX_RPATH=ON'
        # Build options --------------------------------------------------------
        '-DBUILD_STATIC_LIBS=OFF'
    )
    dict['url']="https://github.com/google/brotli/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
