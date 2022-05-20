#!/usr/bin/env bash

koopa_fedora_install_base_system() {
    koopa_install_app \
        --name-fancy='Fedora base system' \
        --name='base-system' \
        --platform='fedora' \
        --system \
        "$@"
}
