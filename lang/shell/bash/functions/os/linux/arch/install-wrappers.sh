#!/usr/bin/env bash

koopa::arch_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Arch base system' \
        --name='base-system' \
        --platform='arch' \
        --system \
        "$@"
}
