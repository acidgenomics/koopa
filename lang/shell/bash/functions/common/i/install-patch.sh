#!/usr/bin/env bash

koopa_install_patch() {
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/patch' \
        --name='patch' \
        "$@"
}
