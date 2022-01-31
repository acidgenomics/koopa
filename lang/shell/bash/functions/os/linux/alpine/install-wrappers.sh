#!/usr/bin/env bash

koopa::alpine_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Alpine base system' \
        --name='base-system' \
        --platform='alpine' \
        --system \
        "$@"
}

koopa::alpine_install_glibc() { # {{{1
    koopa::install_app \
        --name='glibc' \
        --platform='alpine' \
        --system \
        --version='2.30-r0'
}
