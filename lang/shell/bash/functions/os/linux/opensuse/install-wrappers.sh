#!/usr/bin/env bash

# System ================================================================== {{{1

# base-system ------------------------------------------------------------- {{{2

koopa_opensuse_install_base_system() { # {{{3
    koopa_install_app \
        --name-fancy='openSUSE base system' \
        --name='base-system' \
        --platform='opensuse' \
        --system \
        "$@"
}
