#!/usr/bin/env bash

koopa_alpine_install_base_system() { # {{{1
    koopa_install_app \
        --name-fancy='Alpine base system' \
        --name='base-system' \
        --platform='alpine' \
        --system \
        "$@"
}

koopa_alpine_install_glibc_binary() { # {{{1
    koopa_install_app \
        --name-fancy='glibc (binary)' \
        --name='glibc-binary' \
        --platform='alpine' \
        --system \
        --version='2.30-r0' \
        "$@"
}
