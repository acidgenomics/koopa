#!/usr/bin/env bash

koopa_install_mamba() {
    koopa_install_app \
        --link-in-bin='mamba' \
        --name='mamba' \
        --no-prefix-check \
        "$@"
}
