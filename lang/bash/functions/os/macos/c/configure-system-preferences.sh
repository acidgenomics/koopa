#!/usr/bin/env bash

koopa_macos_configure_system_preferences() {
    koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --system \
        "$@"
}
