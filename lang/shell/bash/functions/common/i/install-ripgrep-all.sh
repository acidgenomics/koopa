#!/usr/bin/env bash

koopa_install_ripgrep_all() {
    koopa_install_app \
        --link-in-bin='rga' \
        --name='ripgrep-all' \
        "$@"
}
