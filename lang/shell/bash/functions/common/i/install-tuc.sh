#!/usr/bin/env bash

koopa_install_tuc() {
    koopa_install_app \
        --link-in-bin='tuc' \
        --name='tuc' \
        "$@"
}
