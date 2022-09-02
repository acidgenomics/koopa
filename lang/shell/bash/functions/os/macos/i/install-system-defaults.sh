#!/usr/bin/env bash

koopa_macos_install_system_defaults() {
    koopa_install_app \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}
