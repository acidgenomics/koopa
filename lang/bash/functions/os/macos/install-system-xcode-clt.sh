#!/usr/bin/env bash

_koopa_macos_install_system_xcode_clt() {
    _koopa_install_app \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}
