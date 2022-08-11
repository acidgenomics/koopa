#!/usr/bin/env bash

# FIXME This is causing 'koopa install --all' to error because it's attempting
# to locate mpfr, which isn't installed yet.
# FIXME Need to rework the installer here for better binary support.

koopa_install_mpc() {
    set -x 
    local dict
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    dict[gmp]="$(koopa_realpath "${dict[opt_prefix]}/gmp")"
    dict[mpfr]="$(koopa_realpath "${dict[opt_prefix]}/mpfr")"
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='mpfr' \
        --installer='gnu-app' \
        --name='mpc' \
        -D "--with-gmp=${dict[gmp]}" \
        -D "--with-mpfr=${dict[mpfr]}" \
        "$@"
}
