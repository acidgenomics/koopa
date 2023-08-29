#!/usr/bin/env bash

koopa_install_fd_find() {
    koopa_install_app \
        --installer='rust-package' \
        --name='fd-find' \
        "$@"
}
