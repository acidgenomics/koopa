#!/usr/bin/env bash

main() {
    # """
    # Install mpc.
    # @note Updated 2023-08-30.
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app 'gmp' 'mpfr'
    dict['gmp']="$(koopa_app_prefix 'gmp')"
    dict['mpfr']="$(koopa_app_prefix 'mpfr')"
    conf_args=(
        '--disable-static'
        "--with-gmp=${dict['gmp']}"
        "--with-mpfr=${dict['mpfr']}"
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
