#!/usr/bin/env bash

koopa_install_sd() {
    koopa_install_app \
        --installer='conda-package' \
        --name='sd' \
        "$@"
}
