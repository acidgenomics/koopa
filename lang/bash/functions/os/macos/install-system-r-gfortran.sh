#!/usr/bin/env bash

_koopa_macos_install_system_r_gfortran() {
    _koopa_install_app \
        --name='r-gfortran' \
        --platform='macos' \
        --system \
        "$@"
}
