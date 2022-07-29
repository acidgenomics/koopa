#!/usr/bin/env bash

koopa_install_visidata() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='vd' \
        --name='visidata' \
        "$@"
}
