#!/usr/bin/env bash

koopa_debian_install_system_base() {
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}
