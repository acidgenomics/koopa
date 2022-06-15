#!/usr/bin/env bash

koopa_install_gget() {
    koopa_install_app \
        --installer='conda-env' \
        --link-in-bin='bin/gget' \
        --name='gget' \
        "$@"
}
