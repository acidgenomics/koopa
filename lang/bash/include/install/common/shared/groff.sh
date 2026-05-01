#!/usr/bin/env bash

main() {
    # """
    # Install groff.
    # @note Updated 2023-08-31.
    # """
    local -a conf_args install_args
    local conf_arg
    _koopa_activate_app --build-only 'bison' 'pkg-config' 'texinfo'
    _koopa_activate_app 'm4' 'perl'
    conf_args=('--without-x')
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    _koopa_install_gnu_app "${install_args[@]}"
    return 0
}
