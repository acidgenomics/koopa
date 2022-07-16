#!/usr/bin/env bash

koopa_install_salmon() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='salmon' \
        --name='salmon' \
        "$@"
}
