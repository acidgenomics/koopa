#!/usr/bin/env bash

koopa_macos_install_system_defaults() {
    koopa_update_app \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}
