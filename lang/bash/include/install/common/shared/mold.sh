#!/usr/bin/env bash

main() {
    # """
    # Install mold.
    # @note Updated 2023-10-19.
    #
    # @seealso
    # - https://github.com/rui314/mold
    # - https://formulae.brew.sh/formula/mold
    # """
    local -A dict
    local -a cmake_args deps
    deps+=('mimalloc' 'tbb' 'zlib' 'zstd')
    _koopa_activate_app "${deps[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    _koopa_is_linux && dict['jobs']=1
    dict['url']="https://github.com/rui314/mold/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    cmake_args=(
        '-DCMAKE_SKIP_INSTALL_RULES=OFF'
        '-DMOLD_LTO=ON'
        '-DMOLD_USE_MIMALLOC=ON'
        '-DMOLD_USE_SYSTEM_MIMALLOC=ON'
        '-DMOLD_USE_SYSTEM_TBB=ON'
    )
    _koopa_cmake_build \
        --jobs="${dict['jobs']}" \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}
