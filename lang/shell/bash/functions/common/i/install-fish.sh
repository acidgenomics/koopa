#!/usr/bin/env bash

koopa_install_fish() {
    koopa_install_app \
        --link-in-bin='fish' \
        --name='fish' \
        "$@"
}
