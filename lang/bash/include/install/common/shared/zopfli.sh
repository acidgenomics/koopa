#!/usr/bin/env bash

main() {
    # """
    # Install zopfli.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/google/zopfli
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zopfli.rb
    # """
    local -A dict
    local -a cmake_args
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DBUILD_SHARED_LIBS=ON')
    dict['url']="https://github.com/google/zopfli/archive/\
zopfli-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
