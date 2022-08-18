#!/usr/bin/env bash

koopa_install_ripgrep() {
    koopa_install_app \
        --link-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}
