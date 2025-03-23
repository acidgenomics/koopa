#!/usr/bin/env bash

main() {
    # """
    # Install htop.
    # @note Updated 2023-04-10.
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'autoconf' 'automake'
    koopa_activate_app 'ncurses' 'python3.12'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=(
        '--disable-unicode'
        "--prefix=${dict['prefix']}"
    )
    dict['url']="https://github.com/htop-dev/htop/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    ./autogen.sh
    koopa_make_build "${conf_args[@]}"
    return 0
}
