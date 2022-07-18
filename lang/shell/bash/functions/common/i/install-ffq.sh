#!/usr/bin/env bash

koopa_install_ffq() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='ffq' \
        --name='ffq' \
        "$@"
}
