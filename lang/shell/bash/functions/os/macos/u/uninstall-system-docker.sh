#!/usr/bin/env bash

koopa_macos_uninstall_system_docker() {
    koopa_uninstall_app \
        --name='docker' \
        --platform='macos' \
        --system \
        "$@"
}
