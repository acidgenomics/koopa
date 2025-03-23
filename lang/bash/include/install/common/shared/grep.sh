#!/usr/bin/env bash

main() {
    # """
    # Install grep.
    # @note Updated 2023-08-30.
    # """
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app 'pcre2'
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-nls'
        '--program-prefix=g'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
