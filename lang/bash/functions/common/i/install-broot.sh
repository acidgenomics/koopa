#!/usr/bin/env bash

koopa_install_broot() {
    koopa_install_app \
        --installer='rust-package' \
        --name='broot' \
        "$@"
}
