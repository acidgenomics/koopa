#!/usr/bin/env bash

koopa_debian_install_system_docker() {
    koopa_install_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
