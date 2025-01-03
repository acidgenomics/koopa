#!/usr/bin/env bash

koopa_install_broot() {
    koopa_install_app \
        --installer='conda-package' \
        --name='broot' \
        "$@"
}
