#!/usr/bin/env bash

koopa_macos_update_defaults() {
    koopa_update_app \
        --name-fancy='macOS defaults' \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}
