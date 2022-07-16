#!/usr/bin/env bash

koopa_macos_install_system_xcode_clt() {
    koopa_install_app \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}
