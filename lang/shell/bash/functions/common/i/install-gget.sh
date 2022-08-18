#!/usr/bin/env bash

koopa_install_gget() {
    koopa_install_app \
        --link-in-bin='gget' \
        --name='gget' \
        "$@"
}
