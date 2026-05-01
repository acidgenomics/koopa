#!/usr/bin/env bash

_koopa_debian_uninstall_system_docker() {
    _koopa_uninstall_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
