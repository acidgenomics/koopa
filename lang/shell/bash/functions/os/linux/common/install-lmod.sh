#!/usr/bin/env bash

koopa_linux_install_lmod() {
    koopa_install_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}
