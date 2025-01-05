#!/usr/bin/env bash

koopa_install_fd_find() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fd-find' \
        "$@"
}
