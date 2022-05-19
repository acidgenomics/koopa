#!/usr/bin/env bash

koopa_debian_install_docker() {
    koopa_install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}
