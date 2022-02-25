#!/usr/bin/env bash

koopa_opensuse_install_base_system() { # {{{1
    koopa_install_app \
        --name-fancy='openSUSE base system' \
        --name='base-system' \
        --platform='opensuse' \
        --system \
        "$@"
}
