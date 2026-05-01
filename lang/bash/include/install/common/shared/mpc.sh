#!/usr/bin/env bash

main() {
    # """
    # Install mpc.
    # @note Updated 2023-08-30.
    # """
    local -A dict
    local -a conf_args install_args
    local conf_arg
    _koopa_activate_app 'gmp' 'mpfr'
    dict['gmp']="$(_koopa_app_prefix 'gmp')"
    dict['mpfr']="$(_koopa_app_prefix 'mpfr')"
    conf_args=(
        '--disable-static'
        "--with-gmp=${dict['gmp']}"
        "--with-mpfr=${dict['mpfr']}"
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    _koopa_install_gnu_app "${install_args[@]}"
    return 0
}
