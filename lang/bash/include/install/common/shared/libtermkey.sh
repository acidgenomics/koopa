#!/usr/bin/env bash

main() {
    # """
    # Install libtermkey.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/libtermkey.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'libtool' 'make' 'pkg-config'
    koopa_activate_app 'ncurses' 'unibilium'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://www.leonerd.org.uk/code/libtermkey/\
libtermkey-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" PREFIX="${dict['prefix']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}
