#!/usr/bin/env bash

koopa_install_tuc() {
    koopa_install_app \
        --installer='conda-package' \
        --name='tuc' \
        "$@"
}
