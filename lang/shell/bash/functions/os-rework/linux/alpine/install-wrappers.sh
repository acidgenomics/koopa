#!/usr/bin/env bash

# System ================================================================== {{{1

# base-system ------------------------------------------------------------- {{{2

koopa_alpine_install_base_system() {
    koopa_install_app \
        --name-fancy='Alpine base system' \
        --name='base-system' \
        --platform='alpine' \
        --system \
        "$@"
}

# glibc ------------------------------------------------------------------- {{{2

koopa_alpine_install_glibc() {
    koopa_install_app \
        --name='glibc' \
        --platform='alpine' \
        --system \
        --version='2.30-r0' \
        "$@"
}
