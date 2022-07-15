#!/usr/bin/env bash

koopa_macos_uninstall_docker() {
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='macos' \
        --system \
        "$@"
}
