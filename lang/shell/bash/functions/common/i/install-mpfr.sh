#!/usr/bin/env bash

koopa_install_mpfr() {
    koopa_install_app \
        --activate-opt='gmp' \
        --installer='gnu-app' \
        --name='mpfr' \
        "$@"
}
