#!/usr/bin/env bash

main() {
    # """
    # Install libdeflate.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/ebiggers/libdeflate
    # - https://github.com/conda-forge/libdeflate-feedstock/tree/main/recipe
    # """
    local -A dict
    local -a cmake_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DLIBDEFLATE_BUILD_STATIC_LIB=OFF')
    dict['url']="https://github.com/ebiggers/libdeflate/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
