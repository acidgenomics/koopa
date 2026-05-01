#!/usr/bin/env bash

_koopa_macos_configure_user_preferences() {
    _koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --user \
        "$@"
}
