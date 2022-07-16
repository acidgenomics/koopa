#!/usr/bin/env bash

koopa_install_star() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='STAR' \
        --name='star' \
        "$@"
}
