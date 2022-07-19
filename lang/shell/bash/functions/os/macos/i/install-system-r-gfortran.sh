#!/usr/bin/env bash

koopa_macos_install_system_r_gfortran() {
    koopa_install_app \
        --name='r-gfortran' \
        --no-prefix-check \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}
