#!/usr/bin/env bash

koopa_install_bison() {
    koopa_install_app \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='bison' \
        -D '--enable-relocatable' \
        "$@"
}
