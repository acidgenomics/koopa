#!/usr/bin/env bash

main() {
    # """
    # Install termcolor.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/ikalnytskyi/termcolor
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/termcolor.rb
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='termcolor'
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
