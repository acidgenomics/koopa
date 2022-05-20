#!/usr/bin/env bash

koopa_install_fd_find() {
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/fd' \
        --name='fd-find' \
        "$@"
}
