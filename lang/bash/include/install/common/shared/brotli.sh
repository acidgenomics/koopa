#!/usr/bin/env bash

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
    _koopa_activate_app --build-only 'pkg-config'
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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
