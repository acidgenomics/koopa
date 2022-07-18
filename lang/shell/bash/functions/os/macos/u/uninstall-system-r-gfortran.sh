#!/usr/bin/env bash

koopa_macos_uninstall_r_gfortran() {
    koopa_uninstall_app \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}
