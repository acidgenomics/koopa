#!/usr/bin/env bash

koopa_macos_uninstall_xcode_clt() {
    koopa_uninstall_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}
