#!/usr/bin/env bash

koopa_macos_configure_system_defaults() {
    koopa_configure_app \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}
