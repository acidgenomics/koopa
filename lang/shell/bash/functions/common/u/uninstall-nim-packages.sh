#!/usr/bin/env bash

koopa_uninstall_nim_packages() {
    koopa_uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        --unlink-in-bin='markdown' \
        "$@"
}
