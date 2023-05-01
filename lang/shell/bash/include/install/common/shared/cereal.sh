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
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
