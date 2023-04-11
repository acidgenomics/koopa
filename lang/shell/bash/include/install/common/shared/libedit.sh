#!/usr/bin/env bash

main() {
    # """
    # Install libedit.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://thrysoee.dk/editline/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libedit.rb
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'ncurses'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-static'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://thrysoee.dk/editline/libedit-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}
