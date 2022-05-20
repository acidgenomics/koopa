#!/usr/bin/env bash

koopa_macos_install_xcode_clt() {
    koopa_install_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}
