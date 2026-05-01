#!/usr/bin/env bash

_koopa_macos_install_system_r_xcode_openmp() {
    _koopa_install_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
