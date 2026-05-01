#!/usr/bin/env bash

_koopa_macos_uninstall_system_r_gfortran() {
    _koopa_uninstall_app \
        --name='r-gfortran' \
        --platform='macos' \
        --system \
        "$@"
}
