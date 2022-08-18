#!/usr/bin/env bash

koopa_install_deeptools() {
    koopa_install_app \
        --link-in-bin='deeptools' \
        --name='deeptools' \
        "$@"
}
