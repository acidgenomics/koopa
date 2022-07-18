#!/usr/bin/env bash

koopa_macos_uninstall_system_xcode_clt() {
    koopa_uninstall_app \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}
