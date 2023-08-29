#!/usr/bin/env bash

koopa_install_mdcat() {
    koopa_install_app \
        --installer='rust-package' \
        --name='mdcat' \
        "$@"
}
