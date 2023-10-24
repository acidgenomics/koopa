#!/usr/bin/env bash

koopa_macos_uninstall_system_r_xcode_openmp() {
    koopa_uninstall_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
