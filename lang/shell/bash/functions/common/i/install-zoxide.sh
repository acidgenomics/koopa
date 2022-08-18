#!/usr/bin/env bash

koopa_install_zoxide() {
    koopa_install_app \
        --link-in-bin='zoxide' \
        --name='zoxide' \
        "$@"
}
