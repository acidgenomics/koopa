#!/usr/bin/env bash

koopa_macos_uninstall_system_r() {
    koopa_uninstall_app \
        --name='r' \
        --platform='macos' \
        --system \
        "$@"
}
