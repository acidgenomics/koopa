#!/usr/bin/env bash

koopa_macos_install_system_gfortran() {
    koopa_install_app \
        --name='gfortran' \
        --platform='macos' \
        --system \
        "$@"
}
