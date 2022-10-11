#!/usr/bin/env bash

main() {
    local dict
    declare -A dict=(
        ['gmp']="$(koopa_app_prefix 'gmp')"
        ['mpfr']="$(koopa_app_prefix 'mpfr')"
    )
    koopa_activate_app 'gmp' 'mpfr'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='mpc' \
        -D "--with-gmp=${dict['gmp']}" \
        -D "--with-mpfr=${dict['mpfr']}" \
        "$@"
}
