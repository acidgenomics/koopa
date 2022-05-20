#!/usr/bin/env bash

koopa_debian_uninstall_docker() {
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
