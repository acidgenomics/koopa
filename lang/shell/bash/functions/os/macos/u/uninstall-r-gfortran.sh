#!/usr/bin/env bash

koopa_macos_uninstall_r_gfortran() {
    koopa_uninstall_app \
        --name-fancy='R gfortran' \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}
