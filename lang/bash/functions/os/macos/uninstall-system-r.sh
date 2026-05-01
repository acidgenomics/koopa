#!/usr/bin/env bash

_koopa_macos_uninstall_system_r() {
    _koopa_uninstall_app \
        --name='r' \
        --platform='macos' \
        --system \
        "$@"
}
