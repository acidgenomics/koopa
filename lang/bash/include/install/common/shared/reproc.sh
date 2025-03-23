#!/usr/bin/env bash

main() {
    # """
    # Install reproc.
    # @note Updated 2023-05-17.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/reproc.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_SHARED_LIBS=ON'
        '-DREPROC++=ON'
    )
    dict['url']="https://github.com/DaanDeMeyer/reproc/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build \
        --include-dir='include' \
        --lib-dir='lib' \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
