#!/usr/bin/env bash

koopa_install_mamba() {
    koopa_install_app \
        --installer='conda-package' \
        --name='mamba' \
        "$@"
}
