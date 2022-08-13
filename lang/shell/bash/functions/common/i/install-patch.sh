#!/usr/bin/env bash

koopa_install_patch() {
    koopa_install_app \
        --link-in-bin='patch' \
        --name='patch' \
        "$@"
}
