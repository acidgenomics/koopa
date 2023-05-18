#!/usr/bin/env bash

koopa_macos_configure_user_defaults() {
    koopa_configure_app \
        --name='defaults' \
        --platform='macos' \
        --user \
        "$@"
}
