#!/usr/bin/env bash

koopa_macos_uninstall_system_r_gfortran() {
    koopa_uninstall_app \
        --name='r-gfortran' \
        --platform='macos' \
        --system \
        "$@"
}
