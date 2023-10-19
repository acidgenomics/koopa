#!/usr/bin/env bash

main() {
    # """
    # Install mold.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://github.com/rui314/mold
    # """
    local -A dict
    local -a cmake_args deps
    deps+=('mimalloc' 'tbb' 'zlib' 'zstd')
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
