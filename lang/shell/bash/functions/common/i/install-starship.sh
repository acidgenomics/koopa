#!/usr/bin/env bash

koopa_install_starship() {
    koopa_install_app \
        --link-in-bin='starship' \
        --name='starship' \
        "$@"
}
