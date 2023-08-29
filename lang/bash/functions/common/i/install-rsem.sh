#!/usr/bin/env bash

koopa_install_rsem() {
    koopa_install_app \
        --installer='conda-package' \
        --name='rsem' \
        "$@"
}
