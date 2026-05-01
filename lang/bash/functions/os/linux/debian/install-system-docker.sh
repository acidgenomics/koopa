#!/usr/bin/env bash

_koopa_debian_install_system_docker() {
    _koopa_install_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
