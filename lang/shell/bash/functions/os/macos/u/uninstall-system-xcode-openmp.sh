#!/usr/bin/env bash

koopa_macos_uninstall_system_xcode_openmp() {
    koopa_uninstall_app \
        --name='xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
