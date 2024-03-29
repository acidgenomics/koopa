#!/usr/bin/env bash

main() {
    # """
    # Install termcolor.
    # @note Updated 2023-06-12.
    #
    # @seealso
    # - https://github.com/ikalnytskyi/termcolor
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/termcolor.rb
    # """
    local -A dict
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/ikalnytskyi/termcolor/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}
