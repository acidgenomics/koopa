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
    koopa_assert_has_no_args "$#"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DEXPECTED_ENABLE_TESTS=OFF')
    dict['url']="https://github.com/TartanLlama/expected/archive/\
refs/tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
