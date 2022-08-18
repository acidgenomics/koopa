#!/usr/bin/env bash

koopa_install_visidata() {
    koopa_install_app \
        --link-in-bin='vd' \
        --link-in-bin='visidata' \
        --name='visidata' \
        "$@"
}
