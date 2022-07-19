#!/usr/bin/env bash

koopa_install_r() {
    koopa_install_app \
        --link-in-bin='R' \
        --link-in-bin='Rscript' \
        --name='r' \
        "$@"
}
