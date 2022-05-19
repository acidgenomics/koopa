#!/usr/bin/env bash

koopa_debian_install_base_system() {
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}
