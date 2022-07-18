#!/usr/bin/env bash

koopa_debian_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='debian' \
        --system \
        "$@"
}
