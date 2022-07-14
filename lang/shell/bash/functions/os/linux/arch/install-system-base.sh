#!/usr/bin/env bash

koopa_arch_install_system_base() {
    koopa_install_app \
        --name-fancy='Arch base system' \
        --name='base' \
        --platform='arch' \
        --system \
        "$@"
}
