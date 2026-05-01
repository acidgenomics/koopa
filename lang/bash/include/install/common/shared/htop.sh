#!/usr/bin/env bash

main() {
    # """
    # Install htop.
    # @note Updated 2023-04-10.
    # """
    local -A dict
    local -a conf_args
    _koopa_activate_app --build-only 'autoconf' 'automake'
    _koopa_activate_app 'ncurses'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-unicode'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/htop-dev/htop/archive/\
${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    ./autogen.sh
    _koopa_make_build "${conf_args[@]}"
    return 0
}
