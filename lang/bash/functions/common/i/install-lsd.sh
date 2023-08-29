#!/usr/bin/env bash

koopa_install_lsd() {
    koopa_install_app \
        --installer='rust-package' \
        --name='lsd' \
        "$@"
}
