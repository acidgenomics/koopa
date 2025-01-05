#!/usr/bin/env bash

koopa_install_mdcat() {
    koopa_install_app \
        --installer='conda-package' \
        --name='mdcat' \
        "$@"
}
