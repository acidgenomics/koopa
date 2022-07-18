#!/usr/bin/env bash

koopa_macos_install_r_gfortran() {
    koopa_install_app \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}
