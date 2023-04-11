#!/usr/bin/env bash

koopa_macos_install_system_xcode_openmp() {
    koopa_install_app \
        --name='xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
