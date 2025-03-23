#!/usr/bin/env bash

main() {
    # """
    # Install libtool.
    # @note Updated 2023-08-30.
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app 'm4'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    conf_args=(
        '--disable-static'
        '--program-prefix=g'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln 'glibtool' 'libtool'
        koopa_ln 'glibtoolize' 'libtoolize'
    )
    return 0
}
