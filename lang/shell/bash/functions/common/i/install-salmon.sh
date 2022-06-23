#!/usr/bin/env bash

koopa_install_salmon() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/salmon' \
        --name='salmon' \
        "$@"
}
