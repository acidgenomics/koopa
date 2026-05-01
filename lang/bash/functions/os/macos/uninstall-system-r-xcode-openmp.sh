#!/usr/bin/env bash

_koopa_macos_uninstall_system_r_xcode_openmp() {
    _koopa_uninstall_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}
