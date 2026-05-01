#!/usr/bin/env bash

_koopa_install_fd_find() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fd-find' \
        "$@"
}
