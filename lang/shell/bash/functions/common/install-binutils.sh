#!/usr/bin/env bash

koopa_install_binutils() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='binutils' \
        "$@"
}
