#!/usr/bin/env bash

main() {
    # """
    # Install TartanLlama expected (tl-expected).
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/TartanLlama/expected
    # """
    local -A dict
    local -a cmake_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DEXPECTED_ENABLE_TESTS=OFF')
    dict['url']="https://github.com/TartanLlama/expected/archive/\
refs/tags/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
