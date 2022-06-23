#!/usr/bin/env bash

koopa_install_gdbm() {
    koopa_install_app \
        --installer='gnu-app' \
        --activate-opt='readline' \
        --name='gdbm' \
        "$@"
}
