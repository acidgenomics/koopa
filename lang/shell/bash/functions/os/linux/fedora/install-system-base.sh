#!/usr/bin/env bash

koopa_fedora_install_system_base() {
    koopa_install_app \
        --name-fancy='Fedora base system' \
        --name='base' \
        --platform='fedora' \
        --system \
        "$@"
}
