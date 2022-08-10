#!/usr/bin/env bash

koopa_install_deeptools() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='deeptools' \
        --name='deeptools' \
        "$@"
}
