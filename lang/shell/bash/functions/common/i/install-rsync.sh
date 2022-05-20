#!/usr/bin/env bash

koopa_install_rsync() {
    koopa_install_app \
        --link-in-bin='bin/rsync' \
        --name='rsync' \
        "$@"
}
