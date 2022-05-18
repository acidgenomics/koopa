#!/usr/bin/env bash

koopa_install_mamba() {
    koopa_install_app \
        --link-in-bin='bin/mamba' \
        --name-fancy='Mamba' \
        --name='mamba' \
        --no-prefix-check \
        "$@"
}
