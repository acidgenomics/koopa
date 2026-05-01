#!/usr/bin/env bash

main() {
    # """
    # Install cereal.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cereal.rb
    # """
    local -A dict
    local -a cmake_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DJUST_INSTALL_CEREAL=ON')
    dict['url']="https://github.com/USCiLab/cereal/archive/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
