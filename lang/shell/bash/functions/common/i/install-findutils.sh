#!/usr/bin/env bash

koopa_install_findutils() {
    koopa_install_app \
        --link-in-bin='find' \
        --link-in-bin='locate' \
        --link-in-bin='updatedb' \
        --link-in-bin='xargs' \
        --name='findutils' \
        "$@"
}
