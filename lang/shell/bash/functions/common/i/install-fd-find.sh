#!/usr/bin/env bash

koopa_install_fd_find() {
    koopa_install_app \
        --link-in-bin='fd' \
        --name='fd-find' \
        "$@"
}
