#!/usr/bin/env bash

koopa_install_broot() {
    koopa_install_app \
        --link-in-bin='broot' \
        --name='broot' \
        "$@"
}
