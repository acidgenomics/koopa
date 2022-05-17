#!/usr/bin/env bash

koopa_uninstall_fd_find() {
    koopa_uninstall_app \
        --unlink-in-bin='fd' \
        --name='fd-find' \
        "$@"
}
