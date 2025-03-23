#!/usr/bin/env bash

main() {
    # """
    # Install libiconv.
    # @note Updated 2023-08-30.
    #
    # Not needed on Linux, where 'iconv.h' is provided by glibc.
    # """
    local -a conf_args install_args
    local conf_arg
    conf_args=(
        '--disable-debug'
        '--disable-dependency-tracking'
        '--disable-static'
        '--enable-extra-encodings'
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
