#!/usr/bin/env bash

koopa_install_fish() {
    koopa_install_app \
        --link-in-bin='bin/fish' \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}
