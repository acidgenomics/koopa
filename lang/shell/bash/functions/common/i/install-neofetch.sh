#!/usr/bin/env bash

koopa_install_neofetch() {
    koopa_install_app \
        --link-in-bin='bin/neofetch' \
        --name='neofetch' \
        "$@"
}
