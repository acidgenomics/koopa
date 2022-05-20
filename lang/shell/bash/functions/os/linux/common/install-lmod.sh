#!/usr/bin/env bash

koopa_linux_install_lmod() {
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
}
