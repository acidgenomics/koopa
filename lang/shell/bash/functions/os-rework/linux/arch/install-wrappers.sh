#!/usr/bin/env bash

# System ================================================================== {{{1

# base-system ------------------------------------------------------------- {{{2

koopa_arch_install_base_system() {
    koopa_install_app \
        --name-fancy='Arch base system' \
        --name='base-system' \
        --platform='arch' \
        --system \
        "$@"
}
