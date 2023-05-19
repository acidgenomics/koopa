#!/usr/bin/env bash

koopa_debian_uninstall_system_docker() {
    koopa_uninstall_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
