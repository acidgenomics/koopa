#!/usr/bin/env bash

_koopa_macos_uninstall_system_docker() {
    _koopa_uninstall_app \
        --name='docker' \
        --platform='macos' \
        --system \
        "$@"
}
