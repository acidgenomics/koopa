#!/usr/bin/env bash

koopa_install_gffutils() {
    koopa_install_app \
        --link-in-bin='gffutils-cli' \
        --name='gffutils' \
        "$@"
}
