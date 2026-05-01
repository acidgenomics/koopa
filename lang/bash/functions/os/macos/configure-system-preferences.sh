#!/usr/bin/env bash

_koopa_macos_configure_system_preferences() {
    _koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --system \
        "$@"
}
