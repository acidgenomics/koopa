#!/usr/bin/env bash

koopa_uninstall_broot() {
    koopa_uninstall_app \
        --name='broot' \
        --unlink-in-bin='broot' \
        "$@"
}
