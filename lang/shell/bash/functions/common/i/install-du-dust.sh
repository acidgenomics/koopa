#!/usr/bin/env bash

koopa_install_du_dust() {
    koopa_install_app \
        --link-in-bin='dust' \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}
