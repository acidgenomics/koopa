#!/usr/bin/env bash

koopa::opensuse_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='openSUSE base system' \
        --name='base-system' \
        --platform='opensuse' \
        --system \
        "$@"
}
