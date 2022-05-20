#!/usr/bin/env bash

koopa_macos_update_system() {
    koopa_update_app \
        --name-fancy='macOS system' \
        --name='system' \
        --platform='macos' \
        --system \
        "$@"
}
