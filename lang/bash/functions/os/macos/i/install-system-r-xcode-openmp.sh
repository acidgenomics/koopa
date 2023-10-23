#!/usr/bin/env bash

koopa_macos_install_system_r_xcode_openmp() {
    koopa_install_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
