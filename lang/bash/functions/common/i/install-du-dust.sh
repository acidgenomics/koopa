#!/usr/bin/env bash

koopa_install_du_dust() {
    koopa_install_app \
        --installer='rust-package' \
        --name='du-dust' \
        "$@"
}
