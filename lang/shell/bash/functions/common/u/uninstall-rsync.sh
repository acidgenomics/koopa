#!/usr/bin/env bash

koopa_uninstall_rsync() {
    koopa_uninstall_app \
        --name='rsync' \
        --unlink-in-bin='rsync' \
        "$@"
}
