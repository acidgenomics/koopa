#!/usr/bin/env bash

koopa_macos_configure_user_preferences() {
    koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --user \
        "$@"
}
