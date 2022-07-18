#!/usr/bin/env bash

koopa_install_mdcat() {
    koopa_install_app \
        --link-in-bin='mdcat' \
        --name='mdcat' \
        --installer='rust-package' \
        "$@"
}
