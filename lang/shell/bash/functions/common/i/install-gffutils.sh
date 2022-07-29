#!/usr/bin/env bash

koopa_install_gffutils() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='gffutils' \
        --name='gffutils' \
        "$@"
}
