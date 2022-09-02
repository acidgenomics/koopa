#!/usr/bin/env bash

koopa_macos_install_user_defaults() {
    koopa_install_app \
        --name='defaults' \
        --platform='macos' \
        --user \
        "$@"
}
