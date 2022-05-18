#!/usr/bin/env bash

koopa_arch_install_base_system() {
    koopa_install_app \
        --name-fancy='Arch base system' \
        --name='base-system' \
        --platform='arch' \
        --system \
        "$@"
}
